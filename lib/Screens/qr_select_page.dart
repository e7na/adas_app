import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:samsung_ui_scroll_effect/samsung_ui_scroll_effect.dart';
import 'package:blue/Bloc/ble_bloc.dart';
import 'qr_generate_page.dart';
import 'setter_page.dart';

class SelectQrPage extends StatefulWidget {
  const SelectQrPage({super.key});

  @override
  State<SelectQrPage> createState() => _SelectQrPageState();
}

class _SelectQrPageState extends State<SelectQrPage> {
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
          automaticallyImplyLeading: true,
          expandedTitle: Text("Select Device".tr(), style: const TextStyle(fontSize: 32)),
          collapsedTitle: Padding(
            padding: EdgeInsets.only(left: 40.0, right: 50.0, top: B.lang == "ar" ? 6 : 0),
            child: Row(
              children: [
                Text("Share".tr(), style: const TextStyle(fontSize: 24)),
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
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    children: [
                      ListView.builder(
                          padding: EdgeInsets.zero,
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: B.finalDevices.length,
                          itemBuilder: (context, index) {
                            return ListTile(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => QRGeneratePage(
                                            deviceID: B.finalDevices[index].id,
                                          )),
                                );
                              },
                              title: Text(
                                B.finalDevices[index].name == ""
                                    ? "No Name".tr()
                                    : B.finalDevices[index].name,
                                style: const TextStyle(fontWeight: FontWeight.w600),
                              ),
                              subtitle: Text(B.finalDevices[index].id),
                            );
                          }),
                    ],
                  ),
                )
              ],
            )
          ]));
}
