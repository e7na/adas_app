import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:blue/Bloc/ble_bloc.dart';

class MainPage extends StatelessWidget {
  const MainPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return theScaffold(context: context);
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
                return const Placeholder();
              })
        ],
      ));
}
