import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:blue/Bloc/ble_bloc.dart';
import 'package:blue/Widgets/ble_tile.dart';
import 'package:blue/Data/Models/device_model.dart';
import 'package:blue/Screens/main_page.dart';

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
  B.primary = Theme.of(context).colorScheme.primary;
  B.surfaceVariant = Theme.of(context).colorScheme.surfaceVariant;
  B.background = Theme.of(context).colorScheme.background;

  return Scaffold(
      backgroundColor:
          B.brightness == Brightness.dark ? B.background : B.surfaceVariant.withOpacity(0.6),
      body: ListView(children: [
        const SizedBox(
          height: 40,
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Text(
            "ScanTitle".tr(),
            style: TextStyle(color: B.primary, fontSize: 30, fontWeight: FontWeight.w500),
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
                  return BleTile(
                      device: BleDevice(
                        name: B.devices[index].name,
                        id: B.devices[index].id,
                      ),
                      rssi: B.devices[index].rssi,
                      index: index);
                })
            : SizedBox(
                height: 500,
                child: Center(
                    child: Text(
                  "Start Scan".tr(),
                  style: TextStyle(color: B.primary),
                ))),
      ]),
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
                    : () {
                        B.requestPermissions().whenComplete(() => B.startScan());
                      },
                child: Icon(B.scanStarted ? Icons.cancel : Icons.search),
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
                child: const Icon(Icons.save),
              ),
            ),
          ],
        ),
      ));
}
