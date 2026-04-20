import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:food_waste_app/data/services/api_client.dart';
import 'package:food_waste_app/data/models/product.dart';
import 'package:food_waste_app/data/models/restaurant.dart';
import 'package:food_waste_app/core/app_state.dart';
import 'living_larder_login_screen.dart';
import 'product_detail_screen.dart';
import 'restaurant_detail_screen.dart';

class RescueHomeScreen extends StatefulWidget {
  const RescueHomeScreen({super.key});

  @override
  State<RescueHomeScreen> createState() => _RescueHomeScreenState();
}

class _RescueHomeScreenState extends State<RescueHomeScreen> {
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

  final _apiClient = ApiClient();

  List<Product> _flashProducts = [];
  List<Restaurant> _restaurants = [];
  bool _loading = true;
  String _error = '';
  int _selectedNav = 0;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _loading = true;
      _error = '';
    });
    try {
      final results = await Future.wait([
        _apiClient.getProducts(minDiscountPercent: 20),
        _apiClient.getRestaurants(),
      ]);
      if (mounted) {
        setState(() {
          _flashProducts = results[0] as List<Product>;
          _restaurants = results[1] as List<Restaurant>;
        });
      }
    } on ApiException catch (e) {
      if (mounted) setState(() => _error = e.message);
    } catch (_) {
      if (mounted) setState(() => _error = 'Veri yuklenemedi. Sunucuyu kontrol edin.');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _logout() {
    AppState.clear();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const LivingLarderLoginScreen()),
    );
  }

  void _openFirstProduct() {
    if (_flashProducts.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Gosterilecek urun bulunamadi.')),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (ctx) => ProductDetailScreen(
          product: _flashProducts.first,
          apiClient: _apiClient,
        ),
      ),
    );
  }

  Future<void> _openFirstRestaurant() async {
    if (_restaurants.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Gosterilecek restoran bulunamadi.')),
      );
      return;
    }

    try {
      final detail = await _apiClient.getRestaurantDetail(_restaurants.first.id);
      if (!mounted) return;
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (ctx) => RestaurantDetailScreen(
            restaurant: detail,
            apiClient: _apiClient,
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    }
  }

  void _handleNavTap(int index) {
    setState(() => _selectedNav = index);

    if (index == 1) {
      _openFirstRestaurant();
      return;
    }

    if (index == 2) {
      _openFirstProduct();
      return;
    }

    if (index == 3) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const LivingLarderLoginScreen()),
      );
    }
  }

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
                automaticallyImplyLeading: false,
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
                              'Konum',
                              style: GoogleFonts.manrope(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 1.2,
                                color: _onSurfaceVariant.withValues(alpha: 0.6),
                              ),
                            ),
                            Text(
                              AppState.isLoggedIn
                                  ? AppState.currentUser!.fullName
                                  : 'Misafir',
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
                      GestureDetector(
                        onTap: _openFirstProduct,
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.transparent,
                          ),
                          child: const Icon(Icons.search, color: _onSurfaceVariant),
                        ),
                      ),
                      const SizedBox(width: 12),
                      GestureDetector(
                        onTap: AppState.isLoggedIn ? _logout : null,
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(999),
                            color: _surfaceContainerHighest,
                            border: Border.all(
                              color: _primary.withValues(alpha: 0.1),
                              width: 2,
                            ),
                          ),
                          child: const Icon(Icons.person, color: _onSurfaceVariant),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: _loading
                    ? const Padding(
                        padding: EdgeInsets.symmetric(vertical: 60),
                        child: Center(
                          child: CircularProgressIndicator(
                            color: _primary,
                          ),
                        ),
                      )
                    : _error.isNotEmpty
                        ? Padding(
                            padding: const EdgeInsets.all(32),
                            child: Column(
                              children: [
                                Icon(Icons.cloud_off,
                                    size: 48,
                                    color: _onSurfaceVariant.withValues(alpha: 0.4)),
                                const SizedBox(height: 16),
                                Text(
                                  _error,
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.manrope(
                                    fontSize: 14,
                                    color: _onSurfaceVariant,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                ElevatedButton.icon(
                                  onPressed: _loadData,
                                  icon: const Icon(Icons.refresh),
                                  label: const Text('Tekrar Dene'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: _primary,
                                    foregroundColor: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          )
                        : Padding(
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

  // ── Categories ────────────────────────────────────────────────────────────

  Widget _categories() {
    final categories = [
      ('Market', Icons.storefront, _primaryFixed, const Color(0x66FFFFFF), const Color(0xFF002114)),
      ('Cafe', Icons.coffee, _surfaceContainerHigh, const Color(0xCCFFFFFF), _onSurfaceVariant),
      ('Bakery', Icons.bakery_dining, _surfaceContainerHigh, const Color(0xCCFFFFFF), _onSurfaceVariant),
      ('Juice', Icons.local_drink, _surfaceContainerHigh, const Color(0xCCFFFFFF), _onSurfaceVariant),
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
                  decoration: BoxDecoration(color: item.$4, shape: BoxShape.circle),
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

  // ── Flash Rescues ─────────────────────────────────────────────────────────

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
                      'Flash Kurtarmalar',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        color: _onSurface,
                        height: 1.1,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Son gunem, en dusuk fiyat.',
                      style: GoogleFonts.manrope(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: _onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              GestureDetector(
                onTap: _openFirstProduct,
                child: Text(
                  'Tumunu Gor',
                  style: GoogleFonts.manrope(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: _primary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (_flashProducts.isEmpty)
            _emptyState('Indirimli urun bulunamadi.')
          else ...[
            _productHeroCard(_flashProducts.first),
            if (_flashProducts.length > 1) ...[
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _smallProductCard(_flashProducts[1]),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _flashProducts.length > 2
                        ? _smallProductCard(_flashProducts[2])
                        : const SizedBox.shrink(),
                  ),
                ],
              ),
            ],
          ],
        ],
      ),
    );
  }

  Widget _productHeroCard(Product p) {
    final discount = p.discountPercent.toStringAsFixed(0);
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (ctx) => ProductDetailScreen(
              product: p,
              apiClient: _apiClient,
            ),
          ),
        );
      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: SizedBox(
          height: 192,
          child: Stack(
            fit: StackFit.expand,
            children: [
              Container(
                color: _surfaceContainer,
                child: const Icon(Icons.fastfood, size: 64, color: Colors.white54),
              ),
              DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [
                      Colors.black.withValues(alpha: 0.8),
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
                        _tag('-$discount% İNDİRİM', _secondary, Colors.white),
                        const SizedBox(width: 8),
                        _tag('${p.stock} ADET', _primary, Colors.white),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      p.name,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      p.restaurantName,
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
      ),
    );
  }

  Widget _smallProductCard(Product p) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (ctx) => ProductDetailScreen(
              product: p,
              apiClient: _apiClient,
            ),
          ),
        );
      },
      child: Container(
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
                    Container(
                      color: _surfaceContainerHigh,
                      child: const Icon(Icons.restaurant, color: Colors.white60),
                    ),
                    if (p.stock <= 1)
                      Positioned(
                        top: 8,
                        right: 8,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                          decoration: BoxDecoration(
                            color: _secondaryContainer,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            'SON',
                            style: GoogleFonts.manrope(
                              fontSize: 8,
                              fontWeight: FontWeight.w900,
                              color: const Color(0xFF5C2400),
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
              p.name,
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
                  '₺${p.discountedPrice.toStringAsFixed(2)}',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: _secondary,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '₺${p.originalPrice.toStringAsFixed(2)}',
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
      ),
    );
  }

  // ── Nearby Kitchens ───────────────────────────────────────────────────────

  Widget _nearbySection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Yakin Mutfaklar',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              color: _onSurface,
              height: 1.1,
            ),
          ),
          const SizedBox(height: 24),
          if (_restaurants.isEmpty)
            _emptyState('Restoran bulunamadi.')
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _restaurants.length > 5 ? 5 : _restaurants.length,
              separatorBuilder: (_, __) => const SizedBox(height: 32),
              itemBuilder: (_, i) => _restaurantCard(_restaurants[i]),
            ),
        ],
      ),
    );
  }

  Widget _restaurantCard(Restaurant r) {
    final distText = r.distanceKm != null
        ? '${r.distanceKm!.toStringAsFixed(1)} km • '
        : '';
    return GestureDetector(
      onTap: () async {
        try {
          final detail = await _apiClient.getRestaurantDetail(r.id);
          if (mounted) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (ctx) => RestaurantDetailScreen(
                  restaurant: detail,
                  apiClient: _apiClient,
                ),
              ),
            );
          }
        } catch (e) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  e.toString().replaceAll('ApiException: ', ''),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                backgroundColor: Colors.red.shade400,
              ),
            );
          }
        }
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: AspectRatio(
              aspectRatio: 16 / 10,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Color(0xFF2D6A4F), Color(0xFF0F5238)],
                      ),
                    ),
                    child: const Icon(Icons.storefront, size: 56, color: Colors.white30),
                  ),
                  Positioned(
                    top: 16,
                    left: 16,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: _surface.withValues(alpha: 0.9),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.location_city, size: 14, color: _secondary),
                          const SizedBox(width: 6),
                          Text(
                            r.city,
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
          Text(
            r.name,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: _onSurface,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '$distText${r.address}',
            style: GoogleFonts.manrope(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: _onSurfaceVariant,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  Widget _tag(String text, Color bg, Color fg) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(999)),
      child: Text(
        text,
        style: GoogleFonts.manrope(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: fg,
          letterSpacing: 0.9,
        ),
      ),
    );
  }

  Widget _emptyState(String msg) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Center(
        child: Text(
          msg,
          style: GoogleFonts.manrope(fontSize: 14, color: _onSurfaceVariant),
        ),
      ),
    );
  }

  // ── Bottom Nav ────────────────────────────────────────────────────────────

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
            _navItem(0, 'Anasayfa', Icons.home, Icons.home),
            _navItem(1, 'Harita', Icons.map_outlined, Icons.map),
            _navItem(2, 'Siparisler', Icons.receipt_long_outlined, Icons.receipt_long),
            _navItem(3, 'Profil', Icons.person_outline, Icons.person),
          ],
        ),
      ),
    );
  }

  Widget _navItem(int index, String label, IconData icon, IconData activeIcon) {
    final active = _selectedNav == index;
    final textStyle = GoogleFonts.manrope(fontSize: 11, fontWeight: FontWeight.w500);

    if (active) {
      return GestureDetector(
        onTap: () => _handleNavTap(index),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
          decoration: BoxDecoration(
            color: _primaryFixed,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(activeIcon, color: const Color(0xFF002114)),
              Text(label, style: textStyle.copyWith(color: const Color(0xFF002114))),
            ],
          ),
        ),
      );
    }

    return GestureDetector(
      onTap: () => _handleNavTap(index),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: _onSurfaceVariant),
          Text(label, style: textStyle.copyWith(color: _onSurfaceVariant)),
        ],
      ),
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
            BoxShadow(color: Color(0x0F191C1B), blurRadius: 24, offset: Offset(0, 8)),
          ],
        ),
        child: const Icon(Icons.bolt, color: Colors.white, size: 28),
      ),
    );
  }
}
