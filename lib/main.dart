import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:dynamic_color/dynamic_color.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'Services/flex_colors/theme_controller.dart';
import 'Services/flex_colors/theme_service.dart';
import 'Services/flex_colors/theme_service_hive.dart';
import 'package:adas/Cubit/ble_cubit.dart';
import 'package:adas/Screens/setter_page.dart';
import 'Data/flex_themes.dart';
import 'Data/theme.dart';

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
  runApp(EasyLocalization(
      useOnlyLangCode: true,
      supportedLocales: const [Locale('en'), Locale('ar')],
      path: 'assets/translations',
      fallbackLocale: const Locale('en'),
      child: MyApp(
        themeController: themeController,
        box: box,
      )));
}

class MyApp extends StatelessWidget {
  final Box box;
  final ThemeController themeController;

  const MyApp({super.key, required this.themeController, required this.box});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => BleCubit(),
      child: BlocBuilder<BleCubit, BleState>(
        builder: (context, state) {
          return DynamicColorBuilder(builder: (lightColorScheme, darkColorScheme) {
            return MaterialApp(
                title: 'ADAS',
                debugShowCheckedModeBanner: false,
                theme: flexTheme(
                    mode: "light",
                    themeController: themeController,
                    dScheme: lightColorScheme ?? defaultLightColorScheme,
                    isDynamic: box.get("isDynamic") ?? false),
                darkTheme: flexTheme(
                  mode: "dark",
                  themeController: themeController,
                  dScheme: darkColorScheme ?? defaultDarkColorScheme,
                  isDynamic: box.get("isDynamic") ?? false,
                ),
                themeMode: themeController.themeMode,
                localizationsDelegates: context.localizationDelegates,
                supportedLocales: context.supportedLocales,
                locale: context.locale,
                home: SetterPage(
                  box: box,
                  themeController: themeController,
                ));
          });
        },
      ),
    );
  }
}
