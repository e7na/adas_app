import 'package:flutter/material.dart';

Widget bleTile(String bName, uuid, rssi) {
  return ListTile(
    leading: const Icon(Icons.bluetooth, size: 40),
    title: Text(
      bName,
      style: const TextStyle(fontWeight: FontWeight.w600),
    ),
    subtitle: Text("UUID: $uuid"),
    trailing: Text("RSSI: $rssi"),
  );
}
