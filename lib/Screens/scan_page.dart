import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:samsung_ui_scroll_effect/samsung_ui_scroll_effect.dart';
import 'package:blue/Bloc/ble_bloc.dart';
import 'package:blue/Widgets/ble_tile.dart';
import 'package:blue/Data/Models/device_model.dart';
import 'main_page.dart';
import 'settings_page.dart';
import 'setter_page.dart';

//This page is shown only once when the app is first started to select the cars devices.
class ScanPage extends StatelessWidget {
  const ScanPage({Key? key}) : super(key: key);

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
  return Scaffold(
      appBar: AppBar(toolbarHeight: 0, automaticallyImplyLeading: false),
      body: SamsungUiScrollEffect(
          expandedTitle: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text("ScanTitle".tr(), style: const TextStyle(fontSize: 32)),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10),
                child: Text(B.scanStarted ? "T2".tr() : "T1".tr(),
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w400)),
              )
            ],
          ),
          collapsedTitle: Padding(
            padding: const EdgeInsets.only(right: 12.0, left: 0),
            child: Row(
              children: [
                Text("ScanTitle".tr(), style: const TextStyle(fontSize: 24)),
              ],
            ),
          ),
          backgroundColor: Theme.of(context).colorScheme.background,
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
                  B.devices.isNotEmpty
                      ? ListView.builder(
                          padding: EdgeInsets.zero,
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: B.devices.length,
                          itemBuilder: (context, index) {
                            return BleTile(
                                device: BleDevice(
                                  name: B.devices[index].name,
                                  id: B.devices[index].id,
                                ),
                                rssi: B.devices[index].rssi,
                                index: index);
                          })
                      : SizedBox(
                          height: 350,
                          child: Center(
                              child: Text(
                            "Start Scan".tr(),
                            style: TextStyle(color: B.theme.primary),
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
                onPressed: B.scanStarted
                    ? B.stopScan
                    : () {
                        B.requestPermissions().whenComplete(() => B.startScan());
                      },
                child: Icon(
                  B.scanStarted ? Icons.cancel : Icons.search,
                  color: B.theme.onSurfaceVariant,
                ),
              ),
            ),
            SizedBox(
              width: 140,
              child: ElevatedButton(
                // If a device is chosen, it is be enabled.
                onPressed: B.somethingChosen
                    ? () {
                        B.saveDevices().whenComplete(() => Navigator.of(context).pushReplacement(
                            MaterialPageRoute(builder: (context) => const MainPage())));
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
