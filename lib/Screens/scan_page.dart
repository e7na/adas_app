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
    //Color fontColor = Theme.of(context).colorScheme.onBackground;
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
                child: Scaffold(
                    backgroundColor: brightness == Brightness.dark
                        ? Theme.of(context).colorScheme.background
                        : Theme.of(context)
                            .colorScheme
                            .surfaceVariant
                            .withOpacity(0.6),
                    body: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(
                            height: 40,
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16.0, vertical: 20),
                            child: Text(
                              "Title".tr(),
                              style: const TextStyle(
                                  fontSize: 30, fontWeight: FontWeight.w500),
                            ),
                          ),
                          ListTile(
                            title: Text(
                              "T1".tr(),
                              style:
                                  const TextStyle(fontWeight: FontWeight.w400),
                            ),
                          ),
                          B.devices.isNotEmpty ? bleTile(B.devices.first.name, B.devices.first.id, B.devices.first.rssi): Container(),
                        ]),
                    bottomSheet: Container(
                      color: Theme.of(context).colorScheme.surfaceVariant,
                      height: 60,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          SizedBox(
                            width: 100,
                            child: ElevatedButton(
                              // If the scan HAS started, it should be disabled.
                              onPressed:
                                  B.scanStarted ? B.stopScan : B.startScan,
                              child: Icon(
                                  B.scanStarted ? Icons.cancel : Icons.search),
                            ),
                          ),
                          SizedBox(
                            width: 100,
                            child: ElevatedButton(
                              // If the scan HAS started, it should be disabled.
                              onPressed: B.foundDeviceWaitingToConnect
                                  ? B.connectToDevice
                                  : null,
                              child: const Icon(Icons.bluetooth),
                            ),
                          ),
                          // This would be for what we want to do after connecting
                          SizedBox(
                            width: 100,
                            child: ElevatedButton(
                              onPressed: B.connected ? () {} : null,
                              child: const Icon(Icons.question_mark_rounded),
                            ),
                          ),
                        ],
                      ),
                    )),
              );
            },
          ),
        ));
  }
}
