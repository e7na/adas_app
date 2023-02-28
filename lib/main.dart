import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:dynamic_color/dynamic_color.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:blue/Screens/main_page.dart';
import 'package:blue/Bloc/ble_bloc.dart';
import 'package:blue/Screens/scan_page.dart';
import 'Services/flex_colors/theme_controller.dart';
import 'Services/flex_colors/theme_service.dart';
import 'Services/flex_colors/theme_service_hive.dart';
import 'Data/flex_themes.dart';
import 'Data/system_ui.dart';

late BleBloc B;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Initialize the Localization services.
  await EasyLocalization.ensureInitialized();
  // Initialize the Hive services.
  await Hive.initFlutter();
  // open a named hive box to store data and settings
  Box box = await Hive.openBox("bleBox");
  // open another box for themes
  final ThemeService themeService = ThemeServiceHive('flex_colors_box');
  // Initialize the theme service.
  await themeService.init();
  // Create a ThemeController that uses the ThemeService.
  final ThemeController themeController = ThemeController(themeService);
  // Load preferred theme settings, this prevents a theme change when the app is first displayed.
  await themeController.loadAll();
  // get the number of saved devices
  final int numDevices = box.get('NumDevices') ?? 0;
  runApp(EasyLocalization(
      useOnlyLangCode: true,
      supportedLocales: const [Locale('en'), Locale('ar')],
      path: 'assets/translations',
      fallbackLocale: const Locale('en'),
      child: MyApp(
        numDevices: numDevices,
        themeController: themeController,
        box: box,
      )));
}

class MyApp extends StatelessWidget {
  final int numDevices;
  final Box box;
  final ThemeController themeController;

  const MyApp(
      {super.key, required this.numDevices, required this.themeController, required this.box});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => BleBloc(),
      child: BlocConsumer<BleBloc, BleState>(
        listener: (context, state) {},
        builder: (context, state) {
          B = BleBloc.get(context);
          B.box = box;
          B.lang = context.locale.toString();
          B.themeController = themeController;
          Brightness themeB = B.brightness == Brightness.dark ? Brightness.light : Brightness.dark;
          return AnnotatedRegion<SystemUiOverlayStyle>(
              value: systemUI(theme: themeB),
              child: DynamicColorBuilder(builder: (lightColorScheme, darkColorScheme) {
                return MaterialApp(
                  title: 'Blue',
                  debugShowCheckedModeBanner: false,
                  theme: flexTheme(mode: "light", themeController: themeController),
                  darkTheme: flexTheme(mode: "dark", themeController: themeController),
                  themeMode: themeController.themeMode,
                  localizationsDelegates: context.localizationDelegates,
                  supportedLocales: context.supportedLocales,
                  locale: context.locale,
                  home: numDevices > 0 ? const MainPage() : const ScanPage(),
                );
              }));
        },
      ),
    );
  }
}
