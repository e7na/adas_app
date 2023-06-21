import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:hive/hive.dart';
import 'package:blue/Services/flex_colors/theme_controller.dart';
import 'package:blue/Bloc/ble_bloc.dart';
import 'package:blue/Data/system_ui.dart';
import 'main_page.dart';

late BleBloc B;

class SetterPage extends StatefulWidget {
  final Box box;
  final ThemeController themeController;

  const SetterPage({Key? key, required this.box, required this.themeController}) : super(key: key);

  @override
  State<SetterPage> createState() => _SetterPageState();
}

class _SetterPageState extends State<SetterPage> {
  @override
  void initState() {
    super.initState();
    B = BleBloc.get(context);
    B.box = widget.box;
    B.themeController = widget.themeController;
    // to get theme from context
    SchedulerBinding.instance.addPostFrameCallback((_) {
      B.lang = context.locale.toString();
      B.theme = Theme.of(context).colorScheme;
      B.themeChanged();
      // get list of saved devices
      B.getDevices();
      Navigator.of(context)
          .pushReplacement(MaterialPageRoute(builder: (context) => const MainPage()));
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(value: systemUI(B: B), child: Container());
  }
}
