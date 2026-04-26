import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:food_waste_app/core/app_state.dart';
import 'package:food_waste_app/data/models/seller_order.dart';
import 'package:food_waste_app/data/models/seller_product.dart';
import 'package:food_waste_app/data/services/api_client.dart';
import 'list_new_product_screen.dart';
import 'login_screen.dart';

class SellerHomeScreen extends StatefulWidget {
  const SellerHomeScreen({super.key});

  @override
  State<SellerHomeScreen> createState() => _SellerHomeScreenState();
}

class _SellerHomeScreenState extends State<SellerHomeScreen> {
  final ApiClient _apiClient = ApiClient();
  int _tabIndex = 0;

  late Future<List<SellerProduct>> _productsFuture;
  late Future<List<SellerOrder>> _ordersFuture;

  static const _primary = Color(0xFF0F5238);
  static const _surface = Color(0xFFF8FAF8);
  static const _onSurfaceVariant = Color(0xFF404943);

  @override
  void initState() {
    super.initState();
    _productsFuture = _apiClient.getMySellerProducts();
    _ordersFuture = _apiClient.getSellerOrders(onlyActive: false);
  }

  Future<void> _refreshProducts() async {
    final future = _apiClient.getMySellerProducts();
    setState(() => _productsFuture = future);
    await future;
  }

  Future<void> _refreshOrders() async {
    final future = _apiClient.getSellerOrders(onlyActive: false);
    setState(() => _ordersFuture = future);
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

  Future<void> _deleteProduct(SellerProduct product) async {
    try {
      await _apiClient.deleteSellerProduct(product.id);
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Urun silindi.')));
      _refreshProducts();
    } catch (e) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceAll('ApiException: ', ''))),
      );
    }
  }

  Future<void> _updateProduct(
    SellerProduct product, {
    int? stock,
    bool? isActive,
  }) async {
    try {
      await _apiClient.updateSellerProduct(
        productId: product.id,
        category: product.category,
        name: product.name,
        description: product.description,
        originalPrice: product.originalPrice,
        discountedPrice: product.discountedPrice,
        stock: stock ?? product.stock,
        expiryDate: product.expiryDate,
        isActive: isActive ?? product.isActive,
      );
      if (!mounted) {
        return;
      }
      _refreshProducts();
    } catch (e) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceAll('ApiException: ', ''))),
      );
    }
  }

  Future<void> _editStockDialog(SellerProduct product) async {
    final controller = TextEditingController(text: product.stock.toString());
    var active = product.isActive;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setLocalState) {
            return AlertDialog(
              title: const Text('Urunu Guncelle'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: controller,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Stok'),
                  ),
                  const SizedBox(height: 8),
                  SwitchListTile(
                    value: active,
                    onChanged: (value) => setLocalState(() => active = value),
                    title: const Text('Aktif'),
                    contentPadding: EdgeInsets.zero,
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext, false),
                  child: const Text('Vazgec'),
                ),
                ElevatedButton(
                  onPressed: () => Navigator.pop(dialogContext, true),
                  child: const Text('Kaydet'),
                ),
              ],
            );
          },
        );
      },
    );

    if (confirmed != true) {
      return;
    }

    final stock = int.tryParse(controller.text.trim());
    if (stock == null || stock < 0) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Gecerli bir stok degeri girin.')),
      );
      return;
    }

    await _updateProduct(product, stock: stock, isActive: active);
  }

  Future<void> _updateOrderStatus(SellerOrder order, String status) async {
    try {
      await _apiClient.updateSellerOrderStatus(
        orderId: order.orderId,
        status: status,
      );
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Siparis durumu guncellendi.')),
      );
      _refreshOrders();
    } catch (e) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceAll('ApiException: ', ''))),
      );
    }
  }

  Widget _buildProductsTab() {
    return FutureBuilder<List<SellerProduct>>(
      future: _productsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                snapshot.error.toString().replaceAll('ApiException: ', ''),
                textAlign: TextAlign.center,
              ),
            ),
          );
        }

        final products = snapshot.data ?? [];
        return RefreshIndicator(
          onRefresh: _refreshProducts,
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16),
            children: [
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _openCreateProduct,
                  icon: const Icon(Icons.add),
                  label: const Text('Yeni Urun Ekle'),
                ),
              ),
              const SizedBox(height: 12),
              if (products.isEmpty)
                const Padding(
                  padding: EdgeInsets.only(top: 80),
                  child: Center(child: Text('Henuz urununuz bulunmuyor.')),
                )
              else
                ...products.map(
                  (product) => Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                product.name,
                                style: GoogleFonts.plusJakartaSans(
                                  fontWeight: FontWeight.w800,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                            Chip(
                              label: Text(product.isActive ? 'Aktif' : 'Pasif'),
                              backgroundColor: product.isActive
                                  ? const Color(0xFFD8F3DC)
                                  : const Color(0xFFF4F4F4),
                            ),
                          ],
                        ),
                        Text('${product.category} • Stok: ${product.stock}'),
                        const SizedBox(height: 6),
                        Text(
                          'TL ${product.discountedPrice.toStringAsFixed(2)} / TL ${product.originalPrice.toStringAsFixed(2)}',
                          style: const TextStyle(fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            OutlinedButton.icon(
                              onPressed: () => _editStockDialog(product),
                              icon: const Icon(Icons.edit_outlined),
                              label: const Text('Guncelle'),
                            ),
                            const SizedBox(width: 8),
                            OutlinedButton.icon(
                              onPressed: () => _deleteProduct(product),
                              icon: const Icon(Icons.delete_outline),
                              label: const Text('Sil'),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: Colors.red,
                                side: const BorderSide(color: Colors.red),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildOrdersTab() {
    return FutureBuilder<List<SellerOrder>>(
      future: _ordersFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                snapshot.error.toString().replaceAll('ApiException: ', ''),
                textAlign: TextAlign.center,
              ),
            ),
          );
        }

        final orders = snapshot.data ?? [];
        return RefreshIndicator(
          onRefresh: _refreshOrders,
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16),
            children: [
              if (orders.isEmpty)
                const Padding(
                  padding: EdgeInsets.only(top: 80),
                  child: Center(child: Text('Aktif siparis bulunmuyor.')),
                )
              else
                ...orders.map((order) {
                  final canConfirm = order.status.toLowerCase() == 'pending';
                  final canComplete = order.status.toLowerCase() == 'confirmed';
                  final summary = order.items
                      .map((e) => '${e.productName} x${e.quantity}')
                      .join(', ');

                  return Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              '#${order.orderId}',
                              style: const TextStyle(
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(order.status),
                            const Spacer(),
                            Text('TL ${order.totalAmount.toStringAsFixed(2)}'),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(order.customerName),
                        const SizedBox(height: 4),
                        Text(summary.isNotEmpty ? summary : '-'),
                        const SizedBox(height: 10),
                        if (canConfirm)
                          ElevatedButton(
                            onPressed: () =>
                                _updateOrderStatus(order, 'Confirmed'),
                            child: const Text('Onayla'),
                          )
                        else if (canComplete)
                          ElevatedButton(
                            onPressed: () =>
                                _updateOrderStatus(order, 'Completed'),
                            child: const Text('Tamamla'),
                          ),
                      ],
                    ),
                  );
                }),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      initialIndex: _tabIndex,
      child: Scaffold(
        backgroundColor: _surface,
        appBar: AppBar(
          backgroundColor: _surface,
          elevation: 0,
          title: Text(
            'Satici Paneli',
            style: GoogleFonts.plusJakartaSans(
              fontWeight: FontWeight.w800,
              color: _primary,
              fontSize: 22,
            ),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.logout, color: _onSurfaceVariant),
              tooltip: 'Cikis Yap',
              onPressed: () {
                AppState.clear();
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                );
              },
            ),
          ],
          bottom: TabBar(
            onTap: (index) => setState(() => _tabIndex = index),
            tabs: const [
              Tab(icon: Icon(Icons.inventory_2_outlined), text: 'Urunler'),
              Tab(icon: Icon(Icons.receipt_long_outlined), text: 'Siparisler'),
            ],
          ),
        ),
        body: TabBarView(
          physics: const NeverScrollableScrollPhysics(),
          children: [_buildProductsTab(), _buildOrdersTab()],
        ),
        floatingActionButton: _tabIndex == 0
            ? FloatingActionButton.extended(
                onPressed: _openCreateProduct,
                icon: const Icon(Icons.add),
                label: const Text('Urun Ekle'),
              )
            : null,
      ),
    );
  }
}
