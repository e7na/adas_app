import 'package:blue/Screens/main_page.dart';
import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:dynamic_color/dynamic_color.dart';
import 'package:blue/Bloc/ble_bloc.dart';
import 'package:blue/Screens/scan_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  final int numDevices = prefs.getInt('NumDevices') ?? 0;
  runApp(EasyLocalization(
      useOnlyLangCode: true,
      supportedLocales: const [Locale('en'), Locale('ar')],
      path: 'assets/translations',
      fallbackLocale: const Locale('en'),
      child: MyApp(numDevices: numDevices)));
}

class MyApp extends StatelessWidget {
  final int numDevices;

  const MyApp({super.key, required this.numDevices});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => BleBloc(),
      child: BlocConsumer<BleBloc, BleState>(
        listener: (context, state) {},
        builder: (context, state) {
          var B = BleBloc.get(context);
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
                    scheme: FlexScheme.materialHc,
                    appBarElevation: 1,
                    useMaterial3: true,
                    surfaceMode: FlexSurfaceMode.levelSurfacesLowScaffold,
                    blendLevel: 24,
                    visualDensity: FlexColorScheme.comfortablePlatformDensity,
                  ),
                  darkTheme: FlexThemeData.dark(
                    scheme: FlexScheme.deepPurple,
                    appBarElevation: 1,
                    useMaterial3: true,
                    surfaceMode: FlexSurfaceMode.highBackgroundLowScaffold,
                    blendLevel: 24,
                    visualDensity: FlexColorScheme.comfortablePlatformDensity,
                  ),
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
