import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:food_waste_app/core/app_assets.dart';
import 'package:food_waste_app/core/app_colors.dart';
import 'package:food_waste_app/core/app_spacing.dart';
import 'package:food_waste_app/core/app_state.dart';
import 'package:food_waste_app/data/services/api_client.dart';
import 'package:food_waste_app/screens/register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _apiClient = ApiClient();

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool isLoading = false;
  bool isPasswordHidden = true;

  late final AnimationController _introController;
  late final AnimationController _sparkleController;

  late final Animation<double> _fade;
  late final Animation<Offset> _slide;
  late final Animation<double> _sparkleOpacity;
  late final Animation<double> _sparkleScale;

  @override
  void initState() {
    super.initState();

    _introController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 750),
    );

    _sparkleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1300),
    )..repeat(reverse: true);

    _fade = CurvedAnimation(parent: _introController, curve: Curves.easeOut);

    _slide = Tween<Offset>(begin: const Offset(0, 0.08), end: Offset.zero)
        .animate(
          CurvedAnimation(parent: _introController, curve: Curves.easeOutCubic),
        );

    _sparkleOpacity = Tween<double>(begin: 0.25, end: 0.75).animate(
      CurvedAnimation(parent: _sparkleController, curve: Curves.easeInOut),
    );

    _sparkleScale = Tween<double>(begin: 0.92, end: 1.08).animate(
      CurvedAnimation(parent: _sparkleController, curve: Curves.easeInOut),
    );

    _introController.forward();
  }

  @override
  void dispose() {
    _introController.dispose();
    _sparkleController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => isLoading = true);

    try {
      final auth = await _apiClient.login(
        _emailController.text.trim(),
        _passwordController.text.trim(),
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
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  InputDecoration _inputDecoration({
    required String hint,
    required IconData icon,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      hintText: hint,
      hintStyle: GoogleFonts.manrope(color: AppColors.textSoft, fontSize: 13),
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
        borderSide: const BorderSide(color: AppColors.primaryGreen, width: 1.4),
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
                            const SizedBox(height: 22),
                            _buildTitle(),
                            const SizedBox(height: 26),
                            _buildFields(),
                            const SizedBox(height: 24),
                            _buildLoginButton(),
                            const SizedBox(height: 22),
                            _buildRegisterText(),
                            const SizedBox(height: 20),
                            _buildSecurityBadge(),
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
          top: -55,
          right: -55,
          child: Icon(
            Icons.eco,
            size: 210,
            color: AppColors.freshGreen.withValues(alpha: 0.12),
          ),
        ),
        Positioned(
          bottom: -90,
          left: -100,
          child: Icon(
            Icons.eco,
            size: 270,
            color: AppColors.primaryGreen.withValues(alpha: 0.08),
          ),
        ),
      ],
    );
  }

  Widget _buildLogo() {
    return Column(
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            AnimatedBuilder(
              animation: _sparkleController,
              builder: (context, child) {
                return Transform.scale(
                  scale: _sparkleScale.value,
                  child: Opacity(
                    opacity: _sparkleOpacity.value,
                    child: Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.freshGreen.withValues(alpha: 0.12),
                      ),
                    ),
                  ),
                );
              },
            ),
            Image.asset(
              AppAssets.ecograbLogo,
              width: 118,
              height: 118,
              fit: BoxFit.contain,
            ),
          ],
        ),
        const SizedBox(height: 4),
        RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: 'ECO',
                style: GoogleFonts.plusJakartaSans(
                  color: AppColors.primaryGreen,
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.5,
                ),
              ),
              TextSpan(
                text: 'GRAB',
                style: GoogleFonts.plusJakartaSans(
                  color: AppColors.freshGreen,
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.5,
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
          'Hoş Geldiniz',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 30,
            fontWeight: FontWeight.w900,
            color: AppColors.textDark,
          ),
        ),
      ],
    );
  }

  Widget _buildFields() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // --- E-POSTA ALANI ---
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

        // --- ŞİFRE ALANI ---
        _label('Şifre'),
        const SizedBox(height: 8),
        TextFormField(
          controller: _passwordController,
          obscureText: isPasswordHidden,
          onFieldSubmitted: (_) => isLoading ? null : _login(),
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
            return null;
          },
        ),

        // --- ŞİFREMİ UNUTTUM BUTONU (Tam şifrenin altında) ---
        Align(
          alignment: Alignment.centerRight,
          child: TextButton(
            onPressed: () {
              _showMessage(
                'Şifre sıfırlama bağlantısı e-postanıza gönderilecek.',
              );
            },
            style: TextButton.styleFrom(
              padding: EdgeInsets.zero,
              minimumSize: const Size(0, 30),
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: Text(
              'Şifremi Unuttum',
              style: GoogleFonts.plusJakartaSans(
                color: AppColors.primaryGreen,
                fontWeight: FontWeight.w700,
                fontSize: 13,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLoginButton() {
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
          onPressed: isLoading ? null : _login,
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
                  'Giriş Yap',
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

  Widget _buildRegisterText() {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const RegisterScreen()),
        );
      },
      child: RichText(
        text: TextSpan(
          style: GoogleFonts.manrope(color: AppColors.textSoft, fontSize: 12),
          children: const [
            TextSpan(text: 'Hesabınız yok mu? '),
            TextSpan(
              text: 'Hesap Oluştur',
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

  Widget _buildSecurityBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.freshGreen.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        'Güvenli oturum yönetimi',
        style: GoogleFonts.manrope(
          color: AppColors.primaryGreen,
          fontSize: 11,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }

  Widget _label(String text) {
    return Text(
      text,
      style: GoogleFonts.manrope(
        fontSize: 12,
        fontWeight: FontWeight.w800,
        color: AppColors.textDark,
      ),
    );
  }
}
