import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

SystemUiOverlayStyle systemUI({required Brightness theme}) {
  return SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: theme,
    // For Android (dark icons)
    statusBarBrightness: theme,
    // For iOS (dark icons)
    // systemNavigationBarIconBrightness: theme,
    // systemNavigationBarColor: surfaceVariant,
  );
}
