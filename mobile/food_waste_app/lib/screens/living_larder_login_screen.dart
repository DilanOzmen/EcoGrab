import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class LivingLarderLoginScreen extends StatefulWidget {
  const LivingLarderLoginScreen({super.key});

  @override
  State<LivingLarderLoginScreen> createState() =>
      _LivingLarderLoginScreenState();
}

class _LivingLarderLoginScreenState extends State<LivingLarderLoginScreen> {
  static const _surface = Color(0xFFF8FAF8);
  static const _onSurface = Color(0xFF191C1B);
  static const _onSurfaceVariant = Color(0xFF404943);
  static const _primary = Color(0xFF0F5238);
  static const _primaryContainer = Color(0xFF2D6A4F);
  static const _primaryFixed = Color(0xFFB1F0CE);
  static const _secondary = Color(0xFF9D4300);
  static const _outlineVariant = Color(0xFFBFC9C1);
  static const _surfaceContainerLow = Color(0xFFF2F4F2);
  static const _surfaceContainerHigh = Color(0xFFE6E9E7);
  static const _surfaceContainerLowest = Color(0xFFFFFFFF);

  bool _isCustomer = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _surface,
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isDesktop = constraints.maxWidth >= 900;
          return Stack(
            children: [
              Row(
                children: [
                  if (isDesktop) Expanded(child: _desktopBrandSection()),
                  Expanded(
                    child: _authSection(
                      isDesktop: isDesktop,
                      maxWidth: constraints.maxWidth,
                    ),
                  ),
                ],
              ),
              if (isDesktop)
                Positioned(
                  top: 0,
                  right: 0,
                  bottom: 0,
                  width: constraints.maxWidth / 3,
                  child: IgnorePointer(child: _blobDecoration()),
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _desktopBrandSection() {
    return Container(
      padding: const EdgeInsets.all(48),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [_primary, _primaryContainer],
        ),
      ),
      child: Stack(
        children: [
          Positioned.fill(
            child: Opacity(
              opacity: 0.2,
              child: Image.network(
                'https://lh3.googleusercontent.com/aida-public/AB6AXuCBYtrYFMFxTroytTGLPSw71WFD-G7StN40lVt6Tk5MirlxhDOkbLGELI-YpJ4uoqbmN8tv_8LmYIIz2vt21fuAApW0uZ_o2Vzh4QeoTremNGSb8xT9v4RBSl3GI4nvZtkQgZWISh-z9eRcScbD3gebwjyKzgjomHBOA9G4ZZ2zS7bRMv6XAsg18xW_nMULAqTYg0Lx2MpYmSSNtROvQO37O_5I5SqCWHI5GORZUZq7YewYY2G5BH8X0btyFhH4XDoDCoqt1JcI9Gef',
                fit: BoxFit.cover,
              ),
            ),
          ),
          Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 540),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.eco, size: 64, color: _primaryFixed),
                  const SizedBox(height: 28),
                  Text(
                    'The Living Larder',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 52,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -1.2,
                      color: Colors.white,
                      height: 1.04,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Akilli Gida Israfi Azaltma Platformu ile yerel ureticileri ve taze gidayi koruyun. Surdurulebilir bir gelecek icin bize katilin.',
                    style: GoogleFonts.manrope(
                      fontSize: 22,
                      fontWeight: FontWeight.w400,
                      color: const Color(0xFFA8E7C5),
                      height: 1.45,
                    ),
                  ),
                  const SizedBox(height: 42),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(
                        color: _primaryFixed.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '🌱',
                          style: GoogleFonts.manrope(fontSize: 14),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '1.2M Ton Gida Kurtarildi',
                          style: GoogleFonts.manrope(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _authSection({required bool isDesktop, required double maxWidth}) {
    return SafeArea(
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 540),
          child: Padding(
            padding: EdgeInsets.fromLTRB(
              maxWidth >= 1200 ? 96 : 24,
              48,
              maxWidth >= 1200 ? 96 : 24,
              24,
            ),
            child: Column(
              children: [
                if (!isDesktop) ...[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'The Living Larder',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 28,
                          fontWeight: FontWeight.w800,
                          color: _primary,
                        ),
                      ),
                      const Icon(Icons.location_on, color: _primary),
                    ],
                  ),
                  const SizedBox(height: 44),
                ],
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Hos Geldiniz',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 36,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.8,
                            color: _onSurface,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Platformu nasil kullanmak istersiniz?',
                          style: GoogleFonts.manrope(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: _onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: 30),
                        _roleToggle(),
                        const SizedBox(height: 30),
                        _label('E-posta Adresi'),
                        const SizedBox(height: 10),
                        _inputField(
                          hint: 'ornek@email.com',
                          keyboardType: TextInputType.emailAddress,
                        ),
                        const SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _label('Sifre'),
                            TextButton(
                              onPressed: () {},
                              style: TextButton.styleFrom(
                                padding: EdgeInsets.zero,
                                minimumSize: Size.zero,
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                              child: Text(
                                'Sifremi Unuttum',
                                style: GoogleFonts.manrope(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: _primary,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        _inputField(hint: '••••••••', obscureText: true),
                        const SizedBox(height: 24),
                        _loginButton(),
                        const SizedBox(height: 34),
                        _dividerText(),
                        const SizedBox(height: 22),
                        Row(
                          children: [
                            Expanded(
                              child: _socialButton(
                                label: 'Google',
                                leading: Text(
                                  'G',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w700,
                                    color: _onSurfaceVariant,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: _socialButton(
                                label: 'Facebook',
                                leading: Icon(
                                  Icons.facebook,
                                  color: _onSurfaceVariant,
                                  size: 20,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 36),
                        Align(
                          child: RichText(
                            text: TextSpan(
                              style: GoogleFonts.manrope(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: _onSurfaceVariant,
                              ),
                              children: [
                                const TextSpan(text: 'Hesabiniz yok mu? '),
                                TextSpan(
                                  text: 'Hemen Kaydolun',
                                  style: GoogleFonts.manrope(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                    color: _secondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: _primaryFixed.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.verified_user, size: 16, color: _primary),
                      const SizedBox(width: 8),
                      Text(
                        'JWT-tabanli guvenli oturum yonetimi',
                        style: GoogleFonts.manrope(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: _primary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _roleToggle() {
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: _surfaceContainerLow,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: _roleButton(
              label: 'Musteri',
              icon: Icons.person,
              active: _isCustomer,
              onTap: () => setState(() => _isCustomer = true),
            ),
          ),
          Expanded(
            child: _roleButton(
              label: 'Satici',
              icon: Icons.storefront,
              active: !_isCustomer,
              onTap: () => setState(() => _isCustomer = false),
            ),
          ),
        ],
      ),
    );
  }

  Widget _roleButton({
    required String label,
    required IconData icon,
    required bool active,
    required VoidCallback onTap,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(10),
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
        decoration: BoxDecoration(
          color: active ? _surfaceContainerLowest : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          boxShadow: active
              ? const [
                  BoxShadow(
                    color: Color(0x12000000),
                    blurRadius: 4,
                    offset: Offset(0, 1),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 20,
              color: active ? _primary : _onSurfaceVariant,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: GoogleFonts.manrope(
                fontSize: 16,
                fontWeight: active ? FontWeight.w700 : FontWeight.w500,
                color: active ? _primary : _onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _label(String text) {
    return Text(
      text,
      style: GoogleFonts.manrope(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: _onSurfaceVariant,
      ),
    );
  }

  Widget _inputField({
    required String hint,
    bool obscureText = false,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextField(
      obscureText: obscureText,
      keyboardType: keyboardType,
      style: GoogleFonts.manrope(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        color: _onSurface,
      ),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: GoogleFonts.manrope(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: _onSurfaceVariant.withValues(alpha: 0.5),
        ),
        filled: true,
        fillColor: _surfaceContainerHigh,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 18,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _primary, width: 2),
        ),
      ),
    );
  }

  Widget _loginButton() {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [_primary, _primaryContainer],
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: _primary.withValues(alpha: 0.15),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: () {},
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            padding: const EdgeInsets.symmetric(vertical: 18),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: Text(
            'Giris Yap',
            style: GoogleFonts.manrope(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }

  Widget _dividerText() {
    return Stack(
      alignment: Alignment.center,
      children: [
        Divider(
          color: _outlineVariant.withValues(alpha: 0.3),
          thickness: 1,
        ),
        Container(
          color: _surface,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          child: Text(
            'Ya da sununla devam et',
            style: GoogleFonts.manrope(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: _onSurfaceVariant,
            ),
          ),
        ),
      ],
    );
  }

  Widget _socialButton({required String label, required Widget leading}) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: () {},
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
        decoration: BoxDecoration(
          color: _surfaceContainerLow,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            leading,
            const SizedBox(width: 10),
            Text(
              label,
              style: GoogleFonts.manrope(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: _onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _blobDecoration() {
    return Opacity(
      opacity: 0.05,
      child: CustomPaint(
        painter: _BlobPainter(color: _primary),
      ),
    );
  }
}

class _BlobPainter extends CustomPainter {
  const _BlobPainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;
    final path = Path()
      ..moveTo(size.width * 0.25, size.height * 0.08)
      ..cubicTo(
        size.width * 0.55,
        size.height * 0.0,
        size.width * 0.92,
        size.height * 0.1,
        size.width * 0.8,
        size.height * 0.38,
      )
      ..cubicTo(
        size.width * 0.7,
        size.height * 0.66,
        size.width * 0.96,
        size.height * 0.94,
        size.width * 0.54,
        size.height * 0.98,
      )
      ..cubicTo(
        size.width * 0.15,
        size.height * 1.0,
        size.width * 0.06,
        size.height * 0.64,
        size.width * 0.12,
        size.height * 0.42,
      )
      ..cubicTo(
        size.width * 0.18,
        size.height * 0.24,
        size.width * 0.05,
        size.height * 0.15,
        size.width * 0.25,
        size.height * 0.08,
      )
      ..close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _BlobPainter oldDelegate) {
    return oldDelegate.color != color;
  }
}
