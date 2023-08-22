import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:adas/Data/Models/device_model.dart';
import 'package:adas/Screens/setter_page.dart';

class BleTile extends StatefulWidget {
  final BleDevice device;
  final int rssi;
  final int index;

  const BleTile({Key? key, required this.device, required this.rssi, required this.index})
      : super(key: key);

  @override
  State<BleTile> createState() => _BleTileState();
}

class _BleTileState extends State<BleTile> {
  bool isRemove = false;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Text("${widget.rssi}",
          style: TextStyle(fontSize: 28, fontWeight: FontWeight.w600, color: C.theme.primary)),
      title: Text(
        widget.device.name == "" ? "No Name".tr() : widget.device.name,
        style: const TextStyle(fontWeight: FontWeight.w600),
      ),
      subtitle: Text(widget.device.id),
      trailing: ElevatedButton(
          child: Icon(isRemove ? Icons.cancel_rounded : Icons.check),
          onPressed: () async {
            isRemove
                ? {isRemove = C.deviceRemove(device: widget.device), C.isRemoveChanged()}
                : {isRemove = C.deviceAdd(device: widget.device), C.isRemoveChanged()};
          }),
    );
  }
}
