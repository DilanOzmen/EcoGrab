import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:food_waste_app/data/models/restaurant.dart';
import 'package:food_waste_app/data/services/api_client.dart';
import 'restaurant_detail_screen.dart';

class MapViewScreen extends StatefulWidget {
  const MapViewScreen({super.key});

  @override
  State<MapViewScreen> createState() => _MapViewScreenState();
}

class _MapViewScreenState extends State<MapViewScreen> {
  final ApiClient _apiClient = ApiClient();
  final MapController _mapController = MapController();
  final TextEditingController _searchController = TextEditingController();
  
  List<Restaurant> _restaurants = [];
  bool _loading = false;
  int _selectedIndex = 0;

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
      final results = await _apiClient.getRestaurants(search: search);
      if (mounted) {
        setState(() {
          _restaurants = results;
        });
      }
    } catch (_) {
      // Hata durumunda liste boş kalmasın diye mevcut liste korunabilir
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _onSearchChanged(String value) {
    _fetchRestaurants(search: value.isEmpty ? null : value);
  }

  void _moveToRestaurant(Restaurant res, int index) {
    setState(() => _selectedIndex = index);
    _mapController.move(LatLng(res.latitude, res.longitude), 15.0);
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
          // --- GERÇEK HARİTA KATMANI (OpenStreetMap) ---
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              // Senin veritabanındaki restoranların olduğu Pendik merkezli koordinatlar
              initialCenter: const LatLng(40.8922, 29.2321), 
              initialZoom: 13.0,
              interactionOptions: const InteractionOptions(
                flags: InteractiveFlag.all,
              ),
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.foodwaste.app',
              ),
              // --- DİNAMİK MARKERLAR ---
              MarkerLayer(
                markers: _restaurants.asMap().entries.map((entry) {
                  int idx = entry.key;
                  Restaurant res = entry.value;
                  return Marker(
                    point: LatLng(res.latitude, res.longitude),
                    width: 60,
                    height: 80,
                    child: GestureDetector(
                      onTap: () => _moveToRestaurant(res, idx),
                      child: _buildMapMarker(
                        isSelected: _selectedIndex == idx,
                        label: idx == 0 ? "%60 İNDİRİM" : "", 
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
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
        child: const Center(child: Text('Yükleniyor veya dükkan bulunamadı...')),
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
            color: Colors.black.withAlpha(20),
            blurRadius: 20,
            offset: const Offset(0, 10),
          )
        ],
      ),
      child: child,
    );
  }

  Widget _buildMapMarker({required bool isSelected, required String label}) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFF9D4300) : const Color(0xFF1B4332),
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 3),
            boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 10)],
          ),
          child: const Icon(Icons.storefront, size: 20, color: Colors.white),
        ),
        if (label.isNotEmpty)
          Container(
            margin: const EdgeInsets.only(top: 5),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFF9D4300),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              label,
              style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
            ),
          ),
      ],
    );
  }
}