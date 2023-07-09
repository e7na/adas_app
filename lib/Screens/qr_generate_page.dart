import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:adas/Screens/setter_page.dart';

class QRGeneratePage extends StatelessWidget {
  final String deviceID;
  const QRGeneratePage({super.key, required this.deviceID});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('QR Generator').tr()),
      body: Center(
        child: QrImageView(
          data: "$deviceID||${B.keys[deviceID].base64}|||${B.ivs[deviceID].base64}",
          version: QrVersions.auto,
          size: 300.0,
          backgroundColor: Colors.white,
        ),
      ),
    );
  }
}
