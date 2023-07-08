import 'package:adas/Bloc/ble_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

SystemUiOverlayStyle systemUI({required BleBloc B}) {
  Brightness theme = B.brightness == Brightness.dark ? Brightness.light : Brightness.dark;
  return SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: theme,
    // For Android (dark icons)
    statusBarBrightness: theme,
    // For iOS (dark icons)
    // systemNavigationBarIconBrightness: theme,
    // systemNavigationBarColor: B.theme.surfaceVariant,
  );
}
