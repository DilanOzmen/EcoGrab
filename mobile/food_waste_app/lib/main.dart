import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:food_waste_app/screens/login_screen.dart';
import 'package:food_waste_app/screens/register_screen.dart';
import 'package:food_waste_app/screens/rescue_home_screen.dart';
import 'package:food_waste_app/screens/seller_home_screen.dart';

void main() {
  runApp(const FoodWasteApp());
}

class FoodWasteApp extends StatelessWidget {
  const FoodWasteApp({super.key});

  @override
  Widget build(BuildContext context) {
    const background = Color(0xFFF8FAF8);
    const primary = Color(0xFF0F5238);
    const onSurface = Color(0xFF191C1B);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Food Waste App',
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: background,
        colorScheme: const ColorScheme.light(
          primary: primary,
          surface: background,
          onSurface: onSurface,
        ),
        textTheme: GoogleFonts.manropeTextTheme().copyWith(
          headlineLarge: GoogleFonts.plusJakartaSans(),
          headlineMedium: GoogleFonts.plusJakartaSans(),
          headlineSmall: GoogleFonts.plusJakartaSans(),
          titleLarge: GoogleFonts.plusJakartaSans(),
          titleMedium: GoogleFonts.plusJakartaSans(),
          titleSmall: GoogleFonts.plusJakartaSans(),
        ),
      ),
      initialRoute: '/login',
      routes: {
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        '/customer-home': (context) => const RescueHomeScreen(),
        '/seller-home': (context) => const SellerHomeScreen(),
      },
    );
  }
}