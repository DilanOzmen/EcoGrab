import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:food_waste_app/screens/living_larder_login_screen.dart';

void main() {
  runApp(const FoodWasteApp());
}

class FoodWasteApp extends StatelessWidget {
  const FoodWasteApp({super.key});

  @override
  Widget build(BuildContext context) {
    const background = Color(0xFFF8FAF8);
    const onSurface = Color(0xFF191C1B);

    final baseTextTheme = ThemeData.light().textTheme;

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Food Waste App',
      theme: ThemeData(
        scaffoldBackgroundColor: background,
        colorScheme: const ColorScheme.light(
          primary: Color(0xFF0F5238),
          surface: background,
          onSurface: onSurface,
        ),
        textTheme: GoogleFonts.manropeTextTheme(baseTextTheme).copyWith(
          headlineLarge: GoogleFonts.plusJakartaSans(),
          headlineMedium: GoogleFonts.plusJakartaSans(),
          headlineSmall: GoogleFonts.plusJakartaSans(),
          titleLarge: GoogleFonts.plusJakartaSans(),
          titleMedium: GoogleFonts.plusJakartaSans(),
          titleSmall: GoogleFonts.plusJakartaSans(),
        ),
      ),
      home: const LivingLarderLoginScreen(),
    );
  }
}

class RescueHomeScreen extends StatelessWidget {
  const RescueHomeScreen({super.key});

  static const _surface = Color(0xFFF8FAF8);
  static const _onSurface = Color(0xFF191C1B);
  static const _onSurfaceVariant = Color(0xFF404943);
  static const _primary = Color(0xFF0F5238);
  static const _primaryFixed = Color(0xFFB1F0CE);
  static const _secondary = Color(0xFF9D4300);
  static const _secondaryContainer = Color(0xFFFD761A);
  static const _surfaceContainer = Color(0xFFECEEEC);
  static const _surfaceContainerHigh = Color(0xFFE6E9E7);
  static const _surfaceContainerHighest = Color(0xFFE1E3E1);
  static const _surfaceContainerLowest = Color(0xFFFFFFFF);
  static const _tertiaryFixedDim = Color(0xFFFFBB18);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              SliverAppBar(
                pinned: true,
                elevation: 0,
                backgroundColor: _surface,
                toolbarHeight: 80,
                titleSpacing: 0,
                title: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Row(
                    children: [
                      const Icon(Icons.location_on, color: _primary),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Current Location',
                              style: GoogleFonts.manrope(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 1.2,
                                color: _onSurfaceVariant.withValues(alpha: 0.6),
                              ),
                            ),
                            Text(
                              'Artisan District, SE1',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: _primary,
                                height: 1.1,
                              ),
                            ),
                          ],
                        ),
                      ),
                      _iconCircleButton(icon: Icons.search),
                      const SizedBox(width: 12),
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(999),
                          color: _surfaceContainerHighest,
                          border: Border.all(
                            color: _primary.withValues(alpha: 0.1),
                            width: 2,
                          ),
                          image: const DecorationImage(
                            image: NetworkImage(
                              'https://lh3.googleusercontent.com/aida-public/AB6AXuDCq7NfWzGrUjTD7I07J3LlY3oChpfZHVjKv0fE0jVHhDCZm8Wh4G8z5hNUhN2lAMcZBysOuv3Tic5AtT90scWSmKnY50N5bAxt-VhRuLGXmsFPC3w9PxatjI85NLuUnI7CxDSTzQJ6u13NMWQepXeTc7ezXQLxhpGZH76Lttp0NjcAAPfujG1qj9ryY4wBSRPU8eM0i0kodV6vhyNx3y2CVGeu4AzsLoWOPHVE9RcNXqFBmjv7K6VmGYtZxFJMvEVOx9TOz0c4slUe',
                            ),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 132),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 12),
                      _categories(),
                      const SizedBox(height: 24),
                      _featuredSection(),
                      const SizedBox(height: 32),
                      _nearbySection(),
                    ],
                  ),
                ),
              ),
            ],
          ),
          _bottomNavBar(),
          _quickRescueFab(),
        ],
      ),
    );
  }

  Widget _iconCircleButton({required IconData icon}) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.transparent,
      ),
      child: Icon(icon, color: _onSurfaceVariant),
    );
  }

  Widget _categories() {
    final categories = [
      (
        'Market',
        Icons.storefront,
        _primaryFixed,
        const Color(0x66FFFFFF),
        const Color(0xFF002114),
      ),
      (
        'Cafe',
        Icons.coffee,
        _surfaceContainerHigh,
        const Color(0xCCFFFFFF),
        _onSurfaceVariant,
      ),
      (
        'Bakery',
        Icons.bakery_dining,
        _surfaceContainerHigh,
        const Color(0xCCFFFFFF),
        _onSurfaceVariant,
      ),
      (
        'Juice',
        Icons.local_drink,
        _surfaceContainerHigh,
        const Color(0xCCFFFFFF),
        _onSurfaceVariant,
      ),
    ];

    return SizedBox(
      height: 122,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        separatorBuilder: (_, __) => const SizedBox(width: 16),
        itemBuilder: (context, index) {
          final item = categories[index];
          return Container(
            width: 80,
            decoration: BoxDecoration(
              color: item.$3,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: item.$4,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(item.$2, color: item.$5),
                ),
                const SizedBox(height: 10),
                Text(
                  item.$1,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: item.$5,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _featuredSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Flash Rescues',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        color: _onSurface,
                        height: 1.1,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Expiring soon, priced to save.',
                      style: GoogleFonts.manrope(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: _onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                'View all',
                style: GoogleFonts.manrope(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: _primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _heroCard(),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _smallFlashCard(
                  image:
                      'https://lh3.googleusercontent.com/aida-public/AB6AXuDtBa0AFt0s40xlUDn1bBoeH3WflBs_vmbj9Jwlax9W3cbowyJfbXag7c2Gr4ItRP2LdQb0-zWu8BxbB_IOs0t9Y4uk0qMb2tuYTK1-hq2Wcz_1HoQqjUWyUb0Ttlx8hGrSrC8PnZS8iWPGwG_RnCTmoN5P2Bx0FagHJ1jOUwMI1pcU_RLgf2iJVYT-hi4u4e1fDhMNF2AOw_CaAyN706D-gnggveVLeJR41ereS9x9Jj80ohYiGJdu091mPQSI0mhgylkMnfLVT6AI',
                  title: 'Sourdough Loaf',
                  price: r'$2.50',
                  oldPrice: r'$6.00',
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _smallFlashCard(
                  image:
                      'https://lh3.googleusercontent.com/aida-public/AB6AXuCRI0TuEBcSst_QGUiK921wRjI9hp0Qesfjv5vKKzvnKty-U7HWxOCAMc_UAC5aiHvBH_3BZJgNvIusodfoKujhQU-Cj8aQ5eGj2zo1e9y9FpnhVh-vcKuyUlqjwSNp916LfysvH-UybwXdpzKFH_2gbn-Y_Si2Jqw9OUYdlrfqb95DWxnCXKmtdcztwZ2yG7N8g6_OF0IhZa3jBosF6_9-J1qwTzZxz8M_TKKJTAGnE5gmO6PUL0XiiR1zopbkG43_JTJpwa1ki4RT',
                  title: 'Berry Medley',
                  price: r'$3.90',
                  oldPrice: r'$8.50',
                  chip: 'LAST ONE',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _heroCard() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: SizedBox(
        height: 192,
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.network(
              'https://lh3.googleusercontent.com/aida-public/AB6AXuAtKLfhYv9_cH16k4fd6l47SBko1MJStbzmp-gLf3S3GCLkArO250lKIUiKjWu8vOlrOcVTXH6baCZ4AMQHnKtpu8gjb0TkxHuR8Y0autnO9-2usy-BX6UkgL1jFPTQUFcvtY3zYcyXbTldi_jEHW7yQEPUgvUQkAYH6hjCUREwSV9uLGKLl0EtiGqp9UddYkmmLJwJhYwk8Ik-B07OEAAA3a3THEh9xIDEPwEvICo267sonF_Rd1Tmd6Fm5FA2idEh8triMY0HdM1Q',
              fit: BoxFit.cover,
            ),
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.8),
                    Colors.black.withValues(alpha: 0.2),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
            Positioned(
              left: 16,
              right: 16,
              bottom: 16,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      _tag('-60% OFF', _secondary, Colors.white),
                      const SizedBox(width: 8),
                      _tag('3 LEFT', _primary, Colors.white),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Daily Harvest Box',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    'Whole Foods Market • 0.4 mi',
                    style: GoogleFonts.manrope(
                      fontSize: 12,
                      color: Colors.white.withValues(alpha: 0.8),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _smallFlashCard({
    required String image,
    required String title,
    required String price,
    required String oldPrice,
    String? chip,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0F191C1B),
            blurRadius: 24,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: AspectRatio(
              aspectRatio: 1,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(image, fit: BoxFit.cover),
                  if (chip != null)
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: _secondaryContainer,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          chip,
                          style: GoogleFonts.manrope(
                            fontSize: 8,
                            fontWeight: FontWeight.w900,
                            color: const Color(0xFF5C2400),
                            letterSpacing: 0.3,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: _onSurface,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Text(
                price,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: _secondary,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                oldPrice,
                style: GoogleFonts.manrope(
                  fontSize: 10,
                  color: _onSurfaceVariant.withValues(alpha: 0.5),
                  decoration: TextDecoration.lineThrough,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _tag(String text, Color background, Color foreground) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        text,
        style: GoogleFonts.manrope(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: foreground,
          letterSpacing: 0.9,
        ),
      ),
    );
  }

  Widget _nearbySection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Nearby Kitchens',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              color: _onSurface,
              height: 1.1,
            ),
          ),
          const SizedBox(height: 24),
          _storeCard(
            image:
                'https://lh3.googleusercontent.com/aida-public/AB6AXuApgfO0PtQ7hS7SfSKuBv0_LgcpW7HhB8BvBCLBEP34UvTx4FJJidSj3E230N-rtYBJp4urluD8VVv30e9Riicm3t605TwylFnCOmBLwFPLHYHB5nWFJaH70Tl7IgUNe7hdnvvS7NUu_kOIno8nhYzVfMzoYe-Y1GEvK2PZ9IeYORxtVKEFvctQYPmSrYTQ-VUIvCPVqJ9T0kZxm02D8UGJgkhMULG1aqZIE7ShqIcSnuxB9wUYmS9EUR-rGL90WkBdTq-cs2e_KKfZ',
            name: "L'Artisan Bakery",
            rating: '4.8',
            details: '0.2 mi • French • \$',
            price: r'$4.99',
            subtitle: 'Bag of Surprises',
            pickupText: 'Pickup before 8 PM',
            availabilityText: '7 items remaining today',
            progress: 0.75,
          ),
          const SizedBox(height: 32),
          _storeCard(
            image:
                'https://lh3.googleusercontent.com/aida-public/AB6AXuBTTFcacJj8aOxmKTCwNTkYx4-rb3QY_LjyTZJ58UEcqL-k7AckGRf2r6qI5xYwWbLgCkhfmlPNGWdLhDTnA5DGX4d-ZV0_FF1zXr1mD2XMAfL1vvhq7Yk-ZFsmtMw1VLed-sqfFXyT47ujlCEfRUIE8oPL9TbcgDIKN4F1RTp5djP4W_lQZNk3qwmYKaJTmiLOcpgJSzl-w8Ib-aF02cg38hUbfwLZrDIrUJDRwwJcAc0LuATGYHRkidCqUr5WWW6Uog1qVpYumTwM',
            name: 'Earthbound Organics',
            rating: '4.5',
            details: '1.1 mi • Market • \$\$',
            price: r'$6.50',
            subtitle: 'Veggie Bundle',
            pickupText: 'Pickup before 6 PM',
            availabilityText: 'Only 2 bundles left',
            progress: 0.25,
          ),
        ],
      ),
    );
  }

  Widget _storeCard({
    required String image,
    required String name,
    required String rating,
    required String details,
    required String price,
    required String subtitle,
    required String pickupText,
    required String availabilityText,
    required double progress,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: AspectRatio(
            aspectRatio: 16 / 10,
            child: Stack(
              fit: StackFit.expand,
              children: [
                Image.network(image, fit: BoxFit.cover),
                Positioned(
                  top: 16,
                  left: 16,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: _surface.withValues(alpha: 0.9),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.timer,
                          size: 14,
                          color: _secondary,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          pickupText,
                          style: GoogleFonts.manrope(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: _onSurface,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: _onSurface,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.star, color: _tertiaryFixedDim, size: 16),
                      const SizedBox(width: 4),
                      Text(
                        rating,
                        style: GoogleFonts.manrope(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: _onSurface,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '•',
                        style: GoogleFonts.manrope(
                          fontSize: 12,
                          color: _onSurfaceVariant.withValues(alpha: 0.3),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        details,
                        style: GoogleFonts.manrope(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: _onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  price,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                    color: _primary,
                    height: 1,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  subtitle.toUpperCase(),
                  style: GoogleFonts.manrope(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: _onSurfaceVariant.withValues(alpha: 0.6),
                    letterSpacing: 0.8,
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 16),
        ClipRRect(
          borderRadius: BorderRadius.circular(999),
          child: SizedBox(
            height: 4,
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: _surfaceContainer,
              valueColor: const AlwaysStoppedAnimation<Color>(_secondary),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          availabilityText.toUpperCase(),
          style: GoogleFonts.manrope(
            fontSize: 10,
            fontWeight: FontWeight.w500,
            color: _onSurfaceVariant,
            letterSpacing: 1.2,
          ),
        ),
      ],
    );
  }

  Widget _bottomNavBar() {
    return Positioned(
      left: 0,
      right: 0,
      bottom: 0,
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
        decoration: BoxDecoration(
          color: _surface.withValues(alpha: 0.8),
          border: Border(
            top: BorderSide(color: const Color(0xFFBFC9C1).withValues(alpha: 0.15)),
          ),
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
          boxShadow: const [
            BoxShadow(
              color: Color(0x0F191C1B),
              blurRadius: 24,
              offset: Offset(0, -8),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _navItem('Home', Icons.home, active: true),
            _navItem('Map', Icons.map),
            _navItem('Orders', Icons.receipt_long),
            _navItem('Profile', Icons.person),
          ],
        ),
      ),
    );
  }

  Widget _navItem(String label, IconData icon, {bool active = false}) {
    final textStyle = GoogleFonts.manrope(
      fontSize: 11,
      fontWeight: FontWeight.w500,
    );

    if (active) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
        decoration: BoxDecoration(
          color: _primaryFixed,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.home, color: Color(0xFF002114)),
            Text(label, style: textStyle.copyWith(color: const Color(0xFF002114))),
          ],
        ),
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: _onSurfaceVariant),
        Text(label, style: textStyle.copyWith(color: _onSurfaceVariant)),
      ],
    );
  }

  Widget _quickRescueFab() {
    return Positioned(
      right: 24,
      bottom: 96,
      child: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [_primary, Color(0xFF2D6A4F)],
          ),
          boxShadow: const [
            BoxShadow(
              color: Color(0x0F191C1B),
              blurRadius: 24,
              offset: Offset(0, 8),
            ),
          ],
        ),
        child: const Icon(Icons.bolt, color: Colors.white, size: 28),
      ),
    );
  }
}

class SellerHomePage extends StatelessWidget {
  const SellerHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Satici Paneli')),
      body: const Center(
        child: Text('Satici urun yonetimi ve siparis durum guncelleme API hazir.'),
      ),
    );
  }
}
