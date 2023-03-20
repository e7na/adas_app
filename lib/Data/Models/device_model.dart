import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';

class BleDevice {
  String name;
  String id;
  List<Uuid>? uuids;

  BleDevice({required this.name, required this.id, this.uuids});
}
