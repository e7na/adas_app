import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:blue/Bloc/ble_bloc.dart';
import 'package:blue/Widgets/device_tile.dart';
import 'package:blue/Data/Models/device_model.dart';
import 'package:blue/Screens/settings_page.dart';

class MainPage extends StatefulWidget {
  const MainPage({Key? key}) : super(key: key);

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  @override
  void initState() {
    super.initState();
    BleBloc.get(context).getDevices();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<BleBloc, BleState>(
      listener: (context, state) {},
      builder: (context, state) {
        return theScaffold(context: context);
      },
    );
  }
}

Widget theScaffold({
  required BuildContext context,
}) {
  var B = BleBloc.get(context);
  Color primary = Theme.of(context).colorScheme.primary;
  Color surfaceVariant = Theme.of(context).colorScheme.surfaceVariant;

  return Scaffold(
    backgroundColor: B.brightness == Brightness.dark
        ? Theme.of(context).colorScheme.background
        : surfaceVariant.withOpacity(0.6),
    body: ListView(
      children: [
        const SizedBox(
          height: 30,
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "MainTitle".tr(),
                style: TextStyle(color: primary, fontSize: 30, fontWeight: FontWeight.w500),
              ),
              IconButton(
                  onPressed: () => Navigator.of(context)
                      .push(MaterialPageRoute(builder: (context) => const SettingsPage())),
                  icon: Icon(
                    Icons.settings,
                    color: primary,
                  ))
            ],
          ),
        ),
        ListView.builder(
            padding: EdgeInsets.zero,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: B.finalDevices.length,
            itemBuilder: (context, index) {
              // This is only to Test not the real widget
              return DeviceTile(
                device: BleDevice(
                  name: B.finalDevices[index].name,
                  id: B.finalDevices[index].id,
                ),
                rssi: 0,
                status: DeviceConnectionState.disconnected,
              );
            }),
      ],
    ),
    bottomNavigationBar: Container(
      color: surfaceVariant,
      height: 60,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // This would be used for reconnecting if needed else it will be removed
          SizedBox(
            width: 300,
            child: ElevatedButton(
              // start scan or stop it.
              onPressed: () {},
              child: const Icon(Icons.refresh),
            ),
          ),
        ],
      ),
    ),
  );
}
