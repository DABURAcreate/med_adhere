import 'package:flutter/material.dart';

class AppTheme {
  static const Color primaryBlue = Color(0xFF165B9E);
  static const Color primaryTeal = Color(0xFF1A7E95);
  static const Color accentTeal = Color(0xFF5DC7BD);
  static const Color cardTeal = Color.fromARGB(255, 39, 133, 124);
  static const Color background = Color(0xFFE9E9E9);

  static ThemeData get light => ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: primaryBlue,
      brightness: Brightness.light,
    ),
    scaffoldBackgroundColor: background,
  );

  static ThemeData get dark => ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: primaryBlue,
      brightness: Brightness.dark,
    ),
  );
}