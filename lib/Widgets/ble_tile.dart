import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:blue/Bloc/ble_bloc.dart';
import 'package:blue/Data/Models/device_model.dart';
import 'package:blue/main.dart';

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
    return BlocConsumer<BleBloc, BleState>(
      listener: (context, state) {},
      builder: (context, state) {
        return ListTile(
          leading: Text("${widget.rssi}",
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.w600, color: B.theme.primary)),
          title: Text(
            widget.device.name == "" ? "No Name".tr() : widget.device.name,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          subtitle: Text(widget.device.id),
          trailing: ElevatedButton(
              child: Icon(isRemove ? Icons.cancel_rounded : Icons.check),
              onPressed: () async {
                isRemove
                    ? {isRemove = B.deviceRemove(device: widget.device), B.isRemoveChanged()}
                    : {isRemove = B.deviceAdd(device: widget.device), B.isRemoveChanged()};
              }),
        );
      },
    );
  }
}
