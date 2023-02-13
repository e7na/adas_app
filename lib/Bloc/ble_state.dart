part of 'ble_bloc.dart';

@immutable
abstract class BleState {}

class BleInitial extends BleState {}

class BleScan extends BleState {}

class BleAddDevice extends BleState {}

class BleError extends BleState {}

class BleStop extends BleState {}

class GetDevices extends BleState {}

class BleConnected extends BleState {}

class ThemeChanged extends BleState {}
