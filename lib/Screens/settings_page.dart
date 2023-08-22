import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:samsung_ui_scroll_effect/samsung_ui_scroll_effect.dart';
import 'package:adas/Widgets/theme_popup_menu.dart';
import 'package:adas/Cubit/ble_cubit.dart';
import 'scan_page.dart';
import 'setter_page.dart';

late String _currentLang;
List<String> _lang = ["English", "Arabic"];

class SettingsPage extends StatelessWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BleCubit, BleState>(
      builder: (context, state) {
        C.theme = Theme.of(context).colorScheme;
        _currentLang = context.locale.toString();
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
          automaticallyImplyLeading: true,
          expandedTitle: Text("SettingsTitle".tr(), style: const TextStyle(fontSize: 32)),
          collapsedTitle: Padding(
            padding: EdgeInsets.only(left: 40.0, right: 50.0, top: C.lang == "ar" ? 6 : 0),
            child: Row(
              children: [
                Text("SettingsTitle".tr(), style: const TextStyle(fontSize: 24)),
              ],
            ),
          ),
          backgroundColor:
              C.brightness == Brightness.light ? C.theme.background : C.theme.surfaceVariant,
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
                  child: ListTile(
                    title: Text(
                      "Language".tr(),
                    ),
                    subtitle: Text(
                      "sLanguage".tr(),
                    ),
                    trailing: DropdownButton(
                      iconSize: 20,
                      padding: const EdgeInsets.all(8),
                      borderRadius: BorderRadius.circular(10),
                      alignment: Alignment.center,
                      underline: Container(),
                      elevation: 0,
                      isDense: true,
                      value: _currentLang == 'en' ? 'English' : 'Arabic',
                      icon: const Icon(Icons.keyboard_arrow_down),
                      items: _lang.map((String items) {
                        return DropdownMenuItem(value: items, child: Text(items).tr());
                      }).toList(),
                      onChanged: (String? newValue) {
                        newValue == "English" ? _currentLang = 'en' : _currentLang = 'ar';
                        context.setLocale(Locale(_currentLang));
                        C.stateChanged();
                      },
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 20),
                  child: ThemePopupMenu(
                    schemeIndex: C.themeController.schemeIndex,
                    onChanged: (value) {
                      C.themeController.setSchemeIndex(value);
                      C.themeChanged();
                    },
                  ),
                ),
                Padding(
                    padding: const EdgeInsets.only(bottom: 20.0),
                    child: SwitchListTile(
                      title: Text("Dynamic Colors".tr()),
                      subtitle: Text("T4".tr()),
                      value: C.box.get("isDynamic") ?? false,
                      onChanged: (bool value) {
                        C.box.put("isDynamic", value);
                        C.themeChanged();
                      },
                    )),
                C.finalDevices.isEmpty
                    ? Container()
                    : Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 60.0),
                        child: ElevatedButton(
                            onPressed: () => {
                                  C.chosenDevices.clear(),
                                  C.finalDevices.clear(),
                                  C.box.put('NumDevices', 0),
                                  C.box.put("IDs", ""),
                                  C.box.put("Names", ""),
                                  C.box.put("Uuids", ""),
                                  C.stopScan(),
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
