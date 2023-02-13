import 'package:blue/Bloc/ble_bloc.dart';
import 'package:blue/Screens/scan_page.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:samsung_ui_scroll_effect/samsung_ui_scroll_effect.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({Key? key}) : super(key: key);

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

  return Scaffold(
      appBar: AppBar(toolbarHeight: 0),
      body: SamsungUiScrollEffect(
          expandedTitle: Text("SettingsTitle".tr(), style: const TextStyle(fontSize: 32)),
          collapsedTitle: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40.0),
            child: Text("SettingsTitle".tr(), style: const TextStyle(fontSize: 24)),
          ),
          backgroundColor: theme.background,
          elevation: 1,
          expandedHeight: 300,
          children: [
            ListView(
              padding: EdgeInsets.zero,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                const SizedBox(
                  height: 20,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 60.0),
                  child: ElevatedButton(
                      onPressed: () => {
                            B.chosenDevices = [],
                            Navigator.of(context).pop(),
                            Navigator.of(context).pushReplacement(
                                MaterialPageRoute(builder: (context) => const ScanPage()))
                          },
                      child: Text("Reset Devices".tr())),
                ),
              ],
            )
          ]));
}
