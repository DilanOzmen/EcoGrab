import 'package:flutter/material.dart';
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
      if (mounted) setState(() => _restaurants = results);
    } catch (_) {
      // keep existing list on error
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _onSearchChanged(String value) {
    _fetchRestaurants(search: value.isEmpty ? null : value);
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
          // --- ARKA PLAN: HARİTA DOKUSU ---
          Container(
            width: double.infinity,
            height: double.infinity,
            decoration: const BoxDecoration(
              color: Color(0xFFE5E8E5),
            ),
            child: CustomPaint(
              painter: _MapGridPainter(),
            ),
          ),
          
          // --- MARKERLAR ---
          _buildMapMarker(top: 250, left: 100, isSelected: true, label: "%60 İNDİRİM"),
          _buildMapMarker(top: 400, left: 280, isSelected: false, label: ""),
          _buildMapMarker(top: 150, left: 220, isSelected: false, label: ""),

          // --- TÜRKÇE ARAMA ÇUBUĞU ---
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
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  else
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0F5238),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.tune, color: Colors.white, size: 18),
                    ),
                ],
              ),
            ),
          ),

          // --- ALT KART ---
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
        child: const Center(child: Text('Restoran bulunamadi.')),
      );
    }

    // Show one restaurant at a time with prev/next arrows
    final restaurant = _restaurants[_selectedIndex % _restaurants.length];

    return _buildModernBox(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            width: 85,
            height: 85,
            decoration: BoxDecoration(
              color: const Color(0xFFB1F0CE),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Icon(Icons.store, size: 45, color: Color(0xFF0F5238)),
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
                  '${restaurant.city} • ${restaurant.address}',
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${_selectedIndex % _restaurants.length + 1}/${_restaurants.length}',
                      style: const TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                    Row(
                      children: [
                        if (_restaurants.length > 1)
                          IconButton(
                            onPressed: () => setState(() => _selectedIndex--),
                            icon: const Icon(Icons.chevron_left, color: Color(0xFF0F5238)),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                          ),
                        if (_restaurants.length > 1)
                          IconButton(
                            onPressed: () => setState(() => _selectedIndex++),
                            icon: const Icon(Icons.chevron_right, color: Color(0xFF0F5238)),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                          ),
                        ElevatedButton(
                          onPressed: () => _openRestaurantDetail(restaurant),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF0F5238),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 10),
                          ),
                          child: const Text('Detay',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold)),
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
            // withOpacity yerine withValues(alpha: 0.08) kullanıldı
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, 10),
          )
        ],
      ),
      child: child,
    );
  }

  Widget _buildMapMarker({required double top, required double left, required bool isSelected, required String label}) {
    return Positioned(
      top: top,
      left: left,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(5),
            decoration: BoxDecoration(
              color: isSelected ? const Color(0xFF9D4300) : const Color(0xFF0F5238),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 2.5),
            ),
            child: const Icon(Icons.storefront, size: 18, color: Colors.white),
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
                style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold),
              ),
            ),
        ],
      ),
    );
  }
}

class _MapGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      // withOpacity yerine withValues kullanıldı
      ..color = Colors.white.withValues(alpha: 0.5)
      ..strokeWidth = 20
      ..style = PaintingStyle.stroke;

    final path = Path();
    path.moveTo(0, size.height * 0.3);
    path.lineTo(size.width, size.height * 0.4);
    path.moveTo(size.width * 0.4, 0);
    path.lineTo(size.width * 0.5, size.height);
    path.moveTo(0, size.height * 0.7);
    path.quadraticBezierTo(size.width * 0.5, size.height * 0.6, size.width, size.height * 0.8);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}