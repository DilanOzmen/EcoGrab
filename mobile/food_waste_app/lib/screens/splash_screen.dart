import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _introController;
  late AnimationController _floatController;
  late AnimationController _exitController;

  late Animation<double> _logoScale;
  late Animation<double> _logoOpacity;
  late Animation<double> _floatMove;
  late Animation<double> _exitOpacity;
  late Animation<double> _exitScale;

  @override
  void initState() {
    super.initState();

    _introController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1300),
    );

    _floatController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    )..repeat(reverse: true);

    _exitController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _logoScale = Tween<double>(begin: 0.65, end: 1).animate(
      CurvedAnimation(parent: _introController, curve: Curves.easeOutBack),
    );

    _logoOpacity = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _introController, curve: Curves.easeOut),
    );

    _floatMove = Tween<double>(begin: -10, end: 12).animate(
      CurvedAnimation(parent: _floatController, curve: Curves.easeInOut),
    );

    _exitOpacity = Tween<double>(begin: 1, end: 0).animate(
      CurvedAnimation(parent: _exitController, curve: Curves.easeInOut),
    );

    _exitScale = Tween<double>(begin: 1, end: 1.08).animate(
      CurvedAnimation(parent: _exitController, curve: Curves.easeInOut),
    );

    _startAnimation();
  }

  Future<void> _startAnimation() async {
  await _introController.forward();

  // Splash ekranda daha uzun beklesin
  await Future.delayed(const Duration(milliseconds: 2600));

  if (!mounted) return;
  await _exitController.forward();

  if (!mounted) return;
  Navigator.pushReplacementNamed(context, '/login');
}

  @override
  void dispose() {
    _introController.dispose();
    _floatController.dispose();
    _exitController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedBuilder(
        animation: Listenable.merge([
          _introController,
          _floatController,
          _exitController,
        ]),
        builder: (context, child) {
          return Opacity(
            opacity: _exitOpacity.value,
            child: Transform.scale(
              scale: _exitScale.value,
              child: Stack(
                children: [
                  _background(),
                  _decorations(),
                  _mainContent(),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _background() {
    return Container(
      decoration: const BoxDecoration(
        gradient: RadialGradient(
          center: Alignment.center,
          radius: 0.95,
          colors: [
            Color(0xFF137347),
            Color(0xFF0F5238),
            Color(0xFF053322),
          ],
        ),
      ),
    );
  }

  Widget _decorations() {
    return Stack(
      children: [
        Positioned(
          top: -90,
          left: -80,
          child: _softCircle(250, const Color(0xFF7BCB5A), 0.10),
        ),
        Positioned(
          bottom: -130,
          right: -110,
          child: _softCircle(330, const Color(0xFF7BCB5A), 0.11),
        ),
        Positioned(
          left: -120,
          bottom: 60 + _floatMove.value,
          child: _leaf(310, 0.13, -0.55),
        ),
        Positioned(
          right: -85,
          top: 70 - _floatMove.value,
          child: _leaf(245, 0.13, 0.55),
        ),
        Positioned(
          right: 35,
          bottom: 135 + _floatMove.value,
          child: _leaf(92, 0.35, -0.25),
        ),
        Positioned(
          left: 45,
          top: 145 - _floatMove.value,
          child: _leaf(84, 0.20, 0.55),
        ),
        Positioned(left: 64, bottom: 250, child: _dot(13)),
        Positioned(right: 62, top: 245, child: _ring(28)),
      ],
    );
  }

  Widget _mainContent() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Opacity(
              opacity: _logoOpacity.value,
              child: Transform.translate(
                offset: Offset(0, _floatMove.value),
                child: Transform.scale(
                  scale: _logoScale.value,
                  child: _logoBadge(),
                ),
              ),
            ),
            const SizedBox(height: 34),
            Opacity(
              opacity: _logoOpacity.value,
              child: Transform.translate(
                offset: Offset(0, 20 * (1 - _logoOpacity.value)),
                child: Column(
                  children: [
                    RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: 'ECO',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 50,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 2.6,
                              color: Colors.white,
                            ),
                          ),
                          TextSpan(
                            text: 'GRAB',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 50,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 2.6,
                              color: const Color(0xFF7BCB5A),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Daha az israf, daha iyi gelecek.',
                      style: GoogleFonts.manrope(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white.withValues(alpha: 0.82),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _logoBadge() {
    return Stack(
      alignment: Alignment.center,
      children: [
        Container(
          width: 250,
          height: 250,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: const Color(0xFF7BCB5A).withValues(alpha: 0.14),
          ),
        ),
        Container(
          width: 225,
          height: 225,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: const Color(0xFF7BCB5A).withValues(alpha: 0.18),
          ),
        ),
        Container(
          width: 190,
          height: 190,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: const Color(0xFFFFFCF4),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.30),
                blurRadius: 35,
                offset: const Offset(0, 18),
              ),
              BoxShadow(
                color: const Color(0xFF7BCB5A).withValues(alpha: 0.35),
                blurRadius: 50,
                spreadRadius: 8,
              ),
            ],
          ),
          child: Image.asset(
            'assets/images/ecograb_logo.png',
            fit: BoxFit.contain,
          ),
        ),
      ],
    );
  }

  Widget _leaf(double size, double opacity, double angle) {
    return Transform.rotate(
      angle: angle,
      child: Icon(
        Icons.eco,
        size: size,
        color: const Color(0xFF7BCB5A).withValues(alpha: opacity),
      ),
    );
  }

  Widget _softCircle(double size, Color color, double opacity) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color.withValues(alpha: opacity),
      ),
    );
  }

  Widget _dot(double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: const Color(0xFF7BCB5A).withValues(alpha: 0.8),
      ),
    );
  }

  Widget _ring(double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: const Color(0xFF7BCB5A).withValues(alpha: 0.8),
          width: 2,
        ),
      ),
    );
  }
}