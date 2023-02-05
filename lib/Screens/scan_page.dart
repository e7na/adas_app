import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:reactive_ble/Bloc/ble_bloc.dart';

//This page is shown when scanning for BLE devices
class ScanPage extends StatefulWidget {
  const ScanPage({Key? key}) : super(key: key);

  @override
  State<ScanPage> createState() => _ScanPageState();
}

class _ScanPageState extends State<ScanPage> {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => BleBloc(),
      child: BlocConsumer<BleBloc, BleState>(
        listener: (context, state) {},
        builder: (context, state) {
          var B = BleBloc.get(context);
          return Scaffold(appBar: AppBar(title: Text("Title".tr())),);
        },
      ),
    );
  }
}
