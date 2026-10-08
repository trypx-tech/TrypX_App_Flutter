import 'package:flutter/material.dart';

import 'trypx_colors.dart';

/// Returns the TrypX dark theme.
ThemeData trypxDarkTheme() {
  const colorScheme = ColorScheme.dark(
    primary: TrypXColors.primaryOrange,
    onPrimary: TrypXColors.textPrimary,
    secondary: TrypXColors.secondaryCyan,
    onSecondary: TrypXColors.surfaceNavy,
    surface: TrypXColors.surfaceNavy,
    onSurface: TrypXColors.textPrimary,
    error: TrypXColors.errorRed,
    onError: TrypXColors.textPrimary,
  );

  const textTheme = TextTheme(
    displayLarge: TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: TrypXColors.textPrimary),
    displayMedium: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: TrypXColors.textPrimary),
    headlineMedium: TextStyle(fontSize: 24, fontWeight: FontWeight.w600, color: TrypXColors.textPrimary),
    titleLarge: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: TrypXColors.textPrimary),
    bodyLarge: TextStyle(fontSize: 16, fontWeight: FontWeight.normal, color: TrypXColors.textPrimary),
    bodyMedium: TextStyle(fontSize: 14, fontWeight: FontWeight.normal, color: TrypXColors.textSecondary),
    labelMedium: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: TrypXColors.textSecondary),
  );

  return ThemeData(
    brightness: Brightness.dark,
    colorScheme: colorScheme,
    scaffoldBackgroundColor: TrypXColors.surfaceNavy,
    textTheme: textTheme,
    useMaterial3: true,
  );
}
