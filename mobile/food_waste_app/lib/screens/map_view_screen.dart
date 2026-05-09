import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:food_waste_app/data/models/restaurant.dart';
import 'package:food_waste_app/data/services/api_client.dart';
import 'package:food_waste_app/core/app_state.dart';
import 'restaurant_detail_screen.dart';

class MapViewScreen extends StatefulWidget {
  const MapViewScreen({super.key});

  @override
  State<MapViewScreen> createState() => _MapViewScreenState();
}

class _MapViewScreenState extends State<MapViewScreen> {
  final ApiClient _apiClient = ApiClient();
  GoogleMapController? _mapController;
  final TextEditingController _searchController = TextEditingController();

  List<Restaurant> _restaurants = [];
  bool _loading = false;
  int _selectedIndex = 0;

  // Başlangıç konumu: Cihaz konumu varsa orası, yoksa Pendik/İstanbul merkezi
  final LatLng _initialPosition = LatLng(
    AppState.latitude ?? 40.8922,
    AppState.longitude ?? 29.2321,
  );

  @override
  void initState() {
    super.initState();
    _fetchRestaurants();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchRestaurants({String? search}) async {
    setState(() => _loading = true);
    try {
      // Koordinat bazlı restoranları çekiyoruz
      final results = await _apiClient.getRestaurants(
        search: search,
        latitude: AppState.latitude,
        longitude: AppState.longitude,
        radiusKm: 10,
      );
      if (mounted) {
        setState(() {
          _restaurants = results;
        });
      }
    } catch (_) {
      // Hata durumunda sessizce devam et
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _onSearchChanged(String value) {
    _fetchRestaurants(search: value.isEmpty ? null : value);
  }

  void _moveToRestaurant(Restaurant res, int index) {
    setState(() => _selectedIndex = index);
    _mapController?.animateCamera(
      CameraUpdate.newLatLngZoom(LatLng(res.latitude, res.longitude), 15.0),
    );
  }

  void _openRestaurantDetail(Restaurant restaurant) async {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // --- GOOGLE MAPS KATMANI ---
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: _initialPosition,
              zoom: 13.0,
            ),
            onMapCreated: (controller) => _mapController = controller,
            myLocationEnabled: true,
            myLocationButtonEnabled: false, // Kendi tasarımımız için kapalı
            zoomControlsEnabled: false,
            markers: _restaurants.asMap().entries.map((entry) {
              int idx = entry.key;
              Restaurant res = entry.value;
              return Marker(
                markerId: MarkerId('res_${res.id}'),
                position: LatLng(res.latitude, res.longitude),
                onTap: () => _moveToRestaurant(res, idx),
                // Not: Google Maps marker iconu özelleştirmek için BitmapDescriptor gerekir.
                // Şimdilik standart marker kullanıyoruz.
              );
            }).toSet(),
          ),

          // --- ÜST ARAMA ÇUBUĞU ---
          Positioned(
            top: 50,
            left: 20,
            right: 20,
            child: _buildModernBox(
              child: Row(
                children: [
                  const Icon(Icons.search, color: Color(0xFF707973)),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      onChanged: _onSearchChanged,
                      decoration: const InputDecoration(
                        hintText: "Yerel dükkanları ara...",
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                  if (_loading)
                    const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF1B4332)),
                    )
                  else
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1B4332),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.tune, color: Colors.white, size: 18),
                    ),
                ],
              ),
            ),
          ),

          // --- ALT RESTORAN KARTI ---
          Positioned(
            bottom: 30,
            left: 15,
            right: 15,
            child: _buildRestaurantBottomCard(),
          ),
        ],
      ),
    );
  }

  Widget _buildRestaurantBottomCard() {
    if (_restaurants.isEmpty) {
      return _buildModernBox(
        padding: const EdgeInsets.all(16),
        child: const Center(child: Text('Dükkan bulunamadı...')),
      );
    }

    final restaurant = _restaurants[_selectedIndex % _restaurants.length];

    return _buildModernBox(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            width: 85,
            height: 85,
            decoration: BoxDecoration(
              color: const Color(0xFFD8F3DC),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Icon(Icons.storefront, size: 45, color: Color(0xFF1B4332)),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  restaurant.name,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                Text(
                  '${restaurant.city} • Pendik',
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${(_selectedIndex % _restaurants.length) + 1}/${_restaurants.length}',
                      style: const TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                    Row(
                      children: [
                        if (_restaurants.length > 1)
                          IconButton(
                            onPressed: () {
                              int newIdx = _selectedIndex == 0 ? _restaurants.length - 1 : _selectedIndex - 1;
                              _moveToRestaurant(_restaurants[newIdx], newIdx);
                            },
                            icon: const Icon(Icons.chevron_left, color: Color(0xFF1B4332)),
                          ),
                        if (_restaurants.length > 1)
                          IconButton(
                            onPressed: () {
                              int newIdx = (_selectedIndex + 1) % _restaurants.length;
                              _moveToRestaurant(_restaurants[newIdx], newIdx);
                            },
                            icon: const Icon(Icons.chevron_right, color: Color(0xFF1B4332)),
                          ),
                        ElevatedButton(
                          onPressed: () => _openRestaurantDetail(restaurant),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF1B4332),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          child: const Text('Detay', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModernBox({required Widget child, EdgeInsets padding = const EdgeInsets.symmetric(horizontal: 16, vertical: 8)}) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            // YENİ: withValues kullanımı (Flutter 3.27+ uyumlu)
            color: Colors.black.withValues(alpha: 0.1), 
            blurRadius: 20,
            offset: const Offset(0, 10),
          )
        ],
      ),
      child: child,
    );
  }
}