import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:food_waste_app/core/app_state.dart';
import 'package:food_waste_app/data/services/api_client.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  static const primary = Color(0xFF0F5238);
  static const background = Color(0xFFF8FAF8);
  static const inputBg = Color(0xFFECEFED);
  static const textDark = Color(0xFF191C1B);
  static const textSoft = Color(0xFF707973);

  final _formKey = GlobalKey<FormState>();
  final _apiClient = ApiClient();

  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();

  bool isCustomer = true;
  bool isPasswordHidden = true;
  bool acceptedTerms = false;
  bool isLoading = false;

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;

    if (!acceptedTerms) {
      _showMessage('Kullanım şartlarını kabul etmelisiniz.');
      return;
    }

    setState(() => isLoading = true);

    try {
      final auth = await _apiClient.register(
        fullName: _fullNameController.text.trim(),
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
        phone: _phoneController.text.trim(),
        role: isCustomer ? 'Customer' : 'Seller',
      );

      AppState.setUser(auth);

      if (!mounted) return;

      final role = auth.role.toLowerCase();

      if (role == 'customer' || role == 'musteri') {
        Navigator.pushReplacementNamed(context, '/customer-home');
      } else if (role == 'seller' || role == 'satici') {
        Navigator.pushReplacementNamed(context, '/seller-home');
      } else {
        AppState.clear();
        _showMessage('Desteklenmeyen rol: ${auth.role}');
      }
    } catch (e) {
      if (!mounted) return;
      _showMessage(e.toString().replaceAll('ApiException: ', ''));
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  InputDecoration _inputDecoration({
    required String hint,
    required IconData icon,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      hintText: hint,
      hintStyle: GoogleFonts.manrope(color: textSoft, fontSize: 13),
      prefixIcon: Icon(icon, color: textSoft, size: 20),
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: inputBg,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: const BorderSide(color: primary, width: 1.4),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 20),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 390),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    _buildLogo(),
                    const SizedBox(height: 28),
                    _buildTitle(),
                    const SizedBox(height: 26),
                    _buildRoleSection(),
                    const SizedBox(height: 22),
                    _buildFields(),
                    const SizedBox(height: 16),
                    _buildTerms(),
                    const SizedBox(height: 22),
                    _buildRegisterButton(),
                    const SizedBox(height: 28),
                    _buildLoginText(),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLogo() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.eco, color: primary, size: 18),
        const SizedBox(width: 6),
        Text(
          'The Living Larder',
          style: GoogleFonts.plusJakartaSans(
            color: primary,
            fontSize: 14,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }

  Widget _buildTitle() {
    return Column(
      children: [
        Text(
          'Hoş Geldiniz',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 30,
            fontWeight: FontWeight.w800,
            color: textDark,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Sürdürülebilir bir gelecek için ilk adımı atın.',
          textAlign: TextAlign.center,
          style: GoogleFonts.manrope(
            fontSize: 13,
            color: textSoft,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildRoleSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _label('Hesap Türü'),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(5),
          decoration: BoxDecoration(
            color: const Color(0xFFF2F4F2),
            borderRadius: BorderRadius.circular(18),
          ),
          child: Row(
            children: [
              _roleButton(
                text: 'Müşteri',
                icon: Icons.person,
                selected: isCustomer,
                onTap: () => setState(() => isCustomer = true),
              ),
              _roleButton(
                text: 'Satıcı',
                icon: Icons.storefront,
                selected: !isCustomer,
                onTap: () => setState(() => isCustomer = false),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _roleButton({
    required String text,
    required IconData icon,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(vertical: 11),
          decoration: BoxDecoration(
            color: selected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 17, color: selected ? primary : textSoft),
              const SizedBox(width: 6),
              Text(
                text,
                style: GoogleFonts.manrope(
                  fontSize: 12,
                  color: selected ? primary : textSoft,
                  fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFields() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _label('Ad Soyad'),
        const SizedBox(height: 8),
        TextFormField(
          controller: _fullNameController,
          decoration: _inputDecoration(
            hint: 'İsminizi girin',
            icon: Icons.badge_outlined,
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Ad soyad zorunludur';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        _label('E-posta'),
        const SizedBox(height: 8),
        TextFormField(
          controller: _emailController,
          keyboardType: TextInputType.emailAddress,
          decoration: _inputDecoration(
            hint: 'ornek@mail.com',
            icon: Icons.email_outlined,
          ),
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
        _label('Telefon'),
        const SizedBox(height: 8),
        TextFormField(
          controller: _phoneController,
          keyboardType: TextInputType.phone,
          decoration: _inputDecoration(
            hint: 'Telefon numaranızı girin',
            icon: Icons.phone_outlined,
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Telefon zorunludur';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        _label('Şifre'),
        const SizedBox(height: 8),
        TextFormField(
          controller: _passwordController,
          obscureText: isPasswordHidden,
          decoration: _inputDecoration(
            hint: '••••••••',
            icon: Icons.lock_outline,
            suffixIcon: IconButton(
              icon: Icon(
                isPasswordHidden ? Icons.visibility : Icons.visibility_off,
                color: textSoft,
                size: 20,
              ),
              onPressed: () {
                setState(() => isPasswordHidden = !isPasswordHidden);
              },
            ),
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Şifre zorunludur';
            }
            if (value.length < 6) {
              return 'Şifre en az 6 karakter olmalıdır';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildTerms() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Checkbox(
          value: acceptedTerms,
          activeColor: primary,
          visualDensity: VisualDensity.compact,
          onChanged: (value) {
            setState(() => acceptedTerms = value ?? false);
          },
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              'Kullanım Şartları ve Gizlilik Politikası’nı okudum ve kabul ediyorum.',
              style: GoogleFonts.manrope(
                fontSize: 11,
                color: textSoft,
                height: 1.4,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRegisterButton() {
    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [primary, Color(0xFF2D6A4F)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: primary.withValues(alpha: 0.20),
            blurRadius: 22,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: isLoading ? null : _register,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
        ),
        child: isLoading
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
            : Text(
                'Hesap Oluştur',
                style: GoogleFonts.plusJakartaSans(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                ),
              ),
      ),
    );
  }

  Widget _buildLoginText() {
    return GestureDetector(
      onTap: () => Navigator.pop(context),
      child: RichText(
        text: TextSpan(
          style: GoogleFonts.manrope(
            color: textSoft,
            fontSize: 12,
          ),
          children: const [
            TextSpan(text: 'Zaten bir hesabınız var mı? '),
            TextSpan(
              text: 'Giriş Yap',
              style: TextStyle(
                color: primary,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _label(String text) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        text,
        style: GoogleFonts.manrope(
          fontSize: 12,
          fontWeight: FontWeight.w800,
          color: textDark,
        ),
      ),
    );
  }
}