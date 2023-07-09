import 'package:adas/Screens/setter_page.dart';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:easy_localization/easy_localization.dart';

class ScanQrPage extends StatelessWidget {
  const ScanQrPage({super.key});

  @override
  Widget build(BuildContext context) {
    bool foundQR = false;
    return Scaffold(
        appBar: AppBar(title: const Text('QR Scanner').tr()),
      body: MobileScanner(
        // fit: BoxFit.contain,
        onDetect: (capture) {
          // to prevent multiple scans
          if (!foundQR && capture.barcodes[0].rawValue.toString().split('|||').length == 2) {
            foundQR = true;
            showAlertDialog(context, capture.barcodes[0].rawValue!);
          }
        },
      ),
    );
  }
}

showAlertDialog(BuildContext context, String barCodeValue) {
  // set up the buttons
  Widget cancelButton = TextButton(
    child: const Text("Cancel").tr(),
    onPressed: () {
      // close alert dialog
      Navigator.of(context).pop();
      // close qr scan page
      Navigator.of(context).pop();
    },
  );
  Widget continueButton = TextButton(
    child: const Text("Continue").tr(),
    onPressed: () {
      // replace key and iv
      B.replaceKeys(
          id: barCodeValue.toString().split('|||')[0].split('||')[0],
          key: barCodeValue.toString().split('|||')[0].split('||')[1],
          vector: barCodeValue.toString().split('|||')[1]);
      // close alert dialog
      Navigator.of(context).pop();
      // close qr scan page
      Navigator.of(context).pop();
      // close share page
      Navigator.of(context).pop();
    },
  );

  // set up the AlertDialog
  AlertDialog alert = AlertDialog(
    title: const Text("Warning").tr(),
    content: const Text("T5").tr(),
    actions: [
      cancelButton,
      continueButton,
    ],
  );

  // show the dialog
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return alert;
    },
  );
}
