import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:samsung_ui_scroll_effect/samsung_ui_scroll_effect.dart';
import 'package:adas/Cubit/ble_cubit.dart';
import 'package:adas/Widgets/ble_tile.dart';
import 'package:adas/Data/Models/device_model.dart';
import 'ble_page.dart';
import 'settings_page.dart';
import 'setter_page.dart';

//This page is shown only once when the app is first started to select the cars devices.
class ScanPage extends StatelessWidget {
  const ScanPage({Key? key}) : super(key: key);

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
      appBar: AppBar(toolbarHeight: 0, automaticallyImplyLeading: false),
      body: SamsungUiScrollEffect(
          expandedTitle: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text("ScanTitle".tr(), style: const TextStyle(fontSize: 32)),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10),
                child: Text(C.scanStarted ? "T2".tr() : "T1".tr(),
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w400)),
              )
            ],
          ),
          collapsedTitle: Padding(
            padding: const EdgeInsets.only(right: 12.0, left: 0),
            child: Row(
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 40.0, right: 50.0),
                  child: Text("ScanTitle".tr(), style: const TextStyle(fontSize: 24)),
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
                    .push(MaterialPageRoute(builder: (context) => const SettingsPage())),
                icon: const Icon(
                  Icons.settings,
                ))
          ],
          children: [
            ListView(
                padding: EdgeInsets.zero,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  C.devices.isNotEmpty
                      ? ListView.builder(
                          padding: EdgeInsets.zero,
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: C.devices.length,
                          itemBuilder: (context, index) {
                            return BleTile(
                                device: BleDevice(
                                  name: C.devices[index].name,
                                  id: C.devices[index].id,
                                  uuids: C.devices[index].serviceUuids,
                                ),
                                rssi: C.devices[index].rssi,
                                index: index);
                          })
                      : SizedBox(
                          height: 350,
                          child: Center(
                              child: Text(
                            "Start Scan".tr(),
                            style: TextStyle(
                                color: C.brightness == Brightness.light
                                    ? C.theme.primary
                                    : Colors.white),
                          ))),
                ])
          ]),
      bottomNavigationBar: SizedBox(
        height: 60,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            SizedBox(
              width: 140,
              child: ElevatedButton(
                // start scan or stop it.
                onPressed: C.scanStarted
                    ? C.stopScan
                    : () {
                        C.requestPermissions().whenComplete(() => C.startScan());
                      },
                child: Icon(
                  C.scanStarted ? Icons.cancel : Icons.search,
                  color: C.theme.onSurfaceVariant,
                ),
              ),
            ),
            SizedBox(
              width: 140,
              child: ElevatedButton(
                // If a device is chosen, it is be enabled.
                onPressed: C.somethingChosen
                    ? () {
                        C.saveDevices().whenComplete(() => Navigator.of(context).pushReplacement(
                            MaterialPageRoute(builder: (context) => const BLEPage())));
                      }
                    : null,
                child: const Icon(
                  Icons.save,
                ),
              ),
            ),
          ],
        ),
      ));
}
