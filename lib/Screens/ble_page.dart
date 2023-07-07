import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:samsung_ui_scroll_effect/samsung_ui_scroll_effect.dart';
import 'package:blue/Bloc/ble_bloc.dart';
import 'package:blue/Widgets/device_tile.dart';
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
    B.getDevices();
    //To get Rssi Values
    B.startScan();
    //Connect to devices on start up
    // connect(B);
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<BleBloc, BleState>(
      listener: (context, state) {},
      builder: (context, state) {
        B.theme = Theme.of(context).colorScheme;
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
            B.brightness == Brightness.light ? B.theme.background : B.theme.surfaceVariant,
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
              itemCount: B.finalDevices.length,
              itemBuilder: (context, index) {
                int rssi = 0;
                DeviceConnectionState? deviceState;
                if (B.finalDevicesStates.length > index) {
                  deviceState = B.finalDevicesStates[B.finalDevices[index].id];
                }
                if (B.scanStarted) {
                  Iterable<DiscoveredDevice> dDevice =
                      B.devices.where((d) => d.id == B.finalDevices[index].id);
                  dDevice.isNotEmpty
                      ? rssi = dDevice.first.rssi != 0
                          ? B.averageRssi(rssi: dDevice.first.rssi, id: B.finalDevices[index].id)
                          : 0
                      : 0;
                }
                return DeviceTile(
                  device: B.finalDevices[index],
                  rssi: rssi,
                  distance: B.calculateDistance(rssi: rssi),
                  status: deviceState ?? DeviceConnectionState.disconnected,
                  B: B,
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
                  onPressed: B.scanStarted
                      ? B.stopScan
                      : () async {
                          B.startScan();
                        },
                  child: Icon(
                    B.scanStarted ? Icons.cancel : Icons.location_on,
                    color: B.theme.onSurfaceVariant,
                  ),
                ),
              ),
            ),
          ],
        ),
      ));
}
