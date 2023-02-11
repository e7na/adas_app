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
    String statusString = "$status".split(".")[1].toUpperCase();
    Color primary = Theme.of(context).colorScheme.primary;
    TextStyle data = TextStyle(fontWeight: FontWeight.w400, fontSize: 16, color: primary);
    return Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          initiallyExpanded: true,
          title: Text(
            device.name,
          ),
          children: [
            ListTile(
                title: const Text("ID"),
                trailing: Text(
                  device.id,
                  style: data,
                )),
            ListTile(
                title: const Text("RSSI"),
                trailing: Text(
                  rssi == 0 ? "Not Found" : "$rssi",
                  style: data,
                )),
            ListTile(
                title: const Text("STATUS"),
                trailing: Text(
                  statusString,
                  style: TextStyle(
                      fontSize: 16,
                      color: getStatusColor(context: context, statusString: statusString)),
                ))
          ],
        ));
  }
}

Color getStatusColor({required statusString, required context}) {
  Color color;
  if (statusString == "disconnected".toUpperCase()) {
    color = Theme.of(context).colorScheme.error;
  } else if (statusString == "connected".toUpperCase()) {
    color = Theme.of(context).colorScheme.primary;
  } else {
    color = Theme.of(context).colorScheme.onBackground;
  }
  return color;
}
