// ignore_for_file: invalid_use_of_visible_for_testing_member
import 'dart:async';
import 'dart:io' show Platform;
import 'package:flutter/material.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:location_permissions/location_permissions.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'ble_event.dart';

part 'ble_state.dart';

class BleBloc extends Bloc<BleEvent, BleState> {
  // Some state management stuff
  bool foundDeviceWaitingToConnect = false;
  bool scanStarted = false;
  bool connected = false;

  // Bluetooth related variables
  late DiscoveredDevice dDevice;
  final flutterReactiveBle = FlutterReactiveBle();
  late StreamSubscription<DiscoveredDevice> scanStream;
  late QualifiedCharacteristic rxCharacteristic;

  // These are the UUIDs of the cars device/s??
  final Uuid serviceUuid = Uuid.parse("75C276C3-8F97-20BC-A143-B354244886D4");
  final Uuid characteristicUuid =
      Uuid.parse("6ACF4F08-CC9D-D495-6B41-AA7E60C4E8A6");

  static BleBloc get(context) => BlocProvider.of(context);

  BleBloc() : super(BleInitial()) {
    on<BleEvent>((event, emit) {});
  }

  void startScan() async {
    // Platform permissions handling stuff
    bool permGranted = false;
    scanStarted = true;
    emit(BleScan());
    //TODO: Rework Permissions here
    PermissionStatus permission;
    if (Platform.isAndroid) {
      permission = await LocationPermissions().requestPermissions();
      if (permission == PermissionStatus.granted) permGranted = true;
    } else if (Platform.isIOS) {
      permGranted = true;
    }
    // Main scanning logic happens here
    if (permGranted) {
      scanStream = flutterReactiveBle
          .scanForDevices(withServices: [serviceUuid]).listen((device) {
        // Change this string to what we define later
        if (device.name == 'Something') {
          dDevice = device;
          foundDeviceWaitingToConnect = true;
          emit(BleFound());
        }
      });
    }
  }

  // Simple function to stop searching for devices
  void stopScan() async {
    await scanStream.cancel();
    scanStarted = false;
    emit(BleStop());
  }

  void connectToDevice() {
    // We're done scanning, we can cancel it
    scanStream.cancel();
    // Let's listen to our connection so we can make updates on a state change
    Stream<ConnectionStateUpdate> currentConnectionStream = flutterReactiveBle
        .connectToAdvertisingDevice(
            id: dDevice.id,
            prescanDuration: const Duration(seconds: 1),
            withServices: [serviceUuid, characteristicUuid]);
    currentConnectionStream.listen((event) {
      switch (event.connectionState) {
        // We're connected and good to go!
        case DeviceConnectionState.connected:
          {
            rxCharacteristic = QualifiedCharacteristic(
                serviceId: serviceUuid,
                characteristicId: characteristicUuid,
                deviceId: event.deviceId);
            foundDeviceWaitingToConnect = false;
            connected = true;
            emit(BleConnected());
            break;
          }
        // Can add various state state updates on disconnect
        case DeviceConnectionState.disconnected:
          {
            break;
          }
        default:
      }
    });
  }
}
