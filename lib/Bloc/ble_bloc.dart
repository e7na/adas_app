// ignore_for_file: invalid_use_of_visible_for_testing_member
import 'dart:async';
import 'dart:io' show Platform;
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive/hive.dart';
import 'package:android_intent_plus/android_intent.dart';
import 'package:app_settings/app_settings.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:encrypt/encrypt.dart' as encrypt;
import 'package:blue/Data/Models/device_model.dart';
import 'package:blue/Services/flex_colors/theme_controller.dart';

part 'ble_event.dart';

part 'ble_state.dart';

class BleBloc extends Bloc<BleEvent, BleState> {
  Brightness brightness = SchedulerBinding.instance.platformDispatcher.platformBrightness;
  late Box box;
  late ColorScheme theme;
  late ThemeController themeController;
  late String lang;

  // Some state management stuff
  bool scanStarted = false;
  bool locationService = false;
  bool somethingChosen = false;
  bool addedToStreams = false;
  bool timerStarted = false;
  String currentLog = "";

  // Bluetooth related variables
  final ble = FlutterReactiveBle();
  late StreamSubscription<DiscoveredDevice> scanStream;
  late encrypt.Key key;
  late encrypt.IV iv;
  List<BleDevice> chosenDevices = [];
  List<BleDevice> finalDevices = [];
  Map<String, List<int>> rssiValues = {};
  Map finalDevicesStreams = <String, Stream<ConnectionStateUpdate>>{};
  Map finalDevicesStates = <String, DeviceConnectionState>{};
  Map finalDevicesAuthStates = <String, String>{};
  final devices = <DiscoveredDevice>[];

  static BleBloc get(context) => BlocProvider.of(context);

  BleBloc() : super(BleInitial()) {
    on<BleEvent>((event, emit) {});
  }

  // Permissions handling stuff
  Future<Map<Permission, PermissionStatus>> requestPermissions() async {
    return (await [
      Permission.location,
      Permission.bluetoothScan,
      Permission.bluetoothConnect,
      Permission.nearbyWifiDevices,
    ].request());
  }

  // Scanning logic happens here
  startScan() async {
    //  First Check if bluetooth is on
    if (ble.status != BleStatus.ready) {
      if ({BleStatus.poweredOff, BleStatus.unauthorized, BleStatus.unknown}.contains(ble.status)) {
        await startBlue().whenComplete(() async {
          // wait for BleStatus to change
          await Future.delayed(const Duration(seconds: 1));
        });
      }
      // then if location is on
      if (ble.status == BleStatus.locationServicesDisabled) {
        await openLocationSettings();
      }
      // if both are on, invoke the function again
      if (ble.status != BleStatus.poweredOff && ble.status != BleStatus.locationServicesDisabled) {
        startScan();
      }
      // if every thing is ready start scanning
    } else {
      scanStarted = true;
      currentLog = 'Start ble discovery';
      // if only one device is the final devices list then scan for that device only
      // else scan for all
      scanStream = ble
          .scanForDevices(withServices: finalDevices.length == 1 ? finalDevices.first.uuids! : [])
          .listen((device) {
        final knownDeviceIndex = devices.indexWhere((d) => d.id == device.id);
        if (knownDeviceIndex >= 0) {
          devices[knownDeviceIndex] = device;
          emit(BleScan());
        } else {
          devices.add(device);
          emit(BleAddDevice());
        }
      }, onError: (Object e) {
        currentLog = 'Device scan fails with error: $e';
        emit(BleError());
      });
    }
  }

  // Stop scanning for devices
  stopScan() async {
    await scanStream.cancel();
    scanStarted = false;
    devices.clear(); // Should it clear ?
    emit(BleStop());
  }

  // This should add the device the chosen devices list
  bool deviceAdd({required BleDevice device}) {
    chosenDevices.add(device);
    somethingChosen = true;
    return true;
  }

  // This should remove the devices from chosen devices list
  bool deviceRemove({required BleDevice device}) {
    chosenDevices.removeWhere((element) => element.id == device.id);
    somethingChosen = chosenDevices.isNotEmpty;
    return false;
  }

  // This should be correctly tuned
  // Simple algorithm to estimate distance
  String estimateDistance({required int rssi}) {
    // Environmental factor, a constant between 2 and 4
    int N = 4;
    // Signal broadcast power at 1m (Tx Power)
    int P = -60;
    // Estimated distance in meters
    late num D;
    // The Equation to estimate distance
    D = pow(10, ((P - rssi) / (10 * N)));
    return D.toStringAsFixed(2);
  }

  // More accurate algorithm to estimate distance
  String calculateDistance({required int rssi, int txPower = -59}) {
    // -59 is the most common txPower for ble devices but it should be calculated
    if (rssi == 0) {
      return (-1.0).toString(); // undefined
    }

    double ratio = rssi / txPower;
    if (ratio < 1.0) {
      return pow(ratio, 10.0).toStringAsFixed(2);
    } else {
      double distance = (0.89976) * pow(ratio, 7.7095) + 0.111;
      if (distance <= 1.0) {
        return pow(ratio, 10.0).toStringAsFixed(2);
      } else if (distance > 10) {
        // Algorithm is not accurate when distance is more than 10m
        return "> 10";
      } else {
        return distance.toStringAsFixed(2);
      }
    }
  }

  // A Function to stabilize rssi values by averaging them every specified amount of time
  int averageRssi({required int rssi, required String id}) {
    // start timer for 5 seconds then reset list
    timerStarted ? null : scheduleTimeout(5 * 1000); // 5 seconds
    int average = 0;
    // Get list from map -> This is to have more than one device
    List<int> allRssi = rssiValues[id] ?? [];
    allRssi.add(rssi);
    // add all list items p = previous , c = current
    int sum = allRssi.fold(0, (p, c) => p + c);
    // average and round, rssi is an int value
    sum != 0 ? average = (sum / allRssi.length).round() : null;
    // put new list in map
    rssiValues[id] = allRssi;
    // print("rssi: $rssi % average: $average");
    return average;
  }

  // Just A Timer
  Timer scheduleTimeout([int milliseconds = 10000]) {
    timerStarted = true;
    // print("Timer Started");
    return Timer(Duration(milliseconds: milliseconds), handleTimeout);
  }

  // Callback Function
  void handleTimeout() {
    // Reset all devices
    rssiValues = {};
    // to Start Timer Again
    timerStarted = false;
    // print("Timer Finished");
  }

  // This saves the chosen devices list to the Hive Box
  saveDevices() async {
    String names = "";
    String ids = "";
    String uuids = "";
    box.put("NumDevices", chosenDevices.length);
    // get each all names/ids in a comma separated single string
    for (int i = 0; i < chosenDevices.length; i++) {
      names += chosenDevices[i].name;
      ids += chosenDevices[i].id;
      // device can have multiple uuids
      for (int j = 0; j < chosenDevices[i].uuids!.length; j++) {
        uuids += chosenDevices[i].uuids![j].toString();
        // add hash if not last uuid
        if (j < chosenDevices[i].uuids!.length - 1) {
          uuids += "#";
        }
      }
      // add comma if not last name/id
      if (i < chosenDevices.length - 1) {
        names += ",";
        ids += ",";
        uuids += ",";
      }
      somethingChosen = false;
    }
    // Store Them in the Hive Box
    box.put("IDs", ids);
    box.put("Names", names);
    box.put("Uuids", uuids);
    // Generate the encryption key
    box.get("key", defaultValue: 0) == 0
        ? {key = encrypt.Key.fromSecureRandom(32), box.put("key", key.base64)}
        : null;
    box.get("iv", defaultValue: 0) == 0
        ? {iv = encrypt.IV.fromSecureRandom(16), box.put("iv", iv.base64)}
        : null;
    stopScan();
  }

  // Extract selected devices from the Hive Box into a list
  // This will get called at the main page and every time the app is opened after the first scan
  getDevices() async {
    List<List<Uuid>> uuids = [];
    finalDevices = [];
    //get stored values from the Hive Box
    int numDevices = box.get("NumDevices", defaultValue: 0);
    if (numDevices > 0) {
      //Split names/ids into a list of strings
      List<String> names = box.get("Names").split(",");
      List<String> ids = box.get("IDs").split(",");
      List<String> uuidsString = box.get("Uuids").split(",");
      // split uuids into a list for each device
      for (int i = 0; i < uuidsString.length; i++) {
        List<Uuid> uuidsList = [];
        List<String> list = uuidsString[i].split("#");
        for (var element in list) {
          element != "" ? uuidsList.add(Uuid.parse(element)) : null;
        }
        uuids.add(uuidsList);
      }
      debugPrint("uuids:$uuids");
      // separate into ble devices
      for (int i = 0; i < numDevices; i++) {
        //now we will have a list of the car devices called finalDevices
        finalDevices.add(BleDevice(name: names[i], id: ids[i], uuids: uuids[i]));
        finalDevicesAuthStates[ids[i]] = "unauthorized";
      }
      // get the encryption key
      key = encrypt.Key.fromBase64(box.get("key"));
      iv = encrypt.IV.fromBase64(box.get("iv"));
      emit(GetDevices());
    }
  }

  //establish connection with device
  authorizeDevice(BleDevice device) async {
    // Read the msg that needs to be encrypted
    final characteristic2 = QualifiedCharacteristic(
        // This is the service & characteristics ids from the esp32 used in the project
        serviceId: Uuid.parse("4fafc201-1fb5-459e-8fcc-c5c9c331914b"),
        characteristicId: Uuid.parse("beb5483e-36e1-4688-b7f5-ea07361b26a8"),
        deviceId: device.id);
    // get the value from the msg characteristic
    final response = await ble.readCharacteristic(characteristic2);
    debugPrint("response: $response");
    // send the encrypted msg
    final characteristic3 = QualifiedCharacteristic(
        serviceId: Uuid.parse("4fafc201-1fb5-459e-8fcc-c5c9c331914b"),
        characteristicId: Uuid.parse("fc477e34-adb4-4d01-b56e-d0a2671ecc39"),
        deviceId: device.id);
    // write the encrypted msg to the encrypted characteristic
    await ble.writeCharacteristicWithResponse(characteristic3, value: key.bytes);
    // Let's listen to the state of the authorization characteristic now
    final characteristic1 = QualifiedCharacteristic(
        serviceId: Uuid.parse("4fafc201-1fb5-459e-8fcc-c5c9c331914b"),
        characteristicId: Uuid.parse("fc477e34-adb4-4d01-b56e-d0a2671ecc39"),
        deviceId: device.id);
    ble.subscribeToCharacteristic(characteristic1).listen((data) {
      // set the authorization state to the one coming from the esp32
      data == [0x1]
          ? finalDevicesAuthStates[device.id] = "authorized"
          : finalDevicesAuthStates[device.id] = "unauthorized";
    }, onError: (dynamic error) {
      // code to handle errors
    });
  }

  //establish connection with device
  connectToDevice(BleDevice device) {
    // Connect to device with id
    finalDevicesStreams[device.id] = ble.connectToDevice(
      id: device.id,
      connectionTimeout: const Duration(seconds: 1),
    );
    // Let's listen to our connection so we can make updates on a state change
    finalDevicesStreams[device.id].listen((event) {
      finalDevicesStates[device.id] = event.connectionState;
      event.connectionState == DeviceConnectionState.disconnected
          ? finalDevicesAuthStates[device.id] = "unauthorized"
          : null;
      debugPrint("${device.id} ${event.connectionState}");
      emit(BleConnected());
    });
  }

  //disconnect from device
  disconnectDevice(BleDevice device) {
    finalDevicesStreams[device.id].currentConnectionStream.cancel();
    finalDevicesStates[device.id] = DeviceConnectionState.disconnected;
  }

  // This Function is used to enable bluetooth
  startBlue() async {
    if (Platform.isAndroid) {
      const AndroidIntent(
        action: 'android.bluetooth.adapter.action.REQUEST_ENABLE',
      ).launch().catchError((e) => AppSettings.openBluetoothSettings());
      await Future.delayed(const Duration(seconds: 2));
    } else {
      AppSettings.openBluetoothSettings();
    }
  }

  // This Function is used to enable bluetooth
  openLocationSettings() async {
    if (Platform.isAndroid) {
      const AndroidIntent(
        action: 'android.settings.LOCATION_SOURCE_SETTINGS',
      ).launch().catchError((e) => AppSettings.openLocationSettings());
      await Future.delayed(const Duration(seconds: 2));
    } else {
      AppSettings.openLocationSettings();
    }
  }

  // change state stuff
  themeChanged() {
    emit(ThemeChanged());
  }

  stateChanged() {
    emit(StatusChanged());
  }

  isRemoveChanged() {
    emit(BleAddDevice());
  }
}
