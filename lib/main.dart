import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:dynamic_color/dynamic_color.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:blue/Screens/main_page.dart';
import 'package:blue/Bloc/ble_bloc.dart';
import 'package:blue/Screens/scan_page.dart';
import 'Services/flex_colors/app_color.dart';
import 'Services/flex_colors/theme_controller.dart';
import 'Services/flex_colors/theme_service.dart';
import 'Services/flex_colors/theme_service_hive.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();
  await Hive.initFlutter();
  Box box = await Hive.openBox("bleBox");
  final int numDevices = box.get('NumDevices') ?? 0;
  // The box name is just a file name for the file that stores the settings.
  final ThemeService themeService = ThemeServiceHive('flex_colors_box');
  // Initialize the theme service.
  await themeService.init();
  // Create a ThemeController that uses the ThemeService.
  final ThemeController themeController = ThemeController(themeService);
  // Load preferred theme settings, while the app is loading, before MaterialApp
  // is created, this prevents a theme change when the app is first displayed.
  await themeController.loadAll();
// Run the app and pass in the ThemeController. The app listens to the
// ThemeController for changes.
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
          var B = BleBloc.get(context);
          B.box = box;
          B.themeController = themeController;
          var theme = B.brightness == Brightness.dark ? Brightness.light : Brightness.dark;
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
              child: DynamicColorBuilder(builder: (lightColorScheme, darkColorScheme) {
                return MaterialApp(
                  title: 'Blue',
                  debugShowCheckedModeBanner: false,
                  theme: FlexThemeData.light(
                    colors: AppColor.customSchemes[themeController.schemeIndex].light,
                    keyColors: FlexKeyColors(
                      useKeyColors: themeController.useKeyColors,
                      useSecondary: themeController.useSecondary,
                      useTertiary: themeController.useTertiary,
                      keepPrimary: themeController.keepPrimary,
                      keepSecondary: themeController.keepSecondary,
                      keepTertiary: themeController.keepTertiary,
                    ),
                    appBarElevation: 1,
                    useMaterial3: true,
                    surfaceMode: FlexSurfaceMode.levelSurfacesLowScaffold,
                    blendLevel: 24,
                    visualDensity: FlexColorScheme.comfortablePlatformDensity,
                  ),
                  darkTheme: FlexThemeData.dark(
                    colors: AppColor.customSchemes[themeController.schemeIndex].dark,
                    keyColors: FlexKeyColors(
                      useKeyColors: themeController.useKeyColors,
                      useSecondary: themeController.useSecondary,
                      useTertiary: themeController.useTertiary,
                      keepPrimary: themeController.keepDarkPrimary,
                      keepSecondary: themeController.keepDarkSecondary,
                      keepTertiary: themeController.keepDarkTertiary,
                    ),
                    appBarElevation: 1,
                    useMaterial3: true,
                    surfaceMode: FlexSurfaceMode.highBackgroundLowScaffold,
                    blendLevel: 24,
                    visualDensity: FlexColorScheme.comfortablePlatformDensity,
                  ),
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
