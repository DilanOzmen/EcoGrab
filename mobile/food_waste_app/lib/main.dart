import 'package:flutter/material.dart';

import 'package:food_waste_app/core/app_theme.dart';
import 'package:food_waste_app/data/services/api_client.dart';

import 'package:food_waste_app/screens/splash_screen.dart';
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
    final apiClient = ApiClient();

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'EcoGrab',
      theme: AppTheme.lightTheme(),
      initialRoute: '/splash',
      routes: {
        '/splash': (context) => const SplashScreen(),
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        '/customer-home': (context) => RescueHomeScreen(apiClient: apiClient),
        '/seller-home': (context) => const SellerHomeScreen(),
      },
    );
  }
}