import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';

class AppTextStyles {
  AppTextStyles._();

  static final TextStyle headingLarge = GoogleFonts.plusJakartaSans(
    fontSize: 30,
    fontWeight: FontWeight.w900,
    color: AppColors.textDark,
  );

  static final TextStyle title = GoogleFonts.plusJakartaSans(
    fontSize: 18,
    fontWeight: FontWeight.w800,
    color: AppColors.textDark,
  );

  static final TextStyle body = GoogleFonts.manrope(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: AppColors.textDark,
  );

  static final TextStyle bodySoft = GoogleFonts.manrope(
    fontSize: 13,
    fontWeight: FontWeight.w500,
    color: AppColors.textSoft,
  );

  static final TextStyle button = GoogleFonts.plusJakartaSans(
    fontSize: 15,
    fontWeight: FontWeight.w800,
    color: AppColors.surface,
  );
}