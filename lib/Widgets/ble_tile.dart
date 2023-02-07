import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:reactive_ble/Bloc/ble_bloc.dart';

Widget bleTile(String bName, uuid, rssi, color, index) {
  bool isConnected = false;
  return BlocConsumer<BleBloc, BleState>(
    listener: (context, state) {},
    builder: (context, state) {
      var B = BleBloc.get(context);
      return ListTile(
        leading: Text("$rssi",
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.w600, color: color)),
        title: Text(
          bName == "" ? "No Name" : bName,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text("$uuid"),
        trailing: ElevatedButton(
            child: Icon(isConnected ? Icons.bluetooth_connected : Icons.bluetooth_searching),
            onPressed: () async {
              B.connectToDevice(index);
              // pure fol7 ahead
              //await Future.delayed(const Duration(seconds: 5));
              //isConnected = B.connected;
              //debugPrint("$isConnected");
            }),
      );
    },
  );
}
