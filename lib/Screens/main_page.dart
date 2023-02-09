import 'package:blue/Screens/scan_page.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:blue/Bloc/ble_bloc.dart';
import 'package:blue/Widgets/ble_tile.dart';

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
            height: 40,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Text(
              "MainTitle".tr(),
              style: TextStyle(color: primary, fontSize: 30, fontWeight: FontWeight.w500),
            ),
          ),
          ListView.builder(
              padding: EdgeInsets.zero,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: B.finalDevices.length,
              itemBuilder: (context, index) {
                // This is only to Test not the real widget
                return BleTile(
                    name: B.finalDevices[index].name,
                    uuid: B.finalDevices[index].id,
                    rssi: 0,
                    primary: primary,
                    index: index);
              }),
          // This won't Exist later
          ElevatedButton(
              onPressed: () => Navigator.of(context)
                  .pushReplacement(MaterialPageRoute(builder: (context) => const ScanPage())),
              child: const Text("Go Back")),
        ],
      ));
}
