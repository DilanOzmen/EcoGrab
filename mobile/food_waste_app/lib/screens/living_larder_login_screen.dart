import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:food_waste_app/core/app_state.dart';
import 'package:food_waste_app/data/services/api_client.dart';
import 'rescue_home_screen.dart';
import 'seller_home_screen.dart';

class LivingLarderLoginScreen extends StatefulWidget {
  const LivingLarderLoginScreen({super.key});
  @override
  State<LivingLarderLoginScreen> createState() => _LivingLarderLoginScreenState();
}

class _LivingLarderLoginScreenState extends State<LivingLarderLoginScreen> {
  // Renk tanımları
  static const _primary = Color(0xFF0F5238);
  static const _surface = Color(0xFFF8FAF8);

  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _apiClient = ApiClient();

  bool _isSubmitting = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final auth = await _apiClient.login(
        _emailController.text.trim(),
        _passwordController.text,
      );

      if (!mounted) return;

      AppState.setUser(auth);
      final role = auth.role.toLowerCase();

      if (role == 'customer' || role == 'musteri') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const RescueHomeScreen()),
        );
        return;
      }

      if (role == 'seller' || role == 'satici') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const SellerHomeScreen()),
        );
        return;
      }

      AppState.clear();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Desteklenmeyen rol: ${auth.role}')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceAll('ApiException: ', ''))),
      );
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _surface,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.location_on, color: _primary, size: 60),
              Text('The Living Larder', style: GoogleFonts.plusJakartaSans(fontSize: 32, fontWeight: FontWeight.bold, color: _primary)),
              const SizedBox(height: 40),
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(labelText: 'E-posta', border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'E-posta zorunludur';
                    }
                    if (!value.contains('@')) {
                      return 'Geçerli bir e-posta giriniz';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _passwordController,
                  obscureText: true,
                  onFieldSubmitted: (_) => _isSubmitting ? null : _login(),
                  decoration: InputDecoration(labelText: 'Şifre', border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Şifre zorunludur';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 30),
                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    onPressed: _isSubmitting ? null : _login,
                    style: ElevatedButton.styleFrom(backgroundColor: _primary, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                    child: _isSubmitting
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(strokeWidth: 2.2, valueColor: AlwaysStoppedAnimation<Color>(Colors.white)),
                          )
                        : const Text('Giriş Yap', style: TextStyle(color: Colors.white, fontSize: 18)),
                  ),
                ),
            ],
            ),
          ),
        ),
      ),
    );
  }
}