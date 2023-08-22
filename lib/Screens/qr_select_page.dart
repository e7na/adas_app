import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:samsung_ui_scroll_effect/samsung_ui_scroll_effect.dart';
import 'package:adas/Cubit/ble_cubit.dart';
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
    return BlocBuilder<BleCubit, BleState>(
      builder: (context, state) {
        C.theme = Theme.of(context).colorScheme;
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
            padding: EdgeInsets.only(left: 40.0, right: 50.0, top: C.lang == "ar" ? 6 : 0),
            child: Row(
              children: [
                Text("Share".tr(), style: const TextStyle(fontSize: 24)),
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
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    children: [
                      ListView.builder(
                          padding: EdgeInsets.zero,
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: C.finalDevices.length,
                          itemBuilder: (context, index) {
                            return ListTile(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => QRGeneratePage(
                                            deviceID: C.finalDevices[index].id,
                                          )),
                                );
                              },
                              title: Text(
                                C.finalDevices[index].name == ""
                                    ? "No Name".tr()
                                    : C.finalDevices[index].name,
                                style: const TextStyle(fontWeight: FontWeight.w600),
                              ),
                              subtitle: Text(C.finalDevices[index].id),
                            );
                          }),
                    ],
                  ),
                )
              ],
            )
          ]));
}
