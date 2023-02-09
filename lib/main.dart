import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:dynamic_color/dynamic_color.dart';
import 'package:blue/Bloc/ble_bloc.dart';
import 'package:blue/Screens/scan_page.dart';
import 'package:blue/Data/theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();
  runApp(EasyLocalization(
      useOnlyLangCode: true,
      supportedLocales: const [Locale('en'), Locale('ar')],
      path: 'assets/translations',
      fallbackLocale: const Locale('en'),
      child: const MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

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
                  theme: ThemeData(
                    colorScheme: lightColorScheme ?? defaultLightColorScheme,
                    useMaterial3: true,
                  ),
                  darkTheme: ThemeData(
                    colorScheme: darkColorScheme ?? defaultDarkColorScheme,
                    useMaterial3: true,
                  ),
                  localizationsDelegates: context.localizationDelegates,
                  supportedLocales: context.supportedLocales,
                  locale: context.locale,
                  home: const ScanPage(),
                );
              }));
        },
      ),
    );
  }
}
