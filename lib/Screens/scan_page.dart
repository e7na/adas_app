import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:reactive_ble/Bloc/ble_bloc.dart';

import '../Widgets/BLETile.dart';

//This page is shown when scanning for BLE devices
class ScanPage extends StatefulWidget {
  const ScanPage({Key? key}) : super(key: key);

  @override
  State<ScanPage> createState() => _ScanPageState();
}

class _ScanPageState extends State<ScanPage> {
  @override
  Widget build(BuildContext context) {
    var brightness = SchedulerBinding.instance.window.platformBrightness;
    var theme =
        brightness == Brightness.dark ? Brightness.light : Brightness.dark;
    Color primary = Theme.of(context).colorScheme.primary;
    return AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: theme,
          // For Android (dark icons)
          statusBarBrightness: theme,
          // For iOS (dark icons)
          systemNavigationBarIconBrightness: theme,
          systemNavigationBarColor:
              Theme.of(context).colorScheme.surfaceVariant,
        ),
        child: BlocProvider(
          create: (context) => BleBloc(),
          child: BlocConsumer<BleBloc, BleState>(
            listener: (context, state) {},
            builder: (context, state) {
              var B = BleBloc.get(context);
              return ColoredBox(
                color: Colors.white,
                child: TheScaffold(
                  brightness: brightness,
                  primary: primary,
                  B: B,
                ),
              );
            },
          ),
        ));
  }
}

class TheScaffold extends StatelessWidget {
  const TheScaffold({
    super.key,
    required this.brightness,
    required this.primary,
    required this.B,
  });

  final Brightness brightness;
  final Color primary;
  final BleBloc B;

  @override
  Widget build(BuildContext context) {
    scaffoldMsg() {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("Enable Location Service First"),
      ));
    }

    return Scaffold(
        backgroundColor: brightness == Brightness.dark
            ? Theme.of(context).colorScheme.background
            : Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.6),
        body: ListView(children: [
          const SizedBox(
            height: 40,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Text(
              "Title".tr(),
              style: TextStyle(
                  color: primary, fontSize: 30, fontWeight: FontWeight.w500),
            ),
          ),
          ListTile(
            title: Text(
              B.scanStarted ? "T2".tr() : "T1".tr(),
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w400),
            ),
          ),
          B.devices.isNotEmpty
              ? ListView.builder(
                  padding: EdgeInsets.zero,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: B.devices.length,
                  itemBuilder: (context, index) {
                    return bleTile(B.devices[index].name, B.devices[index].id,
                        B.devices[index].rssi, primary);
                  })
              : SizedBox(
                  height: 500,
                  child: Center(
                      child: Text(
                    "Scan Not Started",
                    style: TextStyle(color: primary),
                  ))),
        ]),
        bottomNavigationBar: Container(
          color: Theme.of(context).colorScheme.surfaceVariant,
          height: 60,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              SizedBox(
                width: 100,
                child: ElevatedButton(
                  // start scan or stop it.
                  onPressed: B.scanStarted
                      ? B.stopScan
                      : () async {
                          await B.checkPermissions();
                          if (B.locationService == false) {
                            scaffoldMsg();
                          } else {
                            B.startBlue();
                            B.startScan();
                          }
                        },
                  child: Icon(B.scanStarted ? Icons.cancel : Icons.search),
                ),
              ),
              SizedBox(
                width: 100,
                child: ElevatedButton(
                  // If the scan HAS started, it should be disabled.
                  onPressed:
                      B.foundDeviceWaitingToConnect ? B.connectToDevice : null,
                  child: const Icon(Icons.save),
                ),
              ),
              // This would be for what we want to do after connecting
              SizedBox(
                width: 100,
                child: ElevatedButton(
                  onPressed: B.connected ? () {} : null,
                  child: const Icon(Icons.arrow_forward),
                ),
              ),
            ],
          ),
        ));
  }
}
