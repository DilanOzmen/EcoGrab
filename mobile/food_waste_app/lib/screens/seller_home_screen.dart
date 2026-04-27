import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:food_waste_app/data/models/seller_product.dart';
import 'package:food_waste_app/data/services/api_client.dart';
import 'list_new_product_screen.dart';

class SellerHomeScreen extends StatefulWidget {
  const SellerHomeScreen({super.key});

  @override
  State<SellerHomeScreen> createState() => _SellerHomeScreenState();
}

class _SellerHomeScreenState extends State<SellerHomeScreen> {
  final ApiClient _apiClient = ApiClient();
  late Future<List<SellerProduct>> _productsFuture;

  static const _primary = Color(0xFF0F5238);
  static const _surface = Color(0xFFF8FAF8);

  @override
  void initState() {
    super.initState();
    _productsFuture = _apiClient.getMySellerProducts();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _surface,
      appBar: AppBar(
        backgroundColor: _surface,
        elevation: 0,
        title: Text(
          'Satıcı Paneli',
          style: GoogleFonts.plusJakartaSans(
            fontWeight: FontWeight.w800,
            color: _primary,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.red),
            onPressed: () {
              // Çıkış mantığın buraya gelecek
            },
          ),
        ],
      ),
      body: FutureBuilder<List<SellerProduct>>(
        future: _productsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: _primary));
          }
          final products = snapshot.data ?? [];
          return RefreshIndicator(
            onRefresh: _refreshProducts,
            color: _primary,
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                _buildMainAddButton(),
                const SizedBox(height: 24),
                Text(
                  'Mevcut Ürünleriniz',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: _primary,
                  ),
                ),
                const SizedBox(height: 12),
                if (products.isEmpty)
                  const Center(child: Text('Henüz ürününüz bulunmuyor.'))
                else
                  ...products.map((product) => _buildModernProductCard(product)),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildMainAddButton() {
    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: _primary.withValues(alpha: 0.2),
            blurRadius: 15,
            offset: const Offset(0, 8),
          )
        ],
      ),
      child: ElevatedButton.icon(
        onPressed: _openCreateProduct,
        icon: const Icon(Icons.add_circle_outline, color: Colors.white),
        label: const Text(
          'YENİ ÜRÜN EKLE',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: _primary,
          minimumSize: const Size(double.infinity, 65),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        ),
      ),
    );
  }

  Widget _buildModernProductCard(SellerProduct product) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 20,
            offset: const Offset(0, 10),
          )
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: const Color(0xFFF0F4F2),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(Icons.fastfood, color: _primary),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.name,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                Text(
                  'Stok: ${product.stock}',
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ],
            ),
          ),
          Text(
            '₺${product.discountedPrice}',
            style: const TextStyle(fontWeight: FontWeight.bold, color: _primary),
          ),
        ],
      ),
    );
  }
}