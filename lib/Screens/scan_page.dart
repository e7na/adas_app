import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:reactive_ble/Bloc/ble_bloc.dart';

//This page is shown when scanning for BLE devices
class ScanPage extends StatefulWidget {
  const ScanPage({Key? key}) : super(key: key);

  @override
  State<ScanPage> createState() => _ScanPageState();
}

class _ScanPageState extends State<ScanPage> {
  @override
  Widget build(BuildContext context) {
    var brightness = SchedulerBinding.instance.window.platformBrightness;
    var theme = brightness == Brightness.dark ? Brightness.light : Brightness.dark;
    Color fontColor = Theme.of(context).colorScheme.onSurfaceVariant;
    return AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: theme,
          // For Android (dark icons)
          statusBarBrightness: theme,
          // For iOS (dark icons)
          systemNavigationBarIconBrightness: theme,
          systemNavigationBarColor: Theme.of(context).colorScheme.surfaceVariant,
        ),
        child: BlocProvider(
          create: (context) => BleBloc(),
          child: BlocConsumer<BleBloc, BleState>(
            listener: (context, state) {},
            builder: (context, state) {
              var B = BleBloc.get(context);
              return ColoredBox(
                color: Colors.white,
                child: Scaffold(
                  backgroundColor: brightness == Brightness.dark ? Theme.of(context).colorScheme.background : Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.6),
                  body: SafeArea(
                    child: Column(children: [
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Text(
                          "Title".tr(),
                          style: TextStyle(color: fontColor, fontSize: 30, fontWeight: FontWeight.w600),
                        ),
                      )
                    ]),
                  ),
                ),
              );
            },
          ),
        ));
  }
}
