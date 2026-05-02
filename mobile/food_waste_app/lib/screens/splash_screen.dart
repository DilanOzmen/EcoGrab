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
  late AnimationController _leafController;
  late AnimationController _exitController;

  late Animation<double> _logoScale;
  late Animation<double> _logoOpacity;
  late Animation<Offset> _logoSlide;

  late Animation<double> _textOpacity;
  late Animation<Offset> _textSlide;

  late Animation<double> _leafMove;
  late Animation<double> _leafRotate;
  late Animation<double> _exitOpacity;
  late Animation<double> _exitScale;

  @override
  void initState() {
    super.initState();

    _introController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1450),
    );

    _leafController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1900),
    )..repeat(reverse: true);

    _exitController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );

    _logoOpacity = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _introController,
        curve: const Interval(0.0, 0.55, curve: Curves.easeOut),
      ),
    );

    _logoScale = Tween<double>(begin: 0.45, end: 1.0).animate(
      CurvedAnimation(parent: _introController, curve: Curves.easeOutBack),
    );

    _logoSlide = Tween<Offset>(
      begin: const Offset(0, 0.45),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _introController, curve: Curves.easeOutCubic),
    );

    _textOpacity = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _introController,
        curve: const Interval(0.42, 1.0, curve: Curves.easeOut),
      ),
    );

    _textSlide = Tween<Offset>(
      begin: const Offset(0, 0.32),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _introController,
        curve: const Interval(0.42, 1.0, curve: Curves.easeOutCubic),
      ),
    );

    _leafMove = Tween<double>(begin: -22, end: 24).animate(
      CurvedAnimation(parent: _leafController, curve: Curves.easeInOut),
    );

    _leafRotate = Tween<double>(begin: -0.08, end: 0.08).animate(
      CurvedAnimation(parent: _leafController, curve: Curves.easeInOut),
    );

    _exitOpacity = Tween<double>(begin: 1, end: 0).animate(
      CurvedAnimation(parent: _exitController, curve: Curves.easeInOut),
    );

    _exitScale = Tween<double>(begin: 1, end: 1.12).animate(
      CurvedAnimation(parent: _exitController, curve: Curves.easeInOut),
    );

    _startAnimation();
  }

  Future<void> _startAnimation() async {
    await _introController.forward();
    await Future.delayed(const Duration(milliseconds: 2200));

    if (!mounted) return;
    await _exitController.forward();

    if (!mounted) return;
    Navigator.pushReplacementNamed(context, '/login');
  }

  @override
  void dispose() {
    _introController.dispose();
    _leafController.dispose();
    _exitController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F5238),
      body: AnimatedBuilder(
        animation: Listenable.merge([
          _introController,
          _leafController,
          _exitController,
        ]),
        builder: (context, child) {
          return Opacity(
            opacity: _exitOpacity.value,
            child: Transform.scale(
              scale: _exitScale.value,
              child: Stack(
                children: [
                  _animatedLeaves(),
                  Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SlideTransition(
                          position: _logoSlide,
                          child: Opacity(
                            opacity: _logoOpacity.value,
                            child: Transform.scale(
                              scale: _logoScale.value,
                              child: Image.asset(
                                'assets/images/ecograb_logo.png',
                                width: 210,
                                height: 210,
                                fit: BoxFit.contain,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        SlideTransition(
                          position: _textSlide,
                          child: Opacity(
                            opacity: _textOpacity.value,
                            child: RichText(
                              text: TextSpan(
                                children: [
                                  TextSpan(
                                    text: 'ECO',
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 52,
                                      fontWeight: FontWeight.w900,
                                      letterSpacing: 2.7,
                                      color: Colors.white,
                                    ),
                                  ),
                                  TextSpan(
                                    text: 'GRAB',
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 52,
                                      fontWeight: FontWeight.w900,
                                      letterSpacing: 2.7,
                                      color: const Color(0xFF7BCB5A),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _animatedLeaves() {
    return Stack(
      children: [
        Positioned(
          left: -125,
          bottom: -10 + _leafMove.value,
          child: Transform.rotate(
            angle: -0.50 + _leafRotate.value,
            child: Icon(
              Icons.eco,
              size: 360,
              color: const Color(0xFF7BCB5A).withValues(alpha: 0.16),
            ),
          ),
        ),
        Positioned(
          right: -105,
          bottom: 65 - _leafMove.value,
          child: Transform.rotate(
            angle: 0.58 - _leafRotate.value,
            child: Icon(
              Icons.eco,
              size: 310,
              color: Colors.white.withValues(alpha: 0.085),
            ),
          ),
        ),
        Positioned(
          right: 35,
          top: 95 + _leafMove.value,
          child: Transform.rotate(
            angle: -0.35 + _leafRotate.value,
            child: Icon(
              Icons.eco,
              size: 125,
              color: Colors.white.withValues(alpha: 0.075),
            ),
          ),
        ),
        Positioned(
          left: 28,
          top: 145 - _leafMove.value,
          child: Transform.rotate(
            angle: 0.65 - _leafRotate.value,
            child: Icon(
              Icons.eco,
              size: 92,
              color: const Color(0xFF7BCB5A).withValues(alpha: 0.09),
            ),
          ),
        ),
      ],
    );
  }
}