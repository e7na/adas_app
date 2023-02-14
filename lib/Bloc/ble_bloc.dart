// ignore_for_file: invalid_use_of_visible_for_testing_member
import 'dart:async';
import 'dart:io' show Platform;
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
  var brightness = SchedulerBinding.instance.window.platformBrightness;
  late Box box;
  late ColorScheme theme;
  late ThemeController themeController;

  // Some state management stuff
  bool scanStarted = false;
  bool locationService = false;
  bool somethingChosen = false;
  bool addedToStreams = false;
  String currentLog = "";

  List<BleDevice> chosenDevices = [];
  List<BleDevice> finalDevices = [];
  Map finalDevicesStreams = <String, Stream<ConnectionStateUpdate>>{};
  Map finalDevicesStates = <String, DeviceConnectionState>{};
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
    return (await [
      Permission.location,
      Permission.bluetoothScan,
      Permission.bluetoothConnect,
      Permission.nearbyWifiDevices,
    ].request());
  }

  // Scanning logic happens here
  startScan() async {
    if (ble.status != BleStatus.ready) {
      await startBlue();
      if (ble.status == BleStatus.locationServicesDisabled) {
        Fluttertoast.showToast(
            msg: "T3".tr(),
            toastLength: Toast.LENGTH_LONG,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 1,
            backgroundColor: theme.secondary,
            textColor: theme.onSecondary,
            fontSize: 16.0);
      } else if (ble.status != BleStatus.locationServicesDisabled) {
        startScan();
      }
    } else {
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
  }

  // Stop scanning for devices
  stopScan() async {
    await scanStream.cancel();
    scanStarted = false;
    //devices.clear(); // Should it clear ?
    emit(BleStop());
  }

  // This should add the device the chosen devices list
  bool deviceAdd({required BleDevice device}) {
    chosenDevices.add(device);
    somethingChosen = true;
    emit(BleAddDevice());
    debugPrint("Num of Devices Chosen ${chosenDevices.length}");
    return true;
  }

  // This should remove the devices from chosen devices list
  bool deviceRemove({required BleDevice device}) {
    chosenDevices.removeWhere((element) => element.id == device.id);
    somethingChosen = chosenDevices.isNotEmpty ? true : false;
    emit(BleAddDevice());
    debugPrint("Num of Devices Chosen ${chosenDevices.length}");
    return false;
  }

  // This saves the chosen devices list to Shared Preferences
  saveDevices() async {
    String names = "";
    String ids = "";
    box.put("NumDevices", chosenDevices.length);
    // get each all names/ids in a comma separated single string
    for (int i = 0; i < chosenDevices.length; i++) {
      names += chosenDevices[i].name;
      ids += chosenDevices[i].id;
      // add comma if not last name/id
      if (i < chosenDevices.length - 1) {
        names += ",";
        ids += ",";
      }
      somethingChosen = false;
    }
    // Store Them in Shared Preferences
    box.put("IDs", ids);
    box.put("Names", names);
  }

  // Extract selected devices from shared prefs into a list
  // This will get called at the main page and every time the app is opened after the first scan
  getDevices() async {
    finalDevices = [];
    //get stored values from SharedPreferences
    int numDevices = box.get("NumDevices")!;
    //Split names/ids into a list of strings
    List<String> names = box.get("Names")!.split(",");
    List<String> ids = box.get("IDs")!.split(",");
    // separate into ble devices
    for (int i = 0; i < numDevices; i++) {
      //now we will have a list of the car devices called finalDevices
      finalDevices.add(BleDevice(name: names[i], id: ids[i]));
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

  themeChanged() {
    emit(ThemeChanged());
  }
}
