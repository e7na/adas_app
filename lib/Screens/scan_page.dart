import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:blue/Bloc/ble_bloc.dart';
import 'package:blue/Widgets/ble_tile.dart';
import 'package:blue/Data/Models/device_model.dart';
import 'package:blue/Screens/main_page.dart';
import 'package:samsung_ui_scroll_effect/samsung_ui_scroll_effect.dart';

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
  var B = BleBloc.get(context);
  ColorScheme theme = Theme.of(context).colorScheme;
  B.theme = theme;

  return Scaffold(
      appBar: AppBar(toolbarHeight: 0, automaticallyImplyLeading: false),
      body: SamsungUiScrollEffect(
          expandedTitle: Text("ScanTitle".tr(), style: const TextStyle(fontSize: 32)),
          collapsedTitle: Text("ScanTitle".tr(), style: const TextStyle(fontSize: 24)),
          backgroundColor: theme.background,
          elevation: 1,
          expandedHeight: 300,
          children: [
            ListView(
                padding: EdgeInsets.zero,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: ListTile(
                      title: Text(
                        B.scanStarted ? "T2".tr() : "T1".tr(),
                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w400),
                      ),
                    ),
                  ),
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
                            style: TextStyle(color: theme.primary),
                          ))),
                ])
          ]),
      bottomNavigationBar: Container(
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
                  color: theme.onSurfaceVariant,
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
