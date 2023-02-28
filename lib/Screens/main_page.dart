import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:samsung_ui_scroll_effect/samsung_ui_scroll_effect.dart';
import 'package:blue/Bloc/ble_bloc.dart';
import 'package:blue/Widgets/device_tile.dart';
import 'package:blue/Data/Models/device_model.dart';
import 'package:blue/Screens/settings_page.dart';
import 'package:blue/main.dart';

class MainPage extends StatefulWidget {
  const MainPage({Key? key}) : super(key: key);

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  bool loading = true;

  @override
  void initState() {
    super.initState();
    // get list of saved devices
    B.getDevices();
    //To get Rssi Values
    B.startScan();
    //Connect to devices on start up
    connect(B);
    // to get theme from context
    SchedulerBinding.instance.addPostFrameCallback((_) {
      B.theme = Theme.of(context).colorScheme;
      loading = false;
      B.themeChanged();
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<BleBloc, BleState>(
      listener: (context, state) {},
      builder: (context, state) {
        return loading
            ? const Center(child: CircularProgressIndicator())
            : ColoredBox(
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
        expandedTitle: Text("MainTitle".tr(), style: const TextStyle(fontSize: 32)),
        collapsedTitle: Padding(
          padding: const EdgeInsets.only(right: 12.0, left: 0),
          child: Row(
            children: [
              Text("MainTitle".tr(), style: const TextStyle(fontSize: 24)),
            ],
          ),
        ),
        backgroundColor: B.theme.background,
        elevation: 1,
        expandedHeight: 300,
        actions: [
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
                  dDevice.isNotEmpty ? rssi = dDevice.first.rssi : null;
                }
                return DeviceTile(
                    device: BleDevice(
                      name: B.finalDevices[index].name,
                      id: B.finalDevices[index].id,
                    ),
                    rssi: rssi,
                    status: deviceState ?? DeviceConnectionState.disconnected);
              }),
        ],
      ),
      bottomNavigationBar: SizedBox(
        height: 60,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            SizedBox(
              width: 140,
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
            // This will be to disconnect or to reconnect
            SizedBox(
              width: 140,
              child: ElevatedButton(
                onPressed: () => connect(B),
                child: Icon(
                  Icons.bluetooth_connected_rounded,
                  color: B.theme.primary,
                ),
              ),
            ),
          ],
        ),
      ));
}

connect(var B) async {
  for (BleDevice device in B.finalDevices) {
    B.connectToDevice(device);
  }
}
