import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:food_waste_app/core/app_state.dart';
import 'login_screen.dart';

class SellerHomeScreen extends StatelessWidget {
  const SellerHomeScreen({super.key});

  static const _primary = Color(0xFF0F5238);
  static const _surface = Color(0xFFF8FAF8);
  static const _onSurfaceVariant = Color(0xFF404943);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _surface,
      appBar: AppBar(
        backgroundColor: _surface,
        elevation: 0,
        title: Text(
          'Satici Paneli',
          style: GoogleFonts.plusJakartaSans(
            fontWeight: FontWeight.w800,
            color: _primary,
            fontSize: 22,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: _onSurfaceVariant),
            tooltip: 'Cikis Yap',
            onPressed: () {
              AppState.clear();
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (_) => const LoginScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.storefront, size: 72, color: _primary),
            const SizedBox(height: 16),
            Text(
              'Hos Geldiniz, ${AppState.currentUser?.fullName ?? 'Satici'}',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: _primary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Urun ve siparis yonetimi yakin zamanda eklenecek.',
              style: GoogleFonts.manrope(
                fontSize: 14,
                color: _onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
