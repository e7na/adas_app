import 'package:flutter/material.dart';
import 'package:blue/Bloc/ble_bloc.dart';
import 'package:blue/Data/Models/device_model.dart';

class BleTile extends StatefulWidget {
  final String name;
  final String uuid;
  final int rssi;
  final Color primary;
  final int index;

  const BleTile(
      {Key? key,
      required this.name,
      required this.uuid,
      required this.rssi,
      required this.primary,
      required this.index})
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
    BleDevice device =
        BleDevice(name: widget.name == "" ? "No Name" : widget.name, id: widget.uuid);
    var B = BleBloc.get(context);
    return ListTile(
      leading: Text("${widget.rssi}",
          style: TextStyle(fontSize: 28, fontWeight: FontWeight.w600, color: widget.primary)),
      title: Text(
        widget.name == "" ? "No Name" : widget.name,
        style: const TextStyle(fontWeight: FontWeight.w600),
      ),
      subtitle: Text(widget.uuid),
      trailing: ElevatedButton(
          child: Icon(isRemove ? Icons.cancel_rounded : Icons.check),
          onPressed: () async {
            isRemove
                ? setState(() {
                    isRemove = B.deviceRemove(device: device);
                  })
                : setState(() {
                    isRemove = B.deviceAdd(device: device);
                  });
          }),
    );
  }
}
