import 'package:flutter/material.dart';

Widget bleTile(String bName, uuid, rssi, color) {
  return ListTile(
    leading:
        Text("$rssi", style: TextStyle(fontSize: 28, fontWeight: FontWeight.w600, color: color)),
    title: Text(
      bName == "" ? "No Name" : bName,
      style: const TextStyle(fontWeight: FontWeight.w600),
    ),
    subtitle: Text("$uuid"),
    trailing: ElevatedButton(child: const Icon(Icons.bluetooth_searching), onPressed: () {}),
  );
}
