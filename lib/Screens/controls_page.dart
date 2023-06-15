import 'package:blue/Screens/setter_page.dart';
import 'package:blue/Screens/settings_page.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:samsung_ui_scroll_effect/samsung_ui_scroll_effect.dart';

TextEditingController _ipController = TextEditingController();
TextEditingController _portController = TextEditingController();

class ControlPage extends StatefulWidget {
  const ControlPage({super.key});

  @override
  State<ControlPage> createState() => _ControlPageState();
}

class _ControlPageState extends State<ControlPage> {
  @override
  void initState() {
    _ipController.text = "192.168.1.1";
    _portController.text = "8080";
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return theScaffold(context: context);
  }
}

Widget theScaffold({required BuildContext context, numDevices}) {
  return Scaffold(
    appBar: AppBar(toolbarHeight: 0),
    body: SamsungUiScrollEffect(
        expandedTitle: Text("ControlTitle".tr(), style: const TextStyle(fontSize: 32)),
        collapsedTitle: Padding(
          padding: const EdgeInsets.only(right: 12.0, left: 0),
          child: Row(
            children: [
              Text(
                "ControlTitle".tr(),
                style: const TextStyle(fontSize: 24),
              ),
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
                Row(
                  children: [
                    SizedBox(
                      width: 160,
                      child: TextField(
                        controller: _ipController,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: SizedBox(
                        width: 80,
                        child: TextField(
                          controller: _portController,
                        ),
                      ),
                    ),
                    FittedBox(
                      child: ElevatedButton(
                        onPressed: () {
                          print("Connect to ${_ipController.text}:${_portController.text}");
                        },
                        child: const Text("Connect"),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          )
        ]),
  );
}
