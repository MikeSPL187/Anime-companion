import 'package:flutter/material.dart';

abstract final class AppTheme {
  static final ThemeData light = ThemeData.light(
    useMaterial3: true,
  ).copyWith(visualDensity: VisualDensity.adaptivePlatformDensity);

  static final ThemeData dark = ThemeData.dark(
    useMaterial3: true,
  ).copyWith(visualDensity: VisualDensity.adaptivePlatformDensity);
}
