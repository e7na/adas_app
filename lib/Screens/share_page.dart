import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:samsung_ui_scroll_effect/samsung_ui_scroll_effect.dart';
import 'package:blue/Bloc/ble_bloc.dart';
import 'qr_generate_page.dart';
import 'qr_scan_page.dart';
import 'setter_page.dart';

class SharePage extends StatefulWidget {
  const SharePage({super.key});

  @override
  State<SharePage> createState() => _SharePageState();
}

class _SharePageState extends State<SharePage> {
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
          expandedTitle: Text("Share".tr(), style: const TextStyle(fontSize: 32)),
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
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: ElevatedButton(
                            onPressed: () => Navigator.of(context).push(
                                MaterialPageRoute(builder: (context) => const QRGeneratePage())),
                            style: ElevatedButton.styleFrom(minimumSize: const Size(400, 50)),
                            child: const Text("Share QR").tr()),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: ElevatedButton(
                            onPressed: () => Navigator.of(context)
                                .push(MaterialPageRoute(builder: (context) => const ScanQrPage())),
                            style: ElevatedButton.styleFrom(minimumSize: const Size(400, 50)),
                            child: const Text("Scan QR").tr()),
                      ),
                    ],
                  ),
                )
              ],
            )
          ]));
}
