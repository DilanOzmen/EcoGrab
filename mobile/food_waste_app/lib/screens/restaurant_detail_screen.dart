import 'package:flutter/material.dart';
import 'package:food_waste_app/core/app_colors.dart';
import 'package:food_waste_app/data/models/restaurant_detail.dart';
import 'package:food_waste_app/data/models/product.dart';
import 'package:food_waste_app/data/services/api_client.dart';
import 'product_detail_screen.dart';

class RestaurantDetailScreen extends StatefulWidget {
  final RestaurantDetail restaurant;
  final ApiClient apiClient;

  const RestaurantDetailScreen({
    super.key,
    required this.restaurant,
    required this.apiClient,
  });

  @override
  State<RestaurantDetailScreen> createState() => _RestaurantDetailScreenState();
}

class _RestaurantDetailScreenState extends State<RestaurantDetailScreen> {
  late Future<List<Product>> _productsFuture;

  @override
  void initState() {
    super.initState();
    _productsFuture =
        widget.apiClient.getProductsByRestaurant(widget.restaurant.id);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          _appBar(),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _restaurantHeader(),
                  const SizedBox(height: 20),
                  _infoCard(),
                  const SizedBox(height: 30),
                  _sectionTitle("Ürünler"),
                  const SizedBox(height: 12),
                  _productList(),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  // ---------------- APPBAR ----------------
  Widget _appBar() {
    return SliverAppBar(
      expandedHeight: 200,
      pinned: true,
      backgroundColor: AppColors.primaryGreen,
      flexibleSpace: FlexibleSpaceBar(
        title: Text(
          widget.restaurant.name,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        background: Container(
          decoration: const BoxDecoration(
            gradient: AppColors.editorialGradient,
          ),
          child: const Center(
            child: Icon(Icons.restaurant, size: 90, color: Colors.white),
          ),
        ),
      ),
    );
  }

  // ---------------- HEADER ----------------
  Widget _restaurantHeader() {
    return Row(
      children: [
        const Icon(Icons.location_on, color: AppColors.primaryGreen),
        const SizedBox(width: 6),
        Text(
          widget.restaurant.city,
          style: const TextStyle(
            color: AppColors.textSoft,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  // ---------------- INFO CARD ----------------
  Widget _infoCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 12,
          )
        ],
      ),
      child: Column(
        children: [
          _infoRow(Icons.location_on, widget.restaurant.address),
          const Divider(),
          _infoRow(Icons.phone, widget.restaurant.phone),
        ],
      ),
    );
  }

  Widget _infoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, color: AppColors.primaryGreen),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
        ),
      ],
    );
  }

  // ---------------- PRODUCTS ----------------
  Widget _productList() {
    return FutureBuilder<List<Product>>(
      future: _productsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return const Center(child: Text("Hata oluştu"));
        }

        final products = snapshot.data ?? [];

        if (products.isEmpty) {
          return const Text("Ürün bulunamadı");
        }

        return Column(
          children: products.map((p) => _productCard(p)).toList(),
        );
      },
    );
  }

  Widget _productCard(Product product) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ProductDetailScreen(
              product: product,
              apiClient: widget.apiClient,
            ),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Row(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: AppColors.surfaceContainer,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.fastfood),
            ),
            const SizedBox(width: 12),

            // TEXT
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        "${product.discountedPrice} ₺",
                        style: const TextStyle(
                          color: AppColors.primaryGreen,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        "${product.originalPrice} ₺",
                        style: const TextStyle(
                          decoration: TextDecoration.lineThrough,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),

            // DISCOUNT BADGE
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.red.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                "%${product.discountPercent.toInt()}",
                style: const TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  // ---------------- TITLE ----------------
  Widget _sectionTitle(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: AppColors.primaryGreen,
      ),
    );
  }
}