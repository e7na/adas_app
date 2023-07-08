import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class ScanQrPage extends StatelessWidget {
  const ScanQrPage({super.key});

  @override
  Widget build(BuildContext context) {
    bool foundQR = false;
    return Scaffold(
      appBar: AppBar(title: const Text('Mobile Scanner')),
      body: MobileScanner(
        // fit: BoxFit.contain,
        onDetect: (capture) {
          // to prevent multiple scans
          if (!foundQR && capture.barcodes[0].rawValue.toString().split('|||').length == 2) {
            foundQR = true;
            print("id:${capture.barcodes[0].rawValue.toString().split('|||')[0].split('||')[0]}");
            print("key:${capture.barcodes[0].rawValue.toString().split('|||')[0].split('||')[1]}");
            print("iv:${capture.barcodes[0].rawValue.toString().split('|||')[1]}");
            // Navigator.of(context).pushReplacement(MaterialPageRoute(
            //     builder: (context) => tempPage(text: capture.barcodes[0].rawValue.toString())));
          }
        },
      ),
    );
  }
}
