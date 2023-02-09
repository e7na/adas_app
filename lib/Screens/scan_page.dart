import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:blue/Bloc/ble_bloc.dart';
import 'package:blue/Widgets/ble_tile.dart';

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
  Color primary = Theme.of(context).colorScheme.primary;
  Color surfaceVariant = Theme.of(context).colorScheme.surfaceVariant;
  scaffoldMsg() {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(
        "Enable Location Service First",
        style: TextStyle(color: primary),
      ),
      backgroundColor: surfaceVariant,
    ));
  }

  return Scaffold(
      backgroundColor: B.brightness == Brightness.dark
          ? Theme.of(context).colorScheme.background
          : surfaceVariant.withOpacity(0.6),
      body: ListView(children: [
        const SizedBox(
          height: 40,
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Text(
            "ScanTitle".tr(),
            style: TextStyle(color: primary, fontSize: 30, fontWeight: FontWeight.w500),
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
                      name: B.devices[index].name,
                      uuid: B.devices[index].id,
                      rssi: B.devices[index].rssi,
                      color: primary,
                      index: index);
                })
            : SizedBox(
                height: 500,
                child: Center(
                    child: Text(
                  "Start Scan".tr(),
                  style: TextStyle(color: primary),
                ))),
      ]),
      bottomNavigationBar: Container(
        color: surfaceVariant,
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
                        if (B.locationService == false) {
                          scaffoldMsg();
                        } else {
                          B.startScan();
                        }
                      },
                child: Icon(B.scanStarted ? Icons.cancel : Icons.search),
              ),
            ),
            SizedBox(
              width: 140,
              child: ElevatedButton(
                // If a device is chosen, it is be enabled.
                onPressed: B.somethingChosen ? B.saveDevices : null,
                child: const Icon(Icons.save),
              ),
            ),
          ],
        ),
      ));
}
