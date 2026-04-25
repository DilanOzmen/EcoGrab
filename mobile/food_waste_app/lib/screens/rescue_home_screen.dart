import 'package:flutter/material.dart';
import 'package:food_waste_app/core/app_state.dart';
import 'package:food_waste_app/data/models/customer_order.dart';
import 'package:food_waste_app/data/models/product.dart';
import 'package:food_waste_app/data/models/restaurant.dart';
import 'package:food_waste_app/data/services/api_client.dart';
import 'login_screen.dart';
import 'map_view_screen.dart';
import 'order_tracking_screen.dart';
import 'product_detail_screen.dart';
import 'profile_screen.dart';
import 'restaurant_detail_screen.dart';

class RescueHomeScreen extends StatefulWidget {
  const RescueHomeScreen({super.key});

  @override
  State<RescueHomeScreen> createState() => _RescueHomeScreenState();
}

class _RescueHomeScreenState extends State<RescueHomeScreen> {
  int _selectedIndex = 0;

  final ApiClient _apiClient = ApiClient();

  late Future<_HomeData> _homeFuture;
  late Future<List<CustomerOrder>> _ordersFuture;

  @override
  void initState() {
    super.initState();
    _homeFuture = _loadHomeData();
    _ordersFuture = _loadOrdersData();
  }

  Future<_HomeData> _loadHomeData() async {
    final results = await Future.wait([
      _apiClient.getProducts(),
      _apiClient.getRestaurants(),
    ]);

    return _HomeData(
      products: results[0] as List<Product>,
      restaurants: results[1] as List<Restaurant>,
    );
  }

  Future<List<CustomerOrder>> _loadOrdersData() async {
    final results = await Future.wait([
      _apiClient.getMyOrders(),
      _apiClient.getMyReservations(),
    ]);

    final merged = <CustomerOrder>[
      ...results[0],
      ...results[1],
    ];

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
    setState(() => _homeFuture = future);
    await future;
  }

  Future<void> _refreshOrders() async {
    final future = _loadOrdersData();
    setState(() => _ordersFuture = future);
    await future;
  }

  Future<void> _logout() async {
    AppState.clear();

    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
    );
  }

  Future<void> _openRestaurantDetail(Restaurant restaurant) async {
    try {
      final detail = await _apiClient.getRestaurantDetail(restaurant.id);

      if (!mounted) return;

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => RestaurantDetailScreen(
            restaurant: detail,
            apiClient: _apiClient,
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString().replaceAll('ApiException: ', '')),
        ),
      );
    }
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

  Widget _buildHomeTab() {
    return SafeArea(
      child: FutureBuilder<_HomeData>(
        future: _homeFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(
                color: Color(0xFF1B4332),
              ),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Veriler yüklenemedi.\n${snapshot.error.toString().replaceAll('ApiException: ', '')}',
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: _refreshHome,
                      child: const Text('Tekrar Dene'),
                    ),
                  ],
                ),
              ),
            );
          }

          final data = snapshot.data;

          if (data == null) {
            return const Center(child: Text('Veri bulunamadı.'));
          }

          return RefreshIndicator(
            onRefresh: _refreshHome,
            color: const Color(0xFF1B4332),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildTopHeader(),
                  _buildCategories(),

                  const Padding(
                    padding: EdgeInsets.fromLTRB(20, 20, 20, 10),
                    child: Text(
                      'Flaş Ürünler',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1B4332),
                      ),
                    ),
                  ),

                  if (data.products.isEmpty)
                    const Padding(
                      padding: EdgeInsets.all(20),
                      child: Text('Gösterilecek ürün bulunamadı.'),
                    )
                  else
                    _buildVerticalProductCard(
                      data.products.first,
                      'https://images.unsplash.com/photo-1547496502-affa22d38842?w=800',
                      '-%60 İNDİRİM',
                    ),

                  const Padding(
                    padding: EdgeInsets.fromLTRB(20, 30, 20, 10),
                    child: Text(
                      'Restoranlar',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1B4332),
                      ),
                    ),
                  ),

                  if (data.restaurants.isEmpty)
                    const Padding(
                      padding: EdgeInsets.all(20),
                      child: Text('Gösterilecek restoran bulunamadı.'),
                    )
                  else
                    ...data.restaurants.take(5).map(
                          (restaurant) => _buildRestaurantCard(restaurant),
                        ),

                  const Padding(
                    padding: EdgeInsets.fromLTRB(20, 30, 20, 10),
                    child: Text(
                      'Diğer Ürünler',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1B4332),
                      ),
                    ),
                  ),

                  ...data.products.skip(1).take(6).map(
                        (product) => _buildSimpleProductCard(product),
                      ),

                  const SizedBox(height: 40),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTopHeader() {
    final fullName = AppState.currentUser?.fullName ?? 'Kullanıcı';
    final initial = fullName.isNotEmpty ? fullName[0].toUpperCase() : 'U';

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
      child: Row(
        children: [
          const Icon(
            Icons.location_on,
            color: Color(0xFF2D6A4F),
            size: 22,
          ),
          const SizedBox(width: 8),
          const Text(
            'Kadıköy, İstanbul',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: Color(0xFF1B4332),
            ),
          ),
          const Spacer(),
          CircleAvatar(
            radius: 18,
            backgroundColor: const Color(0xFFD8F3DC),
            child: Text(
              initial,
              style: const TextStyle(
                color: Color(0xFF1B4332),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategories() {
    return SizedBox(
      height: 110,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.only(left: 20, top: 10),
        children: const [
          CategoryChip(
            icon: Icons.storefront,
            label: 'Market',
            isSelected: true,
          ),
          CategoryChip(
            icon: Icons.coffee,
            label: 'Kafe',
          ),
          CategoryChip(
            icon: Icons.bakery_dining,
            label: 'Fırın',
          ),
          CategoryChip(
            icon: Icons.local_drink,
            label: 'İçecek',
          ),
        ],
      ),
    );
  }

  Widget _buildVerticalProductCard(
    Product product,
    String imageUrl,
    String tag,
  ) {
    return GestureDetector(
      onTap: () async {
        final changed = await Navigator.push<bool>(
          context,
          MaterialPageRoute(
            builder: (_) => ProductDetailScreen(
              product: product,
              apiClient: _apiClient,
            ),
          ),
        );

        if (changed == true && mounted) {
          _refreshHome();
        }
      },
      child: Container(
        width: double.infinity,
        height: 220,
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(28),
          image: DecorationImage(
            image: NetworkImage(imageUrl),
            fit: BoxFit.cover,
          ),
        ),
        child: Stack(
          children: [
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(28),
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withAlpha(160),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
            Positioned(
              top: 15,
              left: 15,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.orange[900],
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  tag,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: 20,
              left: 20,
              right: 20,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '${product.restaurantName} • Stok: ${product.stock}',
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 13,
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

  Widget _buildRestaurantCard(Restaurant restaurant) {
    return GestureDetector(
      onTap: () => _openRestaurantDetail(restaurant),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(26),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(12),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 62,
              height: 62,
              decoration: BoxDecoration(
                color: const Color(0xFFD8F3DC),
                borderRadius: BorderRadius.circular(18),
              ),
              child: const Icon(
                Icons.storefront,
                color: Color(0xFF1B4332),
                size: 30,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    restaurant.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 17,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    '${restaurant.city} • ${restaurant.address}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right,
              color: Color(0xFF1B4332),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSimpleProductCard(Product product) {
    return GestureDetector(
      onTap: () async {
        final changed = await Navigator.push<bool>(
          context,
          MaterialPageRoute(
            builder: (_) => ProductDetailScreen(
              product: product,
              apiClient: _apiClient,
            ),
          ),
        );

        if (changed == true && mounted) {
          _refreshHome();
        }
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(26),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(10),
              blurRadius: 16,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 62,
              height: 62,
              decoration: BoxDecoration(
                color: const Color(0xFFF3F5F7),
                borderRadius: BorderRadius.circular(18),
              ),
              child: const Icon(
                Icons.fastfood,
                color: Color(0xFF1B4332),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 17,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    '${product.restaurantName} • Stok: ${product.stock}',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            Text(
              '₺${product.discountedPrice.toStringAsFixed(2)}',
              style: const TextStyle(
                color: Color(0xFF1B4332),
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrdersTab() {
    return FutureBuilder<List<CustomerOrder>>(
      future: _ordersFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(color: Color(0xFF1B4332)),
          );
        }

        if (snapshot.hasError) {
          return Center(
            child: Text(
              snapshot.error.toString().replaceAll('ApiException: ', ''),
              textAlign: TextAlign.center,
            ),
          );
        }

        final orders = snapshot.data ?? [];

        if (orders.isEmpty) {
          return RefreshIndicator(
            onRefresh: _refreshOrders,
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              children: const [
                SizedBox(height: 220),
                Center(
                  child: Text(
                    'Henüz sipariş veya rezervasyon bulunmuyor.',
                  ),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: _refreshOrders,
          child: ListView.builder(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16),
            itemCount: orders.length,
            itemBuilder: (context, index) {
              final order = orders[index];
              final itemNames = order.items.map((i) => i.productName).join(', ');

              return Container(
                margin: const EdgeInsets.only(bottom: 14),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(22),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withAlpha(10),
                      blurRadius: 16,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => OrderTrackingScreen(
                          orderId: order.id,
                          apiClient: _apiClient,
                        ),
                      ),
                    );
                  },
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            '#${order.id}',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          const Spacer(),
                          _statusBadge(order.status),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        itemNames.isNotEmpty ? itemNames : 'Ürün bilgisi yok',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Text(
                            '₺${order.totalAmount.toStringAsFixed(2)}',
                            style: const TextStyle(
                              color: Color(0xFF1B4332),
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          const Spacer(),
                          const Icon(Icons.chevron_right),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _statusBadge(String status) {
    Color color;
    String text;

    switch (status.toLowerCase()) {
      case 'pending':
        color = Colors.orange;
        text = 'Bekliyor';
        break;
      case 'confirmed':
        color = Colors.blue;
        text = 'Onaylandı';
        break;
      case 'readyforpickup':
        color = const Color(0xFF1B4332);
        text = 'Teslime Hazır';
        break;
      case 'completed':
        color = Colors.green;
        text = 'Tamamlandı';
        break;
      case 'cancelled':
        color = Colors.red;
        text = 'İptal';
        break;
      default:
        color = Colors.grey;
        text = status;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withAlpha(30),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildBottomNav() {
    return BottomNavigationBar(
      currentIndex: _selectedIndex,
      onTap: (i) {
        setState(() {
          _selectedIndex = i;

          if (i == 2) {
            _ordersFuture = _loadOrdersData();
          }
        });
      },
      type: BottomNavigationBarType.fixed,
      selectedItemColor: const Color(0xFF1B4332),
      unselectedItemColor: Colors.grey[400],
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
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFBFBFB),
      body: _buildBody(),
      bottomNavigationBar: _buildBottomNav(),
    );
  }
}

class CategoryChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;

  const CategoryChip({
    super.key,
    required this.icon,
    required this.label,
    this.isSelected = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 18),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: isSelected
                  ? const Color(0xFFD8F3DC)
                  : const Color(0xFFF3F5F7),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(
              icon,
              color: const Color(0xFF1B4332),
              size: 26,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _HomeData {
  final List<Product> products;
  final List<Restaurant> restaurants;

  const _HomeData({
    required this.products,
    required this.restaurants,
  });
}