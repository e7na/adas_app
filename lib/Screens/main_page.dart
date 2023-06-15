import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:samsung_ui_scroll_effect/samsung_ui_scroll_effect.dart';
import 'package:blue/Bloc/ble_bloc.dart';
import 'scan_page.dart';
import 'setter_page.dart';
import 'settings_page.dart';
import 'ble_page.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  late int numDevices;
  @override
  void initState() {
    // get the number of saved devices
    numDevices = B.box.get('NumDevices') ?? 0;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<BleBloc, BleState>(
      listener: (context, state) {},
      builder: (context, state) {
        B.theme = Theme.of(context).colorScheme;
        return ColoredBox(
          color: Colors.white,
          child: theScaffold(
            context: context,
            numDevices: numDevices,
          ),
        );
      },
    );
  }
}

Widget theScaffold({required BuildContext context, numDevices}) {
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
        backgroundColor:
            B.brightness == Brightness.light ? B.theme.background : B.theme.surfaceVariant,
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
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ElevatedButton(
                      onPressed: () => Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) =>
                              numDevices > 0 ? const BLEPage() : const ScanPage())),
                      style: ElevatedButton.styleFrom(minimumSize: const Size(400, 50)),
                      child: const Text("BLE")),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ElevatedButton(
                      onPressed: () => Navigator.of(context).push(
                          MaterialPageRoute(builder: (context) => const MainPage())),
                      style: ElevatedButton.styleFrom(minimumSize: const Size(400, 50)),
                      child: const Text("Websocket")),
                )
              ],
            ),
          )
        ]),
  );
}
