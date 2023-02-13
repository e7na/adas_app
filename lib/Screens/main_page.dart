import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:blue/Bloc/ble_bloc.dart';
import 'package:blue/Widgets/device_tile.dart';
import 'package:blue/Data/Models/device_model.dart';
import 'package:blue/Screens/settings_page.dart';

class MainPage extends StatefulWidget {
  const MainPage({Key? key}) : super(key: key);

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  @override
  void initState() {
    super.initState();
    BleBloc.get(context).getDevices();
    //To get Rssi Values
    BleBloc.get(context).startScan();
  }

  @override
  Widget build(BuildContext context) {
    connect(BleBloc.get(context));
    return BlocConsumer<BleBloc, BleState>(
      listener: (context, state) {},
      builder: (context, state) {
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
  var B = BleBloc.get(context);
  ColorScheme theme = Theme.of(context).colorScheme;
  B.theme = theme;
  return Scaffold(
      appBar: AppBar(
        title: Text(
          "MainTitle".tr(),
        ),
        actions: [
          IconButton(
              onPressed: () => Navigator.of(context)
                  .push(MaterialPageRoute(builder: (context) => const SettingsPage())),
              icon: const Icon(
                Icons.settings,
              ))
        ],
      ),
      body: ListView(
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
            // This will be to disconnect or to reconnect
            SizedBox(
              width: 140,
              child: ElevatedButton(
                onPressed: () => connect(B),
                child: Icon(
                  Icons.refresh,
                  color: theme.onSurfaceVariant,
                ),
              ),
            ),
            SizedBox(
              width: 140,
              child: ElevatedButton(
                // start scan or stop it.
                onPressed: B.scanStarted
                    ? B.stopScan
                    : () async {
                        await B.requestPermissions();
                        B.startScan();
                      },
                child: Icon(
                  B.scanStarted ? Icons.cancel : Icons.search,
                  color: theme.onSurfaceVariant,
                ),
              ),
            ),
          ],
        ),
      ));
}

connect(var B) async {
  await Future.delayed(const Duration(seconds: 5));
  for (BleDevice device in B.finalDevices) {
    B.connectToDevice(device);
  }
}
