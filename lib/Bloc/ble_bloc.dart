// ignore_for_file: invalid_use_of_visible_for_testing_member
import 'dart:async';
import 'dart:convert';
import 'dart:io' show Platform;
import 'dart:math';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive/hive.dart';
import 'package:android_intent_plus/android_intent.dart';
import 'package:app_settings/app_settings.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:encrypt/encrypt.dart' as encrypt;
import 'package:adas/Data/Models/device_model.dart';
import 'package:adas/Services/flex_colors/theme_controller.dart';

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
  String unlockDoors = "OFF";

  // Bluetooth related variables
  final ble = FlutterReactiveBle();
  late StreamSubscription<DiscoveredDevice> scanStream;
  Map keys = <String, encrypt.Key>{};
  Map ivs = <String, encrypt.IV>{};
  List<BleDevice> chosenDevices = [];
  List<BleDevice> finalDevices = [];
  late StreamSubscription<List<int>> authorizationStream;
  Map<String, List<int>> rssiValues = {};
  Map finalDevicesStreams = <String, Stream<ConnectionStateUpdate>>{};
  Map finalDevicesStreamsSubs = <String, StreamSubscription<ConnectionStateUpdate>>{};
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
      // if only one device is the final devices list then scan for that device only
      // else scan for all
      scanStream = ble
          .scanForDevices(
              withServices: finalDevices.length == 1 ? finalDevices.first.uuids! : [],
              scanMode: ScanMode.lowLatency)
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
    String keys = "";
    String vectors = "";
    box.put("NumDevices", chosenDevices.length);
    // get each all names/ids in a comma separated single string
    for (int i = 0; i < chosenDevices.length; i++) {
      names += chosenDevices[i].name;
      ids += chosenDevices[i].id;
      // Generate the encryption keys
      // if there were no keys before, generate new ones
      // but if there was keys make sure to use the old ones
      keys +=
          "${chosenDevices[i].id}||${box.get("Keys", defaultValue: "") == "" || !box.get("Keys").contains(chosenDevices[i].id) ? encrypt.Key.fromSecureRandom(32).base64 : searchKeys(chosenDevices[i].id)}";
      vectors +=
          "${chosenDevices[i].id}||${box.get("Vectors", defaultValue: "") == "" || !box.get("Vectors").contains(chosenDevices[i].id) ? encrypt.IV.fromSecureRandom(16).base64 : searchVectors(chosenDevices[i].id)}";
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
        keys += ",";
        vectors += ",";
        uuids += ",";
      }
      somethingChosen = false;
    }
    // Store Them in the Hive Box
    box.put("IDs", ids);
    box.put("Names", names);
    box.put("Keys", keys);
    box.put("Vectors", vectors);
    box.put("Uuids", uuids);
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
      List<String> keysString = box.get("Keys").split(",");
      List<String> vectorsString = box.get("Vectors").split(",");
      // split keys and vectors into a map for each device
      for (int i = 0; i < keysString.length; i++) {
        keys[keysString[i].split("||")[0]] = encrypt.Key.fromBase64(keysString[i].split("||")[1]);
        ivs[vectorsString[i].split("||")[0]] =
            encrypt.IV.fromBase64(vectorsString[i].split("||")[1]);
      }
      // split uuids into a list for each device
      for (int i = 0; i < uuidsString.length; i++) {
        List<Uuid> uuidsList = [];
        List<String> list = uuidsString[i].split("#");
        for (var element in list) {
          element != "" ? uuidsList.add(Uuid.parse(element)) : null;
        }
        uuids.add(uuidsList);
      }
      // separate into ble devices
      for (int i = 0; i < numDevices; i++) {
        //now we will have a list of the car devices called finalDevices
        finalDevices.add(BleDevice(name: names[i], id: ids[i], uuids: uuids[i]));
        finalDevicesAuthStates[ids[i]] = "unauthorized";
      }
      emit(GetDevices());
    }
  }

  // These functions are used to search in the string for old keys and vectors
  String searchKeys(id) {
    String key = "";
    for (int i = 0; i < box.get("Keys").split(",").length; i++) {
      box.get("Keys").split(",")[i].split("||")[0] == id
          ? key = box.get("Keys").split(",")[i].split("||")[1]
          : null;
    }
    key == "" ? key = encrypt.Key.fromSecureRandom(32).base64 : null;
    return key;
  }

  String searchVectors(id) {
    String iv = "";
    for (int i = 0; i < box.get("Vectors").split(",").length; i++) {
      box.get("Vectors").split(",")[i].split("||")[0] == id
          ? iv = box.get("Vectors").split(",")[i].split("||")[1]
          : null;
    }
    iv == "" ? iv = encrypt.IV.fromSecureRandom(16).base64 : null;
    return iv;
  }

  // this function is called in the scan qr code page
  replaceKeys({required String id, required String key, required String vector}) {
    String keysString = "";
    String vectorsString = "";
    // replace the old key and vector with the new one
    // if the device is not in the list, this will add it
    keys[id] = encrypt.Key.fromBase64(key);
    ivs[id] = encrypt.IV.fromBase64(vector);
    // recreate the stored string
    for (int i = 0; i < keys.length; i++) {
      keysString += "${keys.entries.elementAt(i).key}||${keys.entries.elementAt(i).value.base64}";
      vectorsString += "${ivs.entries.elementAt(i).key}||${ivs.entries.elementAt(i).value.base64}";
      if (i < keys.length - 1) {
        keysString += ",";
        vectorsString += ",";
      }
    }
    // store the new string
    box.put("Keys", keysString);
    box.put("Vectors", vectorsString);
  }

  // Unlock or close car doors
  controlDoors(BleDevice device) async {
    if (finalDevicesAuthStates[device.id] == "authorized") {
      // send the msg to control door
      final characteristic6 = QualifiedCharacteristic(
          serviceId: Uuid.parse("d9327ccb-992b-4d78-98ce-2297ed2c09d6"),
          characteristicId: Uuid.parse("9800d290-19fb-4085-9610-f1e878725ad2"),
          deviceId: device.id);
      // read the state of the doors characteristic
      final response = await ble.readCharacteristic(characteristic6);
      // Make Sure the values come from the esp32
      unlockDoors = utf8.decode(response);
      await ble.writeCharacteristicWithResponse(characteristic6,
          value: utf8.encode(unlockDoors == "OFF" ? "ON" : "OFF"));
      // wait to make sure it changed in the esp32
      await Future.delayed(const Duration(seconds: 1));
      final response2 = await ble.readCharacteristic(characteristic6);
      // Make Sure the value changed in the esp32
      unlockDoors = utf8.decode(response2);
      emit(StatusChanged());
    }
  }

  authorizeDevice(BleDevice device) async {
    // listen to the state of the authorization characteristic
    final characteristic1 = QualifiedCharacteristic(
        serviceId: Uuid.parse("d9327ccb-992b-4d78-98ce-2297ed2c09d6"),
        characteristicId: Uuid.parse("e95e7f63-f041-469f-90db-04d2e3e7619b"),
        deviceId: device.id);
    // read the state of the authorization characteristic
    final response = await ble.readCharacteristic(characteristic1);
    utf8.decode(response).toLowerCase() != "authorized"
        ? {
            // start listening to the authorization characteristic
            startStream(device, characteristic1),
            // send key and vector to the esp32
            sendKey(device),
            await Future.delayed(const Duration(seconds: 2)),
            handshake(device),
            emit(StatusChanged()),
          }
        : null;
  }

  startStream(BleDevice device, QualifiedCharacteristic characteristic1) {
    // subscribe to the authorization characteristic
    authorizationStream = ble.subscribeToCharacteristic(characteristic1).listen((data) {
      // set the authorization state to the one coming from the esp32
      finalDevicesAuthStates[device.id] = utf8.decode(data).toLowerCase();
      emit(StatusChanged());
    }, onError: (dynamic error) {
      // code to handle errors
    });
  }

  // send encryption key to the esp32
  sendKey(BleDevice device) async {
    // send the encryption key to the esp32
    final characteristic2 = QualifiedCharacteristic(
        serviceId: Uuid.parse("d9327ccb-992b-4d78-98ce-2297ed2c09d6"),
        characteristicId: Uuid.parse("8c233b56-4988-4c3c-95b5-ec5b3c179c91"),
        deviceId: device.id);
    await ble.writeCharacteristicWithResponse(characteristic2, value: keys[device.id].bytes);
    // send the encryption vector to the esp32
    final characteristic3 = QualifiedCharacteristic(
        serviceId: Uuid.parse("d9327ccb-992b-4d78-98ce-2297ed2c09d6"),
        characteristicId: Uuid.parse("56bba80a-91f1-46ab-b892-7325e19c3429"),
        deviceId: device.id);
    await ble.writeCharacteristicWithResponse(characteristic3, value: ivs[device.id].bytes);
  }

  //handshake with esp32
  handshake(BleDevice device) async {
    // Read the msg that needs to be encrypted
    final characteristic4 = QualifiedCharacteristic(
        // This is the service & characteristics ids from the esp32 used in the project
        serviceId: Uuid.parse("d9327ccb-992b-4d78-98ce-2297ed2c09d6"),
        characteristicId: Uuid.parse("53a15a66-6dd7-4421-9468-38cf731a77db"),
        deviceId: device.id);
    // get the value from the msg characteristic
    final response = await ble.readCharacteristic(characteristic4);
    // encrypt the msg
    Uint8List encryptedMsg =
        encrypt.Encrypter(encrypt.AES(keys[device.id], mode: encrypt.AESMode.cbc, padding: null))
            .encrypt(utf8.decode(response), iv: ivs[device.id])
            .bytes;
    // send the encrypted msg
    final characteristic5 = QualifiedCharacteristic(
        serviceId: Uuid.parse("d9327ccb-992b-4d78-98ce-2297ed2c09d6"),
        characteristicId: Uuid.parse("acc9a30f-9e44-4323-8193-7bac8c9bc484"),
        deviceId: device.id);
    // write the encrypted msg to the encrypted characteristic
    await ble.writeCharacteristicWithResponse(characteristic5, value: encryptedMsg);
  }

  //establish connection with device
  connectToDevice(BleDevice device) {
    // Connect to device with id
    finalDevicesStreams[device.id] = ble.connectToDevice(
      id: device.id,
      connectionTimeout: const Duration(seconds: 1),
    );
    // Let's listen to our connection so we can make updates on a state change
    finalDevicesStreamsSubs[device.id] = finalDevicesStreams[device.id].listen((event) {
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
    finalDevicesStreamsSubs[device.id].cancel();
    finalDevicesStates[device.id] = DeviceConnectionState.disconnected;
    emit(BleConnected());
  }

  // This Function is used to enable bluetooth
  startBlue() async {
    if (Platform.isAndroid) {
      const AndroidIntent(
        action: 'android.bluetooth.adapter.action.REQUEST_ENABLE',
      ).launch().catchError((e) => AppSettings.openAppSettings(type: AppSettingsType.bluetooth));
      await Future.delayed(const Duration(seconds: 2));
    } else {
      AppSettings.openAppSettings(type: AppSettingsType.bluetooth);
    }
  }

  // This Function is used to enable bluetooth
  openLocationSettings() async {
    if (Platform.isAndroid) {
      const AndroidIntent(
        action: 'android.settings.LOCATION_SOURCE_SETTINGS',
      ).launch().catchError((e) => AppSettings.openAppSettings(type: AppSettingsType.location));
      await Future.delayed(const Duration(seconds: 2));
    } else {
      AppSettings.openAppSettings(type: AppSettingsType.location);
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
