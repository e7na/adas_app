import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:samsung_ui_scroll_effect/samsung_ui_scroll_effect.dart';
import 'package:blue/Widgets/theme_popup_menu.dart';
import 'package:blue/Bloc/ble_bloc.dart';
import 'scan_page.dart';
import 'setter_page.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({Key? key}) : super(key: key);

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
      appBar: AppBar(toolbarHeight: 0),
      body: SamsungUiScrollEffect(
          expandedTitle: Text("SettingsTitle".tr(), style: const TextStyle(fontSize: 32)),
          collapsedTitle: Padding(
            padding: EdgeInsets.only(left: 40.0, right: 50.0, top: B.lang == "ar" ? 6 : 0),
            child: Row(
              children: [
                Text("SettingsTitle".tr(), style: const TextStyle(fontSize: 24)),
              ],
            ),
          ),
          backgroundColor:
              B.brightness == Brightness.light ? B.theme.background : B.theme.surfaceVariant,
          elevation: 1,
          expandedHeight: 300,
          children: [
            ListView(
              padding: EdgeInsets.zero,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 20.0),
                  child: ThemePopupMenu(
                    schemeIndex: B.themeController.schemeIndex,
                    onChanged: (value) {
                      B.themeController.setSchemeIndex(value);
                      B.themeChanged();
                    },
                  ),
                ),
                Padding(
                    padding: const EdgeInsets.only(bottom: 20.0),
                    child: SwitchListTile(
                      title: Text("Dynamic Colors".tr()),
                      subtitle: Text("T4".tr()),
                      value: B.box.get("isDynamic") ?? false,
                      onChanged: (bool value) {
                        B.box.put("isDynamic", value);
                        B.themeChanged();
                      },
                    )),
                B.finalDevices.isEmpty
                    ? Container()
                    : Padding(
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
