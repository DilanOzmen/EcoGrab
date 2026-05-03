import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  static const Color primaryGreen = Color(0xFF0F5238);
  static const Color primaryContainer = Color(0xFF2D6A4F);
  static const Color deepGreen = Color(0xFF083D2B);
  static const Color freshGreen = Color(0xFF7BCB5A);

  static const Color background = Color(0xFFF8FAF8);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceContainer = Color(0xFFECEEEC);

  static const Color textDark = Color(0xFF191C1B);
  static const Color textSoft = Color(0xFF707973);
  static const Color onSurfaceVariant = Color(0xFF404943);

  static const Color secondaryOrange = Color(0xFFFD761A);
  static const Color error = Color(0xFFE53935);

  static const LinearGradient editorialGradient = LinearGradient(
    colors: [primaryGreen, primaryContainer],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient splashGradient = LinearGradient(
    colors: [deepGreen, primaryGreen],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}

