import 'package:flutter/material.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:adas/Data/Models/device_model.dart';
import 'package:adas/Bloc/ble_bloc.dart';

class DeviceTile extends StatelessWidget {
  final BleDevice device;
  final int rssi;
  final String distance;
  final DeviceConnectionState status;
  final BleBloc B;

  const DeviceTile(
      {Key? key,
      required this.device,
      required this.rssi,
      required this.distance,
      required this.status,
      required this.B})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    String statusString = "$status".split(".")[1].toUpperCase();
    String authString = B.finalDevicesAuthStates[device.id];
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
            statusString == "CONNECTED"
                ? const SizedBox()
                : ListTile(
                    title: Text("RSSI".tr()),
                    trailing: Text(
                      rssi == 0 ? "Not Found".tr() : "$rssi",
                      style: data,
                    )),
            statusString == "CONNECTED"
                ? const SizedBox()
                : ListTile(
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
                )),
            statusString != "CONNECTED"
                ? const SizedBox()
                : ListTile(
                    title: Text("AUTH".tr()),
                    subtitle: Text(
                      authString.toUpperCase().tr(),
                      style: TextStyle(
                          fontSize: 16, color: getAuthsColor(theme: theme, authString: authString)),
                    ),
                    trailing: ElevatedButton(
                        onPressed:() => B.sendKey(device),
                        child: Text("AUTHORIZE".tr()))),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  statusString != "CONNECTED"
                      ? const SizedBox()
                      : Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 4.0),
                            child: ElevatedButton(
                                onPressed: authString == "unauthorized"
                                    ? null
                                    : () => B.controlDoors(device),
                                child: Text(B.unlockDoors ? "lock Doors" : "Unlock Doors").tr()),
                          ),
                        ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4.0),
                      child: ElevatedButton(
                          onPressed: statusString == "DISCONNECTED"
                              ? () => B.connectToDevice(device)
                              : () => B.disconnectDevice(device),
                          child:
                              Text(statusString == "DISCONNECTED" ? "CONNECT" : "DISCONNECT").tr()),
                    ),
                  ),
                ],
              ),
            )
          ],
        ));
  }
}

Color getStatusColor({required statusString, required ColorScheme theme}) {
  Color color;
  if (statusString == "DISCONNECTED") {
    color = theme.error;
  } else if (statusString == "CONNECTED") {
    color = theme.primary;
  } else {
    color = theme.onBackground;
  }
  return color;
}

Color getAuthsColor({required authString, required ColorScheme theme}) {
  Color color;
  if (authString == "unauthorized") {
    color = theme.error;
  } else {
    color = theme.primary;
  }
  return color;
}
