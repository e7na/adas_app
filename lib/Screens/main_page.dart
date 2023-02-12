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
  B.primary = Theme.of(context).colorScheme.primary;
  B.surfaceVariant = Theme.of(context).colorScheme.surfaceVariant;
  B.background = Theme.of(context).colorScheme.background;

  return Scaffold(
      backgroundColor:
          B.brightness == Brightness.dark ? B.background : B.surfaceVariant.withOpacity(0.6),
      body: ListView(
        children: [
          const SizedBox(
            height: 30,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  height: 48,
                  child: Text(
                    "MainTitle".tr(),
                    style: TextStyle(color: B.primary, fontSize: 30, fontWeight: FontWeight.w500),
                  ),
                ),
                IconButton(
                    onPressed: () => Navigator.of(context)
                        .push(MaterialPageRoute(builder: (context) => const SettingsPage())),
                    icon: Icon(
                      Icons.settings,
                      color: B.primary,
                    ))
              ],
            ),
          ),
          ListView.builder(
              padding: EdgeInsets.zero,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: B.finalDevices.length,
              itemBuilder: (context, index) {
                int rssi = 0;
                DeviceConnectionState? deviceState;
                if (B.finalDevicesStates.length > index) {
                  deviceState = B.finalDevicesStates[index];
                }
                if (B.scanStarted) {
                  Iterable<DiscoveredDevice> dDevice =
                      B.devices.where((d) => d.id == B.finalDevices[index].id);
                  dDevice.isNotEmpty ? rssi = dDevice.first.rssi : null;
                }
                //ToDo: Change This
                B.connectToDevice(index);
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
      bottomNavigationBar: Container(
        color: B.surfaceVariant,
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
                        await B.requestPermissions();
                        B.startScan();
                      },
                child: Icon(B.scanStarted ? Icons.cancel : Icons.search),
              ),
            ),
            // This will be to disconnect or to reconnect
            const SizedBox(
              width: 140,
              child: ElevatedButton(
                onPressed: null,
                child: Icon(Icons.refresh),
              ),
            ),
          ],
        ),
      ));
}
