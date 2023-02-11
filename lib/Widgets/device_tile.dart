import 'package:flutter/material.dart';
import 'package:blue/Data/Models/device_model.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';

class DeviceTile extends StatelessWidget {
  final BleDevice device;
  final int rssi;
  final DeviceConnectionState status;

  const DeviceTile({Key? key, required this.device, required this.rssi, required this.status})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          initiallyExpanded: true,
          title: Text(device.name),
          children: [
            ListTile(
                title: const Text("ID"),
                trailing: Text(
                  device.id,
                )),
            ListTile(
                title: const Text("Rssi"),
                trailing: Text(
                  "$rssi",
                )),
            ListTile(
                title: const Text("Status"),
                trailing: Text(
                  "$status".split(".")[1].toUpperCase(),
                ))
          ],
        ));
  }
}
