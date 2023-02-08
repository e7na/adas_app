import 'package:blue/Data/Models/device_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:blue/Bloc/ble_bloc.dart';

class bleTile extends StatefulWidget {
  String name;
  String uuid;
  int rssi;
  Color color;
  int index;

  bleTile(
      {Key? key,
      required this.name,
      required this.uuid,
      required this.rssi,
      required this.color,
      required this.index})
      : super(key: key);

  @override
  State<bleTile> createState() => _bleTileState();
}

class _bleTileState extends State<bleTile> {
  late bool isRemove;

  @override
  void initState() {
    isRemove = false;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    BleDevice device = BleDevice(widget.name == "" ? "No Name" : widget.name, widget.uuid);
    return BlocConsumer<BleBloc, BleState>(
      listener: (context, state) {},
      builder: (context, state) {
        var B = BleBloc.get(context);
        return ListTile(
          leading: Text("${widget.rssi}",
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.w600, color: widget.color)),
          title: Text(
            widget.name == "" ? "No Name" : widget.name,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          subtitle: Text(widget.uuid),
          trailing: ElevatedButton(
              child: Icon(isRemove ? Icons.cancel_rounded : Icons.check),
              onPressed: () async {
                isRemove
                    ? {isRemove = B.deviceRemove(device: device)}
                    : {isRemove = B.deviceAdd(device: device)};
              }),
        );
      },
    );
  }
}
