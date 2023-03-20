// ignore_for_file: invalid_use_of_visible_for_testing_member
import 'dart:async';
import 'dart:io' show Platform;
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive/hive.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:android_intent_plus/android_intent.dart';
import 'package:app_settings/app_settings.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:blue/Data/Models/device_model.dart';
import 'package:blue/Services/flex_colors/theme_controller.dart';

part 'ble_event.dart';

part 'ble_state.dart';

class BleBloc extends Bloc<BleEvent, BleState> {
  Brightness brightness = SchedulerBinding.instance.window.platformBrightness;
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
  List<BleDevice> chosenDevices = [];
  List<BleDevice> finalDevices = [];
  Map<String, List<int>> rssiValues = {};
  Map finalDevicesStreams = <String, Stream<ConnectionStateUpdate>>{};
  Map finalDevicesStates = <String, DeviceConnectionState>{};
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

  // TODO: Separate Home page scan from Scan page scan
  // Scanning logic happens here
  startScan({bool home = false}) async {
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
        Fluttertoast.showToast(
            msg: "T3".tr(),
            toastLength: Toast.LENGTH_LONG,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 1,
            backgroundColor: theme.secondary,
            textColor: theme.onSecondary,
            fontSize: 16.0);
      }
      // if both are on, invoke the function again
      if (ble.status != BleStatus.poweredOff && ble.status != BleStatus.locationServicesDisabled) {
        startScan();
      }
      // if every thing is ready start scanning
    } else {
      scanStarted = true;
      currentLog = 'Start ble discovery';
      scanStream = ble.scanForDevices(withServices: home ? [] : []).listen((device) {
        final knownDeviceIndex = devices.indexWhere((d) => d.id == device.id);
        if (knownDeviceIndex >= 0) {
          devices[knownDeviceIndex] = device;
          emit(BleScan());
        } else {
          devices.add(device);
          emit(BleAddDevice());
        }
      }, onError: (Object e) => currentLog = 'Device scan fails with error: $e');
      emit(BleError());
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
  }

  // Extract selected devices from the Hive Box into a list
  // This will get called at the main page and every time the app is opened after the first scan
  getDevices() async {
    List<List<Uuid>> uuids = [];
    finalDevices = [];
    //get stored values from the Hive Box
    int numDevices = box.get("NumDevices")!;
    //Split names/ids into a list of strings
    List<String> names = box.get("Names")!.split(",");
    List<String> ids = box.get("IDs")!.split(",");
    List<String> uuidsString = box.get("Uuids")!.split(",");
    // split uuids into a list for each device
    for (int i = 0; i < uuidsString.length; i++) {
      List<Uuid> uuidsList = [];
      List<String> list = uuidsString[i].split("#");
      for (var element in list) {
        uuidsList.add(Uuid.parse(element));
      }
      uuids.add(uuidsList);
    }
    debugPrint("$uuids");
    // separate into ble devices
    for (int i = 0; i < numDevices; i++) {
      //now we will have a list of the car devices called finalDevices
      finalDevices.add(BleDevice(name: names[i], id: ids[i], uuids: uuids[i]));
    }
    // await connectToAllDevice();
    emit(GetDevices());
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

  // change state stuff
  themeChanged() {
    emit(ThemeChanged());
  }

  isRemoveChanged() {
    emit(BleAddDevice());
  }
}
