import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:samsung_ui_scroll_effect/samsung_ui_scroll_effect.dart';
import 'package:adas/Cubit/ble_cubit.dart';
import 'package:adas/Widgets/device_tile.dart';
import 'settings_page.dart';
import 'setter_page.dart';
import 'share_page.dart';

class BLEPage extends StatefulWidget {
  const BLEPage({Key? key}) : super(key: key);

  @override
  State<BLEPage> createState() => _BLEPageState();
}

class _BLEPageState extends State<BLEPage> {
  @override
  void initState() {
    super.initState();
    // get list of saved devices
    C.getDevices();
    //To get Rssi Values
    C.startScan();
    //Connect to devices on start up
    // connect(B);
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BleCubit, BleState>(
      builder: (context, state) {
        C.theme = Theme.of(context).colorScheme;
        return ColoredBox(
          color: Colors.white,
          child: theScaffold(
            context: context,
          ),
        );
      },
    );
  }
}

Widget theScaffold({
  required BuildContext context,
}) {
  return Scaffold(
      appBar: AppBar(toolbarHeight: 0),
      body: SamsungUiScrollEffect(
        expandedTitle: Text("BleTitle".tr(), style: const TextStyle(fontSize: 32)),
        collapsedTitle: Padding(
          padding: const EdgeInsets.only(right: 12.0, left: 0),
          child: Row(
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 40.0, right: 50.0),
                child: Text("BleTitle".tr(), style: const TextStyle(fontSize: 24)),
              ),
            ],
          ),
        ),
        automaticallyImplyLeading: true,
        backgroundColor:
            C.brightness == Brightness.light ? C.theme.background : C.theme.surfaceVariant,
        elevation: 1,
        expandedHeight: 300,
        actions: [
          IconButton(
              onPressed: () => Navigator.of(context)
                  .push(MaterialPageRoute(builder: (context) => const SharePage())),
              icon: const Icon(
                Icons.share,
              )),
          IconButton(
              onPressed: () => Navigator.of(context)
                  .push(MaterialPageRoute(builder: (context) => const SettingsPage())),
              icon: const Icon(
                Icons.settings,
              ))
        ],
        children: [
          ListView.builder(
              padding: EdgeInsets.zero,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: C.finalDevices.length,
              itemBuilder: (context, index) {
                int rssi = 0;
                DeviceConnectionState? deviceState;
                if (C.finalDevicesStates.length > index) {
                  deviceState = C.finalDevicesStates[C.finalDevices[index].id];
                }
                if (C.scanStarted) {
                  Iterable<DiscoveredDevice> dDevice =
                      C.devices.where((d) => d.id == C.finalDevices[index].id);
                  dDevice.isNotEmpty
                      ? rssi = dDevice.first.rssi != 0
                          ? C.averageRssi(rssi: dDevice.first.rssi, id: C.finalDevices[index].id)
                          : 0
                      : 0;
                }
                return DeviceTile(
                  device: C.finalDevices[index],
                  rssi: rssi,
                  distance: C.calculateDistance(rssi: rssi),
                  status: deviceState ?? DeviceConnectionState.disconnected,
                  C: C,
                );
              }),
        ],
      ),
      bottomNavigationBar: SizedBox(
        height: 60,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12.0),
                child: ElevatedButton(
                  // start scan or stop it.
                  onPressed: C.scanStarted
                      ? C.stopScan
                      : () async {
                          C.startScan();
                        },
                  child: Icon(
                    C.scanStarted ? Icons.cancel : Icons.location_on,
                    color: C.theme.onSurfaceVariant,
                  ),
                ),
              ),
            ),
          ],
        ),
      ));
}
