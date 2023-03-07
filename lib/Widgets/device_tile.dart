import 'package:flutter/material.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:blue/Data/Models/device_model.dart';

class DeviceTile extends StatelessWidget {
  final BleDevice device;
  final int rssi;
  final String distance;
  final DeviceConnectionState status;

  const DeviceTile({Key? key, required this.device, required this.rssi, required this.distance, required this.status})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    String statusString = "$status".split(".")[1].toUpperCase();
    ColorScheme theme = Theme.of(context).colorScheme;
    TextStyle data = TextStyle(fontWeight: FontWeight.w400, fontSize: 16, color: theme.primary);
    return Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          initiallyExpanded: true,
          title: Text(
            device.name == "" ? "No Name".tr() : device.name,
          ),
          children: [
            ListTile(
                title: Text("ID".tr()),
                trailing: Text(
                  device.id,
                  style: data,
                )),
            ListTile(
                title: Text("RSSI".tr()),
                trailing: Text(
                  rssi == 0 ? "Not Found".tr() : "$rssi",
                  style: data,
                )),
            ListTile(
                title: Text("DISTANCE".tr()),
                trailing: Text(
                  rssi == 0 ? "Not Calculated".tr() : "$distance ${"M".tr()}",
                  style: data,
                )),
            ListTile(
                title: Text("STATUS".tr()),
                trailing: Text(
                  statusString.tr(),
                  style: TextStyle(
                      fontSize: 16,
                      color: getStatusColor(theme: theme, statusString: statusString)),
                ))
          ],
        ));
  }
}

Color getStatusColor({required statusString, required ColorScheme theme}) {
  Color color;
  if (statusString == "disconnected".toUpperCase()) {
    color = theme.error;
  } else if (statusString == "connected".toUpperCase()) {
    color = theme.primary;
  } else {
    color = theme.onBackground;
  }
  return color;
}
