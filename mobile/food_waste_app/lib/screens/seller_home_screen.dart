import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:food_waste_app/screens/seller_profile_screen.dart';
import 'package:food_waste_app/core/app_assets.dart';
import 'package:food_waste_app/core/app_colors.dart';
import 'package:food_waste_app/core/app_spacing.dart';
import 'package:food_waste_app/core/app_state.dart';
import 'package:food_waste_app/data/models/seller_product.dart';
import 'package:food_waste_app/data/services/api_client.dart';
import 'package:food_waste_app/screens/list_new_product_screen.dart';
import 'package:food_waste_app/screens/login_screen.dart';
import 'package:food_waste_app/screens/seller_order_approval_screen.dart';

class SellerHomeScreen extends StatefulWidget {
  const SellerHomeScreen({super.key});

  @override
  State<SellerHomeScreen> createState() => _SellerHomeScreenState();
}

class _SellerHomeScreenState extends State<SellerHomeScreen>
    with SingleTickerProviderStateMixin {
  final ApiClient _apiClient = ApiClient();
  late Future<List<SellerProduct>> _productsFuture;

  late final AnimationController _controller;
  late final Animation<double> _fade;
  late final Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _productsFuture = _apiClient.getMySellerProducts();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 650),
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
    super.dispose();
  }

  Future<void> _refreshProducts() async {
    final future = _apiClient.getMySellerProducts();
    setState(() => _productsFuture = future);
    await future;
  }

  Future<void> _openCreateProduct() async {
    final created = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => const ListNewProductScreen()),
    );

    if (created == true && mounted) {
      _refreshProducts();
    }
  }

  void _openOrderApprovalScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const SellerOrderApprovalScreen(),
      ),
    );
  }

  void _openSellerProfile() {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => SellerProfileScreen(
        onLogout: _logout,
      ),
    ),
  );
}

  void _logout() {
    AppState.clear();

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: FutureBuilder<List<SellerProduct>>(
          future: _productsFuture,
          builder: (context, snapshot) {
            final isLoading =
                snapshot.connectionState == ConnectionState.waiting;
            final products = snapshot.data ?? [];

            return RefreshIndicator(
              color: AppColors.primaryGreen,
              onRefresh: _refreshProducts,
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(20, 18, 20, 32),
                children: [
                  FadeTransition(
                    opacity: _fade,
                    child: SlideTransition(
                      position: _slide,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildTopBar(),
                          const SizedBox(height: 20),
                          _buildHeroCard(products),
                          const SizedBox(height: 18),
                          _buildQuickActions(),
                          const SizedBox(height: 24),
                          _buildSectionHeader(products.length),
                          const SizedBox(height: 14),
                          if (isLoading)
                            const Padding(
                              padding: EdgeInsets.only(top: 80),
                              child: Center(
                                child: CircularProgressIndicator(
                                  color: AppColors.primaryGreen,
                                ),
                              ),
                            )
                          else if (snapshot.hasError)
                            _buildErrorCard(snapshot.error.toString())
                          else if (products.isEmpty)
                            _buildEmptyState()
                          else
                            ...products.map(_buildProductCard),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

 Widget _buildTopBar() {
  return Row(
    children: [
      Image.asset(
        AppAssets.ecograbLogo,
        width: 42,
        height: 42,
        fit: BoxFit.contain,
      ),
      const SizedBox(width: 10),
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Satıcı Paneli',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 22,
                fontWeight: FontWeight.w900,
                color: AppColors.primaryGreen,
              ),
            ),
            Text(
              'Ürünlerini yönet, israfı azalt.',
              style: GoogleFonts.manrope(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.textSoft,
              ),
            ),
          ],
        ),
      ),
      IconButton(
        onPressed: _openSellerProfile,
        icon: const Icon(Icons.person_outline_rounded),
        color: AppColors.primaryGreen,
      ),
      IconButton(
        onPressed: _logout,
        icon: const Icon(Icons.logout_rounded),
        color: AppColors.error,
      ),
    ],
  );
}

  Widget _buildHeroCard(List<SellerProduct> products) {
    final totalStock = products.fold<int>(0, (sum, item) => sum + item.stock);
    final totalProducts = products.length;

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
            right: -35,
            top: -45,
            child: Icon(
              Icons.eco,
              size: 150,
              color: Colors.white.withValues(alpha: 0.08),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Bugünkü Özet',
                style: GoogleFonts.manrope(
                  color: Colors.white.withValues(alpha: 0.82),
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                '$totalProducts aktif ürün',
                style: GoogleFonts.plusJakartaSans(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Toplam stok: $totalStock adet',
                style: GoogleFonts.manrope(
                  color: Colors.white.withValues(alpha: 0.82),
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  _miniStat(Icons.inventory_2_outlined, 'Stok', '$totalStock'),
                  const SizedBox(width: 10),
                  _miniStat(
                    Icons.storefront_outlined,
                    'Liste',
                    '$totalProducts',
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _miniStat(IconData icon, String label, String value) {
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
            Icon(icon, color: Colors.white, size: 19),
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

  Widget _buildQuickActions() {
    return Row(
      children: [
        Expanded(
          child: _actionCard(
            icon: Icons.add_circle_outline_rounded,
            title: 'Yeni Ürün',
            subtitle: 'Listele',
            onTap: _openCreateProduct,
            isPrimary: true,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _actionCard(
            icon: Icons.fact_check_outlined,
            title: 'Siparişleri Onayla',
            subtitle: 'Bekleyenleri kontrol et',
            onTap: _openOrderApprovalScreen,
            isPrimary: false,
          ),
        ),
      ],
    );
  }

  Widget _actionCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    required bool isPrimary,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(22),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isPrimary ? AppColors.primaryGreen : AppColors.surface,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: isPrimary
                ? AppColors.primaryGreen
                : AppColors.surfaceContainer,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isPrimary ? Colors.white : AppColors.primaryGreen,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.plusJakartaSans(
                      color: isPrimary ? Colors.white : AppColors.textDark,
                      fontWeight: FontWeight.w900,
                      fontSize: 13,
                    ),
                  ),
                  Text(
                    subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.manrope(
                      color: isPrimary
                          ? Colors.white.withValues(alpha: 0.74)
                          : AppColors.textSoft,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
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

  Widget _buildSectionHeader(int count) {
    return Row(
      children: [
        Text(
          'Ürünlerin',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 20,
            fontWeight: FontWeight.w900,
            color: AppColors.textDark,
          ),
        ),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: AppColors.freshGreen.withValues(alpha: 0.18),
            borderRadius: BorderRadius.circular(999),
          ),
          child: Text(
            '$count ürün',
            style: GoogleFonts.manrope(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              color: AppColors.primaryGreen,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildProductCard(SellerProduct product) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.surfaceContainer),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.035),
            blurRadius: 18,
            offset: const Offset(0, 9),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 62,
            height: 62,
            decoration: BoxDecoration(
              color: AppColors.freshGreen.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(19),
            ),
            child: const Icon(
              Icons.restaurant_menu_rounded,
              color: AppColors.primaryGreen,
              size: 28,
            ),
          ),
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
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
                    color: AppColors.textDark,
                  ),
                ),
                const SizedBox(height: 6),
                _smallBadge(
                  Icons.inventory_2_outlined,
                  'Stok: ${product.stock}',
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Text(
            '₺${product.discountedPrice}',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 15,
              fontWeight: FontWeight.w900,
              color: AppColors.primaryGreen,
            ),
          ),
        ],
      ),
    );
  }

  Widget _smallBadge(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainer.withValues(alpha: 0.65),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: AppColors.primaryGreen),
          const SizedBox(width: 5),
          Text(
            text,
            style: GoogleFonts.manrope(
              fontSize: 11,
              color: AppColors.textSoft,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      margin: const EdgeInsets.only(top: 10),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: AppColors.surfaceContainer),
      ),
      child: Column(
        children: [
          Icon(
            Icons.eco_rounded,
            size: 54,
            color: AppColors.freshGreen.withValues(alpha: 0.8),
          ),
          const SizedBox(height: 12),
          Text(
            'Henüz ürününüz yok',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 18,
              fontWeight: FontWeight.w900,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'İlk ürününüzü ekleyerek satışa başlayabilirsiniz.',
            textAlign: TextAlign.center,
            style: GoogleFonts.manrope(
              color: AppColors.textSoft,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 18),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton.icon(
              onPressed: _openCreateProduct,
              icon: const Icon(Icons.add_rounded, color: Colors.white),
              label: const Text('Ürün Ekle'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryGreen,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppSpacing.buttonRadius),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorCard(String error) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.error.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.error.withValues(alpha: 0.18)),
      ),
      child: Column(
        children: [
          const Icon(Icons.error_outline_rounded, color: AppColors.error),
          const SizedBox(height: 8),
          Text(
            error.replaceAll('ApiException: ', ''),
            textAlign: TextAlign.center,
            style: GoogleFonts.manrope(
              color: AppColors.error,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),
          TextButton(
            onPressed: _refreshProducts,
            child: const Text('Tekrar Dene'),
          ),
        ],
      ),
    );
  }
}