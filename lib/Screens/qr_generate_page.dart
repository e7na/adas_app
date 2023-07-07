import 'package:blue/Screens/setter_page.dart';
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

class QRGeneratePage extends StatelessWidget {
  const QRGeneratePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('QR Generator')),
      body: Center(
        child: QrImageView(
          data: "${B.key.base64}||${B.iv.base64}",
          version: QrVersions.auto,
          size: 300.0,
          backgroundColor: Colors.white,
        ),
      ),
    );
  }
}
