import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';

import 'package:food_waste_app/screens/chatbot_screen.dart';
import 'package:food_waste_app/core/app_colors.dart';
import 'package:food_waste_app/core/app_state.dart';
import 'package:food_waste_app/data/models/customer_order.dart';
import 'package:food_waste_app/data/models/product.dart';
import 'package:food_waste_app/data/models/restaurant.dart';
import 'package:food_waste_app/data/services/api_client.dart';
import 'package:food_waste_app/data/services/location_service.dart';
import 'package:food_waste_app/core/app_assets.dart';

import 'login_screen.dart';
import 'map_view_screen.dart';
import 'order_tracking_screen.dart';
import 'product_detail_screen.dart';
import 'profile_screen.dart';
import 'restaurant_detail_screen.dart';

class RescueHomeScreen extends StatefulWidget {
  final int initialIndex;
  final ApiClient apiClient;

  const RescueHomeScreen({
    super.key,
    this.initialIndex = 0,
    required this.apiClient,
  });

  @override
  State<RescueHomeScreen> createState() => _RescueHomeScreenState();
}

class _RescueHomeScreenState extends State<RescueHomeScreen>
    with SingleTickerProviderStateMixin {
  int _selectedIndex = 0;
  _HomeCategoryFilter _selectedHomeFilter = _HomeCategoryFilter.all;

  late final ApiClient _apiClient;
  late Future<_HomeData> _homeFuture;
  late Future<List<CustomerOrder>> _ordersFuture;

  late final AnimationController _controller;
  late final Animation<double> _fade;
  late final Animation<Offset> _slide;

  Timer? _chatBotTimer;
  bool _isChatBotOpen = false;

  @override
  void initState() {
    super.initState();

    _apiClient = widget.apiClient;
    _selectedIndex = widget.initialIndex;

    _homeFuture = _bootstrapHomeData();
    _ordersFuture = _loadOrdersData();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );

    _fade = CurvedAnimation(parent: _controller, curve: Curves.easeOut);

    _slide = Tween<Offset>(
      begin: const Offset(0, 0.05),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));

    _controller.forward();

    _chatBotTimer = Timer.periodic(const Duration(seconds: 4), (_) {
      if (!mounted) return;
      setState(() {
        _isChatBotOpen = !_isChatBotOpen;
      });
    });
  }

  @override
  void dispose() {
    _chatBotTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  Future<_HomeData> _bootstrapHomeData() async {
    try {
      await LocationService.fetchAndSaveLocation();
    } catch (_) {}

    return _loadHomeData(_HomeCategoryFilter.all);
  }

  Future<_HomeData> _loadHomeData([_HomeCategoryFilter? filter]) async {
    final selectedFilter = filter ?? _selectedHomeFilter;

    final Future<List<Product>> productsFuture;
    if (selectedFilter == _HomeCategoryFilter.all) {
      productsFuture = _apiClient.getProducts(
        latitude: AppState.latitude,
        longitude: AppState.longitude,
      );
    } else {
      productsFuture = _apiClient.getFilteredProducts(selectedFilter.apiValue);
    }

    final results = await Future.wait([
      productsFuture,
      _apiClient.getRestaurants(
        latitude: AppState.latitude,
        longitude: AppState.longitude,
        radiusKm: 10,
      ),
    ]);

    final products = results[0] as List<Product>;
    final restaurants = results[1] as List<Restaurant>;

    return _HomeData(products: products, restaurants: restaurants);
  }

  Future<List<CustomerOrder>> _loadOrdersData() async {
    final results = await Future.wait([
      _apiClient.getMyOrders(),
      _apiClient.getMyReservations(),
    ]);

    final merged = <CustomerOrder>[...results[0], ...results[1]];
    final unique = <int, CustomerOrder>{};

    for (final order in merged) {
      unique[order.id] = order;
    }

    final list = unique.values.toList();
    list.sort((a, b) => b.createdAt.compareTo(a.createdAt));

    return list;
  }

  Future<void> _refreshHome() async {
    final future = _loadHomeData();
    setState(() {
      _homeFuture = future;
    });
    await future;
  }

  Future<void> _refreshOrders() async {
    final future = _loadOrdersData();
    setState(() {
      _ordersFuture = future;
    });
    await future;
  }

  Future<void> _logout() async {
    AppState.clear();

    if (!mounted) return;

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }

  Future<void> _openRestaurantDetail(Restaurant restaurant) async {
    try {
      final detail = await _apiClient.getRestaurantDetail(restaurant.id);

      if (!mounted) return;

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) =>
              RestaurantDetailScreen(restaurant: detail, apiClient: _apiClient),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceAll('ApiException: ', ''))),
      );
    }
  }

  Future<void> _openProductDetail(Product product) async {
    final changed = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) =>
            ProductDetailScreen(product: product, apiClient: _apiClient),
      ),
    );

    if (changed == true && mounted) {
      _refreshHome();
    }
  }

  void _selectHomeCategory(_HomeCategoryFilter filter) {
    if (_selectedHomeFilter == filter) return;

    setState(() {
      _selectedHomeFilter = filter;
      _homeFuture = _loadHomeData(filter);
    });
  }

  Widget _buildBody() {
    switch (_selectedIndex) {
      case 0:
        return _buildHomeTab();
      case 1:
        return const MapViewScreen();
      case 2:
        return _buildOrdersTab();
      case 3:
        return ProfileScreen(
          apiClient: _apiClient,
          onLogout: _logout,
          onOrdersTap: () {
            setState(() {
              _selectedIndex = 2;
              _ordersFuture = _loadOrdersData();
            });
          },
        );
      default:
        return _buildHomeTab();
    }
  }

  Widget _buildLocationBar() {
    final address = AppState.currentAddress ?? "Konum alındı";

    return GestureDetector(
      onTap: () async {
        await LocationService.fetchAndSaveLocation();
        _refreshHome();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.primaryGreen.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.location_on_rounded,
              color: AppColors.primaryGreen,
              size: 16,
            ),
            const SizedBox(width: 6),
            Text(
              address,
              style: GoogleFonts.manrope(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: AppColors.primaryGreen,
              ),
            ),
            const SizedBox(width: 4),
            const Icon(
              Icons.keyboard_arrow_down_rounded,
              color: AppColors.primaryGreen,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHomeTab() {
    return SafeArea(
      child: FutureBuilder<_HomeData>(
        future: _homeFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primaryGreen),
            );
          }

          if (snapshot.hasError) {
            return _buildErrorState(
              title: 'Veriler yüklenemedi',
              message: snapshot.error.toString().replaceAll(
                    'ApiException: ',
                    '',
                  ),
            );
          }

          final data = snapshot.data;

          if (data == null) {
            return _buildEmptyState(
              icon: Icons.eco_rounded,
              title: 'Veri bulunamadı',
              message: 'Şu anda gösterilecek içerik yok.',
            );
          }

          return RefreshIndicator(
            color: AppColors.primaryGreen,
            onRefresh: _refreshHome,
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 30),
              children: [
                FadeTransition(
                  opacity: _fade,
                  child: SlideTransition(
                    position: _slide,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildTopHeader(),
                        const SizedBox(height: 12),
                        _buildLocationBar(),
                        const SizedBox(height: 18),
                        _buildHeroCard(data),
                        const SizedBox(height: 22),
                        _buildCategories(),
                        const SizedBox(height: 22),
                        _sectionTitle(
                          _selectedHomeFilter == _HomeCategoryFilter.all
                              ? 'Flaş Ürünler'
                              : '${_selectedHomeFilter.label} Ürünleri',
                          'Bugünün en avantajlı ürünleri',
                        ),
                        const SizedBox(height: 12),
                        if (data.products.isEmpty)
                          _buildEmptyState(
                            icon: Icons.shopping_bag_outlined,
                            title: 'Ürün bulunamadı',
                            message: 'Bu kategoride listelenen ürün yok.',
                          )
                        else
                          _buildHorizontalProductList(data.products),
                        const SizedBox(height: 24),
                        _sectionTitle(
                          'Restoranlar',
                          'Yakındaki kurtarılabilir ürünler',
                        ),
                        const SizedBox(height: 12),
                        if (data.restaurants.isEmpty)
                          _buildEmptyState(
                            icon: Icons.storefront_outlined,
                            title: 'Restoran bulunamadı',
                            message: 'Şu anda listelenen restoran yok.',
                          )
                        else
                          _buildHorizontalRestaurantList(data.restaurants),
                        const SizedBox(height: 24),
                        _sectionTitle('Tüm Ürünler', 'Kaçırmadan göz at'),
                        const SizedBox(height: 12),
                        if (data.products.isEmpty)
                          _buildEmptyState(
                            icon: Icons.inventory_2_outlined,
                            title: 'Liste boş',
                            message: 'Henüz ürün eklenmemiş.',
                          )
                        else
                          ...data.products
                              .take(8)
                              .map((product) => _buildSimpleProductCard(product)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildTopHeader() {
    final fullName = AppState.currentUser?.fullName ?? 'Kullanıcı';
    final initial = fullName.isNotEmpty ? fullName[0].toUpperCase() : 'U';

    return Row(
      children: [
        AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            final scale = Curves.elasticOut.transform(_controller.value);

            return Transform.scale(
              scale: scale,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: 76,
                    height: 76,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.primaryGreen.withValues(alpha: 0.06),
                      border: Border.all(
                        color: AppColors.primaryGreen.withValues(alpha: 0.12),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primaryGreen.withValues(alpha: 0.10),
                          blurRadius: 22,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                  ),
                  Positioned(
                    top: 6,
                    right: 10,
                    child: Icon(
                      Icons.eco_rounded,
                      size: 18,
                      color: AppColors.freshGreen.withValues(alpha: 0.75),
                    ),
                  ),
                  Positioned(
                    left: 7,
                    bottom: 12,
                    child: Transform.rotate(
                      angle: -0.7,
                      child: Icon(
                        Icons.eco_rounded,
                        size: 18,
                        color: AppColors.primaryGreen.withValues(alpha: 0.24),
                      ),
                    ),
                  ),
                  Container(
                    width: 56,
                    height: 56,
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                      border: Border.all(
                        color: AppColors.primaryGreen.withValues(alpha: 0.08),
                      ),
                    ),
                    child: Image.asset(
                      AppAssets.ecograbLogo,
                      fit: BoxFit.contain,
                    ),
                  ),
                ],
              ),
            );
          },
        ),

        const SizedBox(width: 14),

        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'EcoGrab',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 21,
                  fontWeight: FontWeight.w900,
                  color: AppColors.primaryGreen,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Daha az israf, daha iyi gelecek.',
                style: GoogleFonts.manrope(
                  fontSize: 12,
                  height: 1.25,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textSoft,
                ),
              ),
            ],
          ),
        ),

        GestureDetector(
          onTap: () {
            setState(() {
              _selectedIndex = 3;
            });
          },
          child: CircleAvatar(
            radius: 22,
            backgroundColor: AppColors.primaryGreen,
            child: Text(
              initial,
              style: GoogleFonts.plusJakartaSans(
                color: Colors.white,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFloatingChatBot() {
    if (_selectedIndex != 0) return const SizedBox.shrink();

    return Positioned(
      right: 0,
      bottom: 128,
      child: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const ChatBotScreen(),
            ),
          );
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 650),
          curve: Curves.easeInOutCubic,
          width: _isChatBotOpen ? 118 : 54,
          height: 64,
          decoration: BoxDecoration(
            color: AppColors.primaryGreen,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(32),
              bottomLeft: Radius.circular(32),
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.primaryGreen.withValues(alpha: 0.30),
                blurRadius: 22,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Row(
            children: [
              if (_isChatBotOpen)
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 14),
                    child: Text(
                      'Yardım\nister misin?',
                      style: GoogleFonts.manrope(
                        color: Colors.white,
                        fontSize: 10,
                        height: 1.15,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ),
              Container(
                width: 54,
                height: 54,
                margin: const EdgeInsets.only(right: 3),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: Padding(
                  padding: const EdgeInsets.all(5),
                  child: Lottie.asset(
                    AppAssets.chatbotRobotLottie,
                    fit: BoxFit.contain,
                    repeat: true,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeroCard(_HomeData data) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: AppColors.splashGradient,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryGreen.withValues(alpha: 0.25),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -34,
            top: -48,
            child: Icon(
              Icons.eco,
              size: 155,
              color: Colors.white.withValues(alpha: 0.08),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Bugün ne kurtarıyoruz?',
                style: GoogleFonts.manrope(
                  color: Colors.white.withValues(alpha: 0.84),
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                '${data.products.length} ürün hazır',
                style: GoogleFonts.plusJakartaSans(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                '${data.restaurants.length} restoran şu anda listede.',
                style: GoogleFonts.manrope(
                  color: Colors.white.withValues(alpha: 0.82),
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  _heroMiniStat(
                    Icons.shopping_bag_outlined,
                    '${data.products.length}',
                    'Ürün',
                  ),
                  const SizedBox(width: 10),
                  _heroMiniStat(
                    Icons.storefront_outlined,
                    '${data.restaurants.length}',
                    'Restoran',
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _heroMiniStat(IconData icon, String value, String label) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.13),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.white, size: 18),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: GoogleFonts.plusJakartaSans(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    fontSize: 15,
                  ),
                ),
                Text(
                  label,
                  style: GoogleFonts.manrope(
                    color: Colors.white.withValues(alpha: 0.72),
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategories() {
    return SizedBox(
      height: 92,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          CategoryChip(
            icon: Icons.grid_view_rounded,
            label: 'Tümü',
            isSelected: _selectedHomeFilter == _HomeCategoryFilter.all,
            onTap: () => _selectHomeCategory(_HomeCategoryFilter.all),
          ),
          CategoryChip(
            icon: Icons.cake_rounded,
            label: 'Tatlılar',
            isSelected: _selectedHomeFilter == _HomeCategoryFilter.tatlilar,
            onTap: () => _selectHomeCategory(_HomeCategoryFilter.tatlilar),
          ),
          CategoryChip(
            icon: Icons.bakery_dining_rounded,
            label: 'Unlu',
            isSelected: _selectedHomeFilter == _HomeCategoryFilter.unluMamuller,
            onTap: () => _selectHomeCategory(_HomeCategoryFilter.unluMamuller),
          ),
          CategoryChip(
            icon: Icons.restaurant_rounded,
            label: 'Yemekler',
            isSelected: _selectedHomeFilter == _HomeCategoryFilter.yemekler,
            onTap: () => _selectHomeCategory(_HomeCategoryFilter.yemekler),
          ),
          CategoryChip(
            icon: Icons.local_cafe_rounded,
            label: 'İçecekler',
            isSelected: _selectedHomeFilter == _HomeCategoryFilter.icecekler,
            onTap: () => _selectHomeCategory(_HomeCategoryFilter.icecekler),
          ),
          CategoryChip(
            icon: Icons.rice_bowl_rounded,
            label: 'Meze',
            isSelected: _selectedHomeFilter == _HomeCategoryFilter.meze,
            onTap: () => _selectHomeCategory(_HomeCategoryFilter.meze),
          ),
          CategoryChip(
            icon: Icons.eco_rounded,
            label: 'Salata',
            isSelected: _selectedHomeFilter == _HomeCategoryFilter.salata,
            onTap: () => _selectHomeCategory(_HomeCategoryFilter.salata),
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(String title, String subtitle) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: GoogleFonts.plusJakartaSans(
            color: AppColors.textDark,
            fontSize: 20,
            fontWeight: FontWeight.w900,
          ),
        ),
        Text(
          subtitle,
          style: GoogleFonts.manrope(
            color: AppColors.textSoft,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildHorizontalProductList(List<Product> products) {
    final visibleProducts = products.take(8).toList();

    return SizedBox(
      height: 210,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: visibleProducts.length,
        separatorBuilder: (_, __) => const SizedBox(width: 14),
        itemBuilder: (context, index) {
          final product = visibleProducts[index];

          return GestureDetector(
            onTap: () => _openProductDetail(product),
            child: Container(
              width: 220,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                gradient: AppColors.editorialGradient,
                borderRadius: BorderRadius.circular(28),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primaryGreen.withValues(alpha: 0.20),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Stack(
                children: [
                  Positioned(
                    right: -28,
                    bottom: -35,
                    child: Icon(
                      Icons.shopping_basket_rounded,
                      size: 130,
                      color: Colors.white.withValues(alpha: 0.08),
                    ),
                  ),
                  Positioned(
                    top: 0,
                    left: 0,
                    child: _discountBadge(product.discountPercent),
                  ),
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 0,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          product.name,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.plusJakartaSans(
                            color: Colors.white,
                            fontSize: 19,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          '${product.restaurantName} • Stok: ${product.stock}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.manrope(
                            color: Colors.white.withValues(alpha: 0.76),
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          '₺${product.discountedPrice.toStringAsFixed(2)}',
                          style: GoogleFonts.plusJakartaSans(
                            color: Colors.white,
                            fontWeight: FontWeight.w900,
                            fontSize: 18,
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

  Widget _buildHorizontalRestaurantList(List<Restaurant> restaurants) {
    return SizedBox(
      height: 150,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: restaurants.length,
        separatorBuilder: (_, __) => const SizedBox(width: 14),
        itemBuilder: (context, index) {
          final restaurant = restaurants[index];

          return GestureDetector(
            onTap: () => _openRestaurantDetail(restaurant),
            child: Container(
              width: 190,
              padding: const EdgeInsets.all(16),
              decoration: _cardDecoration(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _iconBox(Icons.storefront_rounded),
                  const Spacer(),
                  Text(
                    restaurant.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.plusJakartaSans(
                      color: AppColors.textDark,
                      fontSize: 15,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    '${restaurant.city} • ${restaurant.address}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.manrope(
                      color: AppColors.textSoft,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
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

  Widget _discountBadge(double percent) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: AppColors.secondaryOrange,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        '-%${percent.toInt()}',
        style: GoogleFonts.manrope(
          color: Colors.white,
          fontWeight: FontWeight.w900,
          fontSize: 12,
        ),
      ),
    );
  }

  Widget _buildSimpleProductCard(Product product) {
    return GestureDetector(
      onTap: () => _openProductDetail(product),
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.all(15),
        decoration: _cardDecoration(),
        child: Row(
          children: [
            _iconBox(Icons.fastfood_rounded),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.plusJakartaSans(
                      color: AppColors.textDark,
                      fontSize: 15,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    '${product.restaurantName} • Stok: ${product.stock}',
                    style: GoogleFonts.manrope(
                      color: AppColors.textSoft,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            Text(
              '₺${product.discountedPrice.toStringAsFixed(2)}',
              style: GoogleFonts.plusJakartaSans(
                color: AppColors.primaryGreen,
                fontWeight: FontWeight.w900,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrdersTab() {
    return SafeArea(
      child: FutureBuilder<List<CustomerOrder>>(
        future: _ordersFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primaryGreen),
            );
          }

          if (snapshot.hasError) {
            return _buildErrorState(
              title: 'Siparişler yüklenemedi',
              message: snapshot.error.toString().replaceAll(
                    'ApiException: ',
                    '',
                  ),
            );
          }

          final orders = snapshot.data ?? [];

          if (orders.isEmpty) {
            return RefreshIndicator(
              color: AppColors.primaryGreen,
              onRefresh: _refreshOrders,
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(20),
                children: [
                  const SizedBox(height: 160),
                  _buildEmptyState(
                    icon: Icons.receipt_long_outlined,
                    title: 'Henüz sipariş yok',
                    message:
                        'Rezervasyonların ve siparişlerin burada görünecek.',
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            color: AppColors.primaryGreen,
            onRefresh: _refreshOrders,
            child: ListView.builder(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(20),
              itemCount: orders.length,
              itemBuilder: (context, index) => _buildOrderCard(orders[index]),
            ),
          );
        },
      ),
    );
  }

  Widget _buildOrderCard(CustomerOrder order) {
    final status = _statusInfo(order.status);
    final itemNames = order.items.map((i) => i.productName).join(', ');

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: _cardDecoration(),
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: () async {
          final changed = await Navigator.push<bool>(
            context,
            MaterialPageRoute(
              builder: (_) =>
                  OrderTrackingScreen(orderId: order.id, apiClient: _apiClient),
            ),
          );

          if (changed == true && mounted) {
            _refreshOrders();
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 6,
                height: 72,
                decoration: BoxDecoration(
                  color: status.color,
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Sipariş #${order.id}',
                      style: GoogleFonts.manrope(
                        color: AppColors.textSoft,
                        fontWeight: FontWeight.w800,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      itemNames.isNotEmpty ? itemNames : 'Ürün bilgisi yok',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.plusJakartaSans(
                        color: AppColors.textDark,
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '₺${order.totalAmount.toStringAsFixed(2)}',
                      style: GoogleFonts.plusJakartaSans(
                        color: AppColors.primaryGreen,
                        fontSize: 17,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
              ),
              _statusBadge(status.text, status.color),
            ],
          ),
        ),
      ),
    );
  }

  _StatusInfo _statusInfo(String status) {
    switch (status.toLowerCase()) {
      case 'cancelled':
      case 'iptal':
        return const _StatusInfo('İptal Edildi', Colors.redAccent);
      case 'completed':
        return const _StatusInfo('Teslim Edildi', AppColors.primaryGreen);
      case 'readyforpickup':
        return const _StatusInfo('Teslime Hazır', Colors.orange);
      case 'confirmed':
        return const _StatusInfo('Onaylandı', Colors.blue);
      default:
        return const _StatusInfo('Bekliyor', AppColors.primaryContainer);
    }
  }

  Widget _statusBadge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        text,
        style: GoogleFonts.manrope(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }

  Widget _buildBottomNav() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 14),
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(26),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;

            if (index == 2) {
              _ordersFuture = _loadOrdersData();
            }
          });
        },
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.transparent,
        elevation: 0,
        selectedItemColor: AppColors.primaryGreen,
        unselectedItemColor: AppColors.textSoft.withValues(alpha: 0.65),
        selectedLabelStyle: GoogleFonts.manrope(
          fontWeight: FontWeight.w900,
          fontSize: 11,
        ),
        unselectedLabelStyle: GoogleFonts.manrope(
          fontWeight: FontWeight.w700,
          fontSize: 11,
        ),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_filled),
            label: 'Anasayfa',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.map_outlined),
            label: 'Harita',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.receipt_long_outlined),
            label: 'Siparişler',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            label: 'Profil',
          ),
        ],
      ),
    );
  }

  BoxDecoration _cardDecoration() {
    return BoxDecoration(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(24),
      border: Border.all(color: AppColors.surfaceContainer),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.035),
          blurRadius: 18,
          offset: const Offset(0, 8),
        ),
      ],
    );
  }

  Widget _iconBox(IconData icon) {
    return Container(
      width: 58,
      height: 58,
      decoration: BoxDecoration(
        color: AppColors.freshGreen.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Icon(icon, color: AppColors.primaryGreen, size: 27),
    );
  }

  Widget _buildEmptyState({
    required IconData icon,
    required String title,
    required String message,
  }) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: _cardDecoration(),
      child: Column(
        children: [
          Icon(icon, color: AppColors.primaryGreen, size: 42),
          const SizedBox(height: 12),
          Text(
            title,
            textAlign: TextAlign.center,
            style: GoogleFonts.plusJakartaSans(
              color: AppColors.textDark,
              fontSize: 17,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            message,
            textAlign: TextAlign.center,
            style: GoogleFonts.manrope(
              color: AppColors.textSoft,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState({required String title, required String message}) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: _buildEmptyState(
          icon: Icons.error_outline_rounded,
          title: title,
          message: message,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          _buildBody(),
          _buildFloatingChatBot(),
        ],
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }
}

class CategoryChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback? onTap;

  const CategoryChip({
    super.key,
    required this.icon,
    required this.label,
    this.isSelected = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 12),
      child: InkWell(
        borderRadius: BorderRadius.circular(22),
        onTap: onTap,
        child: Container(
          width: 82,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primaryGreen : AppColors.surface,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: isSelected
                  ? AppColors.primaryGreen
                  : AppColors.surfaceContainer,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                color: isSelected ? Colors.white : AppColors.primaryGreen,
                size: 24,
              ),
              const SizedBox(height: 8),
              Text(
                label,
                style: GoogleFonts.manrope(
                  color: isSelected ? Colors.white : AppColors.textDark,
                  fontSize: 11,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HomeData {
  final List<Product> products;
  final List<Restaurant> restaurants;

  const _HomeData({required this.products, required this.restaurants});
}

class _StatusInfo {
  final String text;
  final Color color;

  const _StatusInfo(this.text, this.color);
}

enum _HomeCategoryFilter {
  all,
  tatlilar,
  unluMamuller,
  yemekler,
  icecekler,
  meze,
  salata,
}

extension on _HomeCategoryFilter {
  String get label => switch (this) {
        _HomeCategoryFilter.all => 'Tümü',
        _HomeCategoryFilter.tatlilar => 'Tatlılar',
        _HomeCategoryFilter.unluMamuller => 'Unlu',
        _HomeCategoryFilter.yemekler => 'Yemekler',
        _HomeCategoryFilter.icecekler => 'İçecekler',
        _HomeCategoryFilter.meze => 'Meze',
        _HomeCategoryFilter.salata => 'Salata',
      };

  String get apiValue => switch (this) {
        _HomeCategoryFilter.all => '',
        _HomeCategoryFilter.tatlilar => 'Tatlilar',
        _HomeCategoryFilter.unluMamuller => 'Unlu Mamuller',
        _HomeCategoryFilter.yemekler => 'Yemekler',
        _HomeCategoryFilter.icecekler => 'Içecekler',
        _HomeCategoryFilter.meze => 'Meze',
        _HomeCategoryFilter.salata => 'Salata',
      };
}