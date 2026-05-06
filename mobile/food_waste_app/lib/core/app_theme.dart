import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';
import 'app_spacing.dart';

class AppTheme {
  AppTheme._();

  static ThemeData lightTheme() {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: AppColors.background,
      colorScheme: const ColorScheme.light(
        primary: AppColors.primaryGreen,
        secondary: AppColors.freshGreen,
        surface: AppColors.surface,
        error: AppColors.error,
        onSurface: AppColors.textDark,
      ),
      textTheme: GoogleFonts.manropeTextTheme().copyWith(
        headlineLarge: GoogleFonts.plusJakartaSans(
          fontWeight: FontWeight.w900,
          color: AppColors.textDark,
        ),
        headlineMedium: GoogleFonts.plusJakartaSans(
          fontWeight: FontWeight.w800,
          color: AppColors.textDark,
        ),
        titleLarge: GoogleFonts.plusJakartaSans(
          fontWeight: FontWeight.w800,
          color: AppColors.textDark,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.inputRadius),
          borderSide: const BorderSide(color: AppColors.surfaceContainer),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.inputRadius),
          borderSide: const BorderSide(color: AppColors.surfaceContainer),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.inputRadius),
          borderSide: const BorderSide(
            color: AppColors.primaryGreen,
            width: 1.5,
          ),
        ),
      ),
    );
  }
}