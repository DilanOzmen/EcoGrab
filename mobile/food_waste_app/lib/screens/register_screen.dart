import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:food_waste_app/core/app_assets.dart';
import 'package:food_waste_app/core/app_colors.dart';
import 'package:food_waste_app/core/app_spacing.dart';
import 'package:food_waste_app/core/app_state.dart';
import 'package:food_waste_app/data/services/api_client.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen>
    with SingleTickerProviderStateMixin {
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

  late final AnimationController _controller;
  late final Animation<double> _fade;
  late final Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );

    _fade = CurvedAnimation(parent: _controller, curve: Curves.easeOut);

    _slide = Tween<Offset>(
      begin: const Offset(0, 0.06),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
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

      await AppState.setUser(auth);

      if (!mounted) return;

      final role = auth.role.toLowerCase();

      if (role == 'customer' || role == 'musteri') {
        Navigator.pushReplacementNamed(context, '/customer-home');
      } else if (role == 'seller' || role == 'satici') {
        Navigator.pushReplacementNamed(context, '/seller-home');
      } else {
        await AppState.clear();
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
      hintStyle: GoogleFonts.manrope(
        color: AppColors.textSoft,
        fontSize: 13,
      ),
      prefixIcon: Icon(icon, color: AppColors.textSoft, size: 20),
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: AppColors.surfaceContainer.withValues(alpha: 0.75),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppSpacing.inputRadius),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppSpacing.inputRadius),
        borderSide: const BorderSide(
          color: AppColors.primaryGreen,
          width: 1.4,
        ),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Stack(
          children: [
            _backgroundLeaves(),
            Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.screenPadding,
                  vertical: 24,
                ),
                child: FadeTransition(
                  opacity: _fade,
                  child: SlideTransition(
                    position: _slide,
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 390),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            _buildLogo(),
                            const SizedBox(height: 16),
                            _buildTitle(),
                            const SizedBox(height: 22),
                            _buildRoleSection(),
                            const SizedBox(height: 20),
                            _buildFields(),
                            const SizedBox(height: 14),
                            _buildTerms(),
                            const SizedBox(height: 20),
                            _buildRegisterButton(),
                            const SizedBox(height: 22),
                            _buildLoginText(),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _backgroundLeaves() {
    return Stack(
      children: [
        Positioned(
          top: -65,
          right: -65,
          child: Icon(
            Icons.eco,
            size: 220,
            color: AppColors.freshGreen.withValues(alpha: 0.10),
          ),
        ),
        Positioned(
          bottom: -90,
          left: -100,
          child: Icon(
            Icons.eco,
            size: 270,
            color: AppColors.primaryGreen.withValues(alpha: 0.07),
          ),
        ),
      ],
    );
  }

  Widget _buildLogo() {
    return Column(
      children: [
        Image.asset(
          AppAssets.ecograbLogo,
          width: 92,
          height: 92,
          fit: BoxFit.contain,
        ),
        const SizedBox(height: 4),
        RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: 'ECO',
                style: GoogleFonts.plusJakartaSans(
                  color: AppColors.primaryGreen,
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.4,
                ),
              ),
              TextSpan(
                text: 'GRAB',
                style: GoogleFonts.plusJakartaSans(
                  color: AppColors.freshGreen,
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.4,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTitle() {
    return Column(
      children: [
        Text(
          'Hesap Oluştur',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 28,
            fontWeight: FontWeight.w900,
            color: AppColors.textDark,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Size uygun hesap türünü seçin ve başlayın.',
          textAlign: TextAlign.center,
          style: GoogleFonts.manrope(
            fontSize: 13,
            color: AppColors.textSoft,
            fontWeight: FontWeight.w600,
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
        const SizedBox(height: 10),
        Row(
          children: [
            _roleCard(
              title: 'Müşteri',
              subtitle: 'Ürün kurtar',
              icon: Icons.shopping_bag_outlined,
              selected: isCustomer,
              onTap: () => setState(() => isCustomer = true),
            ),
            const SizedBox(width: 12),
            _roleCard(
              title: 'Satıcı',
              subtitle: 'Ürün listele',
              icon: Icons.storefront_outlined,
              selected: !isCustomer,
              onTap: () => setState(() => isCustomer = false),
            ),
          ],
        ),
      ],
    );
  }

  Widget _roleCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            gradient: selected ? AppColors.editorialGradient : null,
            color: selected ? null : AppColors.surfaceContainer.withValues(alpha: 0.55),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: selected
                  ? AppColors.primaryGreen
                  : AppColors.surfaceContainer,
              width: 1.2,
            ),
            boxShadow: selected
                ? [
                    BoxShadow(
                      color: AppColors.primaryGreen.withValues(alpha: 0.18),
                      blurRadius: 18,
                      offset: const Offset(0, 8),
                    ),
                  ]
                : [],
          ),
          child: Column(
            children: [
              Icon(
                icon,
                color: selected ? Colors.white : AppColors.primaryGreen,
                size: 26,
              ),
              const SizedBox(height: 8),
              Text(
                title,
                style: GoogleFonts.plusJakartaSans(
                  color: selected ? Colors.white : AppColors.textDark,
                  fontSize: 14,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                subtitle,
                style: GoogleFonts.manrope(
                  color: selected
                      ? Colors.white.withValues(alpha: 0.82)
                      : AppColors.textSoft,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
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
        const SizedBox(height: 14),
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
        const SizedBox(height: 14),
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
        const SizedBox(height: 14),
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
                color: AppColors.textSoft,
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
          activeColor: AppColors.primaryGreen,
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
                color: AppColors.textSoft,
                height: 1.4,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRegisterButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: AppColors.editorialGradient,
          borderRadius: BorderRadius.circular(AppSpacing.buttonRadius),
          boxShadow: [
            BoxShadow(
              color: AppColors.primaryGreen.withValues(alpha: 0.22),
              blurRadius: 22,
              offset: const Offset(0, 9),
            ),
          ],
        ),
        child: ElevatedButton(
          onPressed: isLoading ? null : _register,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
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
                    fontWeight: FontWeight.w900,
                  ),
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
            color: AppColors.textSoft,
            fontSize: 12,
          ),
          children: const [
            TextSpan(text: 'Zaten bir hesabınız var mı? '),
            TextSpan(
              text: 'Giriş Yap',
              style: TextStyle(
                color: AppColors.primaryGreen,
                fontWeight: FontWeight.w900,
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
          color: AppColors.textDark,
        ),
      ),
    );
  }
}