import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:food_waste_app/screens/living_larder_login_screen.dart';
import 'package:food_waste_app/screens/order_tracking_screen.dart';

void main() {
  runApp(const FoodWasteApp());
}

class FoodWasteApp extends StatelessWidget {
  const FoodWasteApp({super.key});

  @override
  Widget build(BuildContext context) {
    const background = Color(0xFFF8FAF8);
    const onSurface = Color(0xFF191C1B);

    final baseTextTheme = ThemeData.light().textTheme;

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Food Waste App',
      theme: ThemeData(
        scaffoldBackgroundColor: background,
        colorScheme: const ColorScheme.light(
          primary: Color(0xFF0F5238),
          surface: background,
          onSurface: onSurface,
        ),
        textTheme: GoogleFonts.manropeTextTheme(baseTextTheme).copyWith(
          headlineLarge: GoogleFonts.plusJakartaSans(),
          headlineMedium: GoogleFonts.plusJakartaSans(),
          headlineSmall: GoogleFonts.plusJakartaSans(),
          titleLarge: GoogleFonts.plusJakartaSans(),
          titleMedium: GoogleFonts.plusJakartaSans(),
          titleSmall: GoogleFonts.plusJakartaSans(),
        ),
      ),
      routes: {
        '/login': (context) => const LivingLarderLoginScreen(),
        '/tracking': (context) => const OrderTrackingScreen(),
      },
      home: const LivingLarderLoginScreen(),
    );
  }
}