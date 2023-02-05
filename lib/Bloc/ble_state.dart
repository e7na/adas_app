part of 'ble_bloc.dart';

@immutable
abstract class BleState {}

class BleInitial extends BleState {}
class BleScan extends BleState {}