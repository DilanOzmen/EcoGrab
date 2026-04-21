import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'rescue_home_screen.dart';

class LivingLarderLoginScreen extends StatefulWidget {
  const LivingLarderLoginScreen({super.key});
  @override
  State<LivingLarderLoginScreen> createState() => _LivingLarderLoginScreenState();
}

class _LivingLarderLoginScreenState extends State<LivingLarderLoginScreen> {
  // Renk tanımları
  static const _primary = Color(0xFF0F5238);
  static const _surface = Color(0xFFF8FAF8);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _surface,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.location_on, color: _primary, size: 60),
              Text('The Living Larder', style: GoogleFonts.plusJakartaSans(fontSize: 32, fontWeight: FontWeight.bold, color: _primary)),
              const SizedBox(height: 40),
              TextField(decoration: InputDecoration(labelText: 'E-posta', border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)))),
              const SizedBox(height: 16),
              TextField(obscureText: true, decoration: InputDecoration(labelText: 'Şifre', border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)))),
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: () {
                    // GİRİŞ YAPINCA ANA SAYFAYA GİDER
                    Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const RescueHomeScreen()));
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: _primary, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                  child: const Text('Giriş Yap', style: TextStyle(color: Colors.white, fontSize: 18)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}