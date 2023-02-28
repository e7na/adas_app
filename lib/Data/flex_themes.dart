import 'package:flutter/material.dart';
import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:blue/Services/flex_colors/app_color.dart';
import 'package:blue/Services/flex_colors/theme_controller.dart';

ThemeData flexTheme({required String mode, required ThemeController themeController}) {
  late ThemeData theme;
  mode == "light"
      ? theme = FlexThemeData.light(
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
        )
      : theme = FlexThemeData.dark(
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
        );
  return theme;
}
