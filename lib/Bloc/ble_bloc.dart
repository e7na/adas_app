// ignore_for_file: invalid_use_of_visible_for_testing_member
import 'dart:async';
import 'dart:io' show Platform;
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:android_intent_plus/android_intent.dart';
import 'package:app_settings/app_settings.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:blue/Data/Models/device_model.dart';

part 'ble_event.dart';

part 'ble_state.dart';

class BleBloc extends Bloc<BleEvent, BleState> {
  var brightness = SchedulerBinding.instance.window.platformBrightness;

  // Some state management stuff
  bool scanStarted = false;
  bool locationService = false;
  bool somethingChosen = false;
  bool connected = false;
  bool addedToStreams = false;
  String currentLog = "";

  List<BleDevice> chosenDevices = [];
  List<BleDevice> finalDevices = [];
  List<Stream<ConnectionStateUpdate>> finalDevicesStreams = [];
  final devices = <DiscoveredDevice>[];

  // Bluetooth related variables
  final ble = FlutterReactiveBle();
  late StreamSubscription<DiscoveredDevice> scanStream;

  static BleBloc get(context) => BlocProvider.of(context);

  BleBloc() : super(BleInitial()) {
    on<BleEvent>((event, emit) {});
  }

  // Permissions handling stuff
  Future<Map<Permission, PermissionStatus>> requestPermissions() async {
    locationService = await Permission.locationWhenInUse.serviceStatus.isEnabled;
    emit(BleScan());
    return (await [
      Permission.location,
      Permission.bluetoothScan,
      Permission.bluetoothConnect,
      Permission.nearbyWifiDevices,
    ].request());
  }

  // Scanning logic happens here
  startScan() async {
    ble.status == BleStatus.poweredOff ? await startBlue() : null;
    scanStarted = true;
    currentLog = 'Start ble discovery';
    scanStream = ble.scanForDevices(withServices: []).listen((device) {
      final knownDeviceIndex = devices.indexWhere((d) => d.id == device.id);
      if (knownDeviceIndex >= 0) {
        devices[knownDeviceIndex] = device;
      } else {
        devices.add(device);
      }
      emit(BleAddDevice());
    }, onError: (Object e) => currentLog = 'Device scan fails with error: $e');
    emit(BleError());
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
    debugPrint("Num of Devices Chosen ${chosenDevices.length}");
    return true;
  }

  // This should remove the devices from chosen devices list
  bool deviceRemove({required BleDevice device}) {
    chosenDevices.removeWhere((element) => element.id == device.id);
    somethingChosen = chosenDevices.isNotEmpty ? true : false;
    debugPrint("Num of Devices Chosen ${chosenDevices.length}");
    return false;
  }

  // This saves the chosen devices list to Shared Preferences
  saveDevices() async {
    String names = "";
    String ids = "";
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt("NumDevices", chosenDevices.length);
    // get each all names/ids in a comma separated single string
    for (int i = 0; i < chosenDevices.length; i++) {
      names += chosenDevices[i].name;
      ids += chosenDevices[i].id;
      // add comma if not last name/id
      if (i < chosenDevices.length - 1) {
        names += ",";
        ids += ",";
      }
    }
    // Store Them in Shared Preferences
    await prefs.setString("IDs", ids);
    await prefs.setString("Names", names);
  }

  // Extract selected devices from shared prefs into a list
  // This will get called at the main page and every time the app is opened after the first scan
  getDevices() async {
    //To get Rssi Values when app starts
    startScan();

    finalDevices = [];
    final prefs = await SharedPreferences.getInstance();
    //get stored values from SharedPreferences
    int numDevices = prefs.getInt("NumDevices")!;
    //Split names/ids into a list of strings
    List<String> names = prefs.getString("Names")!.split(",");
    List<String> ids = prefs.getString("IDs")!.split(",");
    // separate into ble devices
    for (int i = 0; i < numDevices; i++) {
      //now we will have a list of the car devices called finalDevices
      finalDevices.add(BleDevice(name: names[i], id: ids[i]));
    }
    // await connectToAllDevice();
    emit(GetDevices());
  }

  //establish connection with all chosen devices
  connectToAllDevice() {
    // To Disconnect we can use currentConnectionStream.cancel()
    if (addedToStreams == false) {
      // for (BleDevice device in finalDevices) {
      //   finalDevicesStreams.add(ble.connectToAdvertisingDevice(
      //     id: device.id,
      //     connectionTimeout: const Duration(seconds: 5),
      //     withServices: [],
      //     prescanDuration: const Duration(seconds: 5),
      //   ));
      // }
      for (BleDevice device in finalDevices) {
        finalDevicesStreams.add(ble.connectToDevice(
          id: device.id,
          connectionTimeout: const Duration(seconds: 5),
        ));
      }
    }
    for (var stream in finalDevicesStreams) {
      stream.listen((event) {
        switch (event.connectionState) {
          case DeviceConnectionState.connecting:
            {
              debugPrint('Connecting');
              break;
            }
          // We're connected and good to go!
          case DeviceConnectionState.connected:
            {
              debugPrint("Connected");
              connected = true;
              break;
            }
          // Can add various state updates on disconnect
          case DeviceConnectionState.disconnected:
            {
              debugPrint("Disconnected");
              connected = false;
              break;
            }
          default:
        }
      });
    }
    addedToStreams = true;
  }

  //establish connection with device
  connectToDevice(int index) {
    BleDevice device = finalDevices[index];
    // Let's listen to our connection so we can make updates on a state change
    // To Disconnect we can use currentConnectionStream.cancel()
    Stream<ConnectionStateUpdate> currentConnectionStream = ble.connectToDevice(
      id: device.id,
      connectionTimeout: const Duration(seconds: 5),
    );
    currentConnectionStream.listen((event) {
      switch (event.connectionState) {
        case DeviceConnectionState.connecting:
          {
            debugPrint('Connecting $index');
            break;
          }
        // We're connected and good to go!
        case DeviceConnectionState.connected:
          {
            debugPrint("Connected $index");
            connected = true;
            break;
          }
        // Can add various state updates on disconnect
        case DeviceConnectionState.disconnected:
          {
            debugPrint("Disconnected $index");
            connected = false;
            break;
          }
        default:
      }
    });
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
}
