part of 'ble_bloc.dart';

@immutable
abstract class BleState {}

class BleInitial extends BleState {}

class BleScan extends BleState {}

class BleStop extends BleState {}

class BleFound extends BleState {}

class BleConnected extends BleState {}
