// ignore_for_file: invalid_use_of_visible_for_testing_member
import 'dart:async';
import 'dart:io' show Platform;
import 'package:flutter/material.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:android_intent_plus/android_intent.dart';
import 'package:app_settings/app_settings.dart';
import 'package:permission_handler/permission_handler.dart';

part 'ble_event.dart';

part 'ble_state.dart';

class BleBloc extends Bloc<BleEvent, BleState> {
  // Some state management stuff
  bool scanStarted = false;
  bool connected = false;
  bool locationService = false;
  final devices = <DiscoveredDevice>[];
  String currentLog = "";

  // Bluetooth related variables
  final flutterReactiveBle = FlutterReactiveBle();
  late StreamSubscription<DiscoveredDevice> scanStream;

  // These are the UUIDs of the cars device/s??
  final Uuid serviceUuid = Uuid.parse("75C276C3-8F97-20BC-A143-B354244886D4");
  final Uuid characteristicUuid = Uuid.parse("6ACF4F08-CC9D-D495-6B41-AA7E60C4E8A6");

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

  void startScan() async {
    // Main scanning logic happens here
    scanStarted = true;
    currentLog = 'Start ble discovery';
    scanStream = flutterReactiveBle.scanForDevices(withServices: []).listen((device) {
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

  // Simple function to stop searching for devices
  void stopScan() async {
    await scanStream.cancel();
    scanStarted = false;
    devices.clear(); // Should it clear ?
    emit(BleStop());
  }

  void connectToDevice(int index) {
    debugPrint('Outside');
    DiscoveredDevice device = devices[index];
    // Let's listen to our connection so we can make updates on a state change
    Stream<ConnectionStateUpdate> currentConnectionStream =
        flutterReactiveBle.connectToAdvertisingDevice(
      id: device.id,
      prescanDuration: const Duration(seconds: 5),
      connectionTimeout: const Duration(seconds: 2), withServices: [],
    );
    currentConnectionStream.listen((event) {
      debugPrint('Inside');
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
            emit(BleConnected());
            break;
          }
        // Can add various state state updates on disconnect
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

  // This Function is used to enable bluetooth
  startBlue() {
    if (Platform.isAndroid) {
      const AndroidIntent(
        action: 'android.bluetooth.adapter.action.REQUEST_ENABLE',
      ).launch().catchError((e) => AppSettings.openBluetoothSettings());
    } else {
      AppSettings.openBluetoothSettings();
    }
  }
}
