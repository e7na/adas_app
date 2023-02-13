import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:blue/Bloc/ble_bloc.dart';
import 'package:blue/Data/Models/device_model.dart';

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
  late bool isRemove;

  @override
  void initState() {
    isRemove = false;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var B = BleBloc.get(context);
    ColorScheme theme = Theme.of(context).colorScheme;
    return ListTile(
      leading: Text("${widget.rssi}",
          style: TextStyle(fontSize: 28, fontWeight: FontWeight.w600, color: theme.primary)),
      title: Text(
        widget.device.name == "" ? "No Name".tr() : widget.device.name,
        style: const TextStyle(fontWeight: FontWeight.w600),
      ),
      subtitle: Text(widget.device.id),
      trailing: ElevatedButton(
          child: Icon(isRemove ? Icons.cancel_rounded : Icons.check),
          onPressed: () async {
            isRemove
                ? setState(() {
                    isRemove = B.deviceRemove(device: widget.device);
                  })
                : setState(() {
                    isRemove = B.deviceAdd(device: widget.device);
                  });
          }),
    );
  }
}
