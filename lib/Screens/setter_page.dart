import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:hive/hive.dart';
import 'package:adas/Services/flex_colors/theme_controller.dart';
import 'package:adas/Cubit/ble_cubit.dart';
import 'package:adas/Data/system_ui.dart';
import 'main_page.dart';
import 'on_boarding.dart';

late BleCubit C;

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
    C = BleCubit.get(context);
    C.box = widget.box;
    C.themeController = widget.themeController;
    // to get theme from context
    SchedulerBinding.instance.addPostFrameCallback((_) {
      C.lang = context.locale.toString();
      C.theme = Theme.of(context).colorScheme;
      C.themeChanged();
      // get list of saved devices
      C.getDevices();
      Navigator.of(context).pushReplacement(MaterialPageRoute(
          builder: (context) => C.box.get("showHome", defaultValue: false) == true
              ? const MainPage()
              : const IntroPage()));
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
        value: systemUI(brightness: C.brightness), child: Container());
  }
}
