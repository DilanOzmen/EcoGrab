import 'package:flutter/material.dart';
import 'package:food_waste_app/core/app_state.dart';
import 'package:food_waste_app/data/models/product.dart';
import 'package:food_waste_app/data/models/restaurant.dart';
import 'package:food_waste_app/data/services/api_client.dart';
import 'map_view_screen.dart';
import 'living_larder_login_screen.dart';
import 'product_detail_screen.dart';
import 'restaurant_detail_screen.dart';

class RescueHomeScreen extends StatefulWidget {
  const RescueHomeScreen({super.key});
  @override
  State<RescueHomeScreen> createState() => _RescueHomeScreenState();
}

class _RescueHomeScreenState extends State<RescueHomeScreen> {
  int _selectedIndex = 0; // Başlangıçta Home seçili
  final ApiClient _apiClient = ApiClient();

  late Future<_HomeData> _homeFuture;

  @override
  void initState() {
    super.initState();
    _homeFuture = _loadHomeData();
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

  Future<void> _refreshHome() async {
    final future = _loadHomeData();
    setState(() {
      _homeFuture = future;
    });
    await future;
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
        SnackBar(content: Text(e.toString().replaceAll('ApiException: ', ''))),
      );
    }
  }

  Future<void> _logout() async {
    AppState.clear();
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const LivingLarderLoginScreen()),
    );
  }

  Widget _buildHomeTab() {
    return FutureBuilder<_HomeData>(
      future: _homeFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Veriler yuklenemedi.\n${snapshot.error.toString().replaceAll('ApiException: ', '')}',
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
          return const Center(child: Text('Veri bulunamadi.'));
        }

        return RefreshIndicator(
          onRefresh: _refreshHome,
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            children: [
              Text(
                'Merhaba, ${AppState.currentUser?.fullName ?? 'Kullanici'}',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Indirimli Urunler',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 8),
              if (data.products.isEmpty)
                const Card(
                  child: Padding(
                    padding: EdgeInsets.all(12),
                    child: Text('Gosterilecek urun bulunamadi.'),
                  ),
                )
              else
                ...data.products.take(10).map(
                  (product) => Card(
                    child: ListTile(
                      title: Text(product.name),
                      subtitle: Text(
                        '${product.restaurantName} • Stok: ${product.stock}',
                      ),
                      trailing: Text(
                        '${product.discountedPrice.toStringAsFixed(2)} TL',
                        style: const TextStyle(
                          color: Color(0xFF0F5238),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
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
                    ),
                  ),
                ),
              const SizedBox(height: 16),
              const Text(
                'Restoranlar',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 8),
              if (data.restaurants.isEmpty)
                const Card(
                  child: Padding(
                    padding: EdgeInsets.all(12),
                    child: Text('Gosterilecek restoran bulunamadi.'),
                  ),
                )
              else
                ...data.restaurants.take(10).map(
                  (restaurant) => Card(
                    child: ListTile(
                      title: Text(restaurant.name),
                      subtitle: Text('${restaurant.city} • ${restaurant.address}'),
                      leading: const CircleAvatar(
                        backgroundColor: Color(0xFFEAF4EE),
                        child: Icon(Icons.store, color: Color(0xFF0F5238)),
                      ),
                      onTap: () => _openRestaurantDetail(restaurant),
                    ),
                  ),
                ),
              const SizedBox(height: 12),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBody() {
    switch (_selectedIndex) {
      case 0:
        return _buildHomeTab();
      case 1:
        return const MapViewScreen();
      case 2:
        return const Center(
          child: Text('Orders sekmesi baglanacak.'),
        );
      case 3:
        return Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                AppState.currentUser?.email ?? '-',
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 12),
              ElevatedButton.icon(
                onPressed: _logout,
                icon: const Icon(Icons.logout),
                label: const Text('Cikis Yap'),
              ),
            ],
          ),
        );
      default:
        return const SizedBox.shrink();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _buildBody(),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color(0xFF0F5238),
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_outlined), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.map_rounded), label: "Map"),
          BottomNavigationBarItem(icon: Icon(Icons.receipt_long_outlined), label: "Orders"),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: "Profile"),
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