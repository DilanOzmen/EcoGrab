import 'package:flutter/material.dart';
import '../data/models/product.dart';
import '../data/models/restaurant.dart';
import '../data/services/api_client.dart';
import 'product_detail_screen.dart';

class RescueHomeScreen extends StatefulWidget {
  final ApiClient apiclient;
  const RescueHomeScreen({super.key, required this.apiclient});

  @override
  State<RescueHomeScreen> createState() => _RescueHomeScreenState();
}

class _RescueHomeScreenState extends State<RescueHomeScreen> {
  int _selectedIndex = 0;
  late Future<_HomeData> _homeFuture;

  @override
  void initState() {
    super.initState();
    _homeFuture = _loadHomeData();
  }

  Future<_HomeData> _loadHomeData() async {
    final results = await Future.wait([
      widget.apiclient.getProducts(),
      widget.apiclient.getRestaurants(),
    ]);
    return _HomeData(
      products: results[0] as List<Product>,
      restaurants: results[1] as List<Restaurant>,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFBFBFB),
      body: SafeArea(
        child: FutureBuilder<_HomeData>(
          future: _homeFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator(color: Color(0xFF1B4332)));
            }
            if (snapshot.hasError) return Center(child: Text('Hata: ${snapshot.error}'));
            final data = snapshot.data!;

            return RefreshIndicator(
              onRefresh: () async => setState(() => _homeFuture = _loadHomeData()),
              color: const Color(0xFF1B4332),
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 1. Üst Kısım: Konum ve Profil
                    const Padding(
                      padding: EdgeInsets.fromLTRB(20, 20, 20, 10),
                      child: Row(
                        children: [
                          Icon(Icons.location_on, color: Color(0xFF2D6A4F), size: 22),
                          SizedBox(width: 8),
                          Text('Kadıköy, İstanbul', 
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF1B4332))
                          ),
                          Spacer(),
                          CircleAvatar(
                            radius: 18, 
                            backgroundImage: NetworkImage('https://ui-avatars.com/api/?name=User&background=D8F3DC&color=1B4332')
                          ),
                        ],
                      ),
                    ),

                    // 2. Kategori Seçenekleri
                    SizedBox(
                      height: 110,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.only(left: 20, top: 10),
                        children: const [
                          CategoryChip(icon: Icons.storefront, label: 'Market', isSelected: true),
                          CategoryChip(icon: Icons.coffee, label: 'Kafe'),
                          CategoryChip(icon: Icons.bakery_dining, label: 'Fırın'),
                          CategoryChip(icon: Icons.local_drink, label: 'İçecek'),
                        ],
                      ),
                    ),

                    // 3. Bölüm: Flaş Ürünler (Öne Çıkan Kart)
                    const Padding(
                      padding: EdgeInsets.fromLTRB(20, 20, 20, 10),
                      child: Text('Flaş Ürünler', 
                        style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF1B4332))
                      ),
                    ),
                    if (data.products.isNotEmpty)
                      _buildVerticalProductCard(
                        data.products.first,
                        'https://images.unsplash.com/photo-1547496502-affa22d38842?w=800',
                        '-%60 İNDİRİM'
                      ),

                    // 4. Bölüm: Popüler Kafeler
                    const Padding(
                      padding: EdgeInsets.fromLTRB(20, 30, 20, 10),
                      child: Text('Popüler Kafeler', 
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF1B4332))
                      ),
                    ),
                    _buildCategorizedKitchenCard(
                      'Kahve Dünyası', 
                      '4.9', '0.5 km', 'Kafe', 
                      'https://images.unsplash.com/photo-1495474472287-4d71bcdd2085?w=800',
                      '₺45.00'
                    ),

                    // 5. Bölüm: Şehir Fırınları
                    const Padding(
                      padding: EdgeInsets.fromLTRB(20, 30, 20, 10),
                      child: Text('Şehir Fırınları', 
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF1B4332))
                      ),
                    ),
                    _buildCategorizedKitchenCard(
                      'L\'Artisan Bakery', 
                      '4.8', '0.2 km', 'Fırın', 
                      'https://images.unsplash.com/photo-1509440159596-0249088772ff?w=800',
                      '₺35.00'
                    ),

                    // 6. Bölüm: Sağlıklı Seçenekler
                    const Padding(
                      padding: EdgeInsets.fromLTRB(20, 30, 20, 10),
                      child: Text('Sağlıklı Seçenekler', 
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF1B4332))
                      ),
                    ),
                    if (data.products.length > 1)
                      _buildVerticalProductCard(
                        data.products[1],
                        'https://images.unsplash.com/photo-1512621776951-a57141f2eefd?w=800',
                        'TAZE SEÇENEK'
                      ),

                    // 7. Bölüm: Gece Atıştırmalıkları (Dönerci Ali Düzeltildi)
                    const Padding(
                      padding: EdgeInsets.fromLTRB(20, 30, 20, 10),
                      child: Text('Gece Atıştırmalıkları', 
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF1B4332))
                      ),
                    ),
                    _buildCategorizedKitchenCard(
                      'Dönerci Ali', 
                      '4.7', '1.2 km', 'Restoran', 
                      'https://images.unsplash.com/photo-1633383718081-22ac93e3dbf1?w=800',
                      '₺120.00'
                    ),

                    const SizedBox(height: 40),
                  ],
                ),
              ),
            );
          },
        ),
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  // Ürün Kartı Tasarımı
  Widget _buildVerticalProductCard(Product product, String imageUrl, String tag) {
    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(
        builder: (_) => ProductDetailScreen(product: product, apiClient: widget.apiclient)
      )),
      child: Container(
        width: double.infinity,
        height: 220,
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(28),
          image: DecorationImage(image: NetworkImage(imageUrl), fit: BoxFit.cover),
        ),
        child: Stack(
          children: [
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(28),
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter, 
                  colors: [Colors.black.withAlpha(150), Colors.transparent]
                ),
              ),
            ),
            Positioned(
              top: 15, left: 15,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(color: Colors.orange[900], borderRadius: BorderRadius.circular(10)),
                child: Text(tag, style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
              ),
            ),
            Positioned(
              bottom: 20, left: 20,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(product.name, style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
                  Text('${product.restaurantName} • Stok: ${product.stock}', 
                    style: const TextStyle(color: Colors.white70, fontSize: 13)
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Restoran/Mutfak Kartı Tasarımı
  Widget _buildCategorizedKitchenCard(String name, String rating, String dist, String cat, String img, String price) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white, 
        borderRadius: BorderRadius.circular(28), 
        boxShadow: [BoxShadow(color: Colors.black.withAlpha(12), blurRadius: 20)]
      ),
      child: Column(
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)), 
            child: Image.network(img, height: 170, width: double.infinity, fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                height: 170, color: Colors.grey[200], child: const Icon(Icons.broken_image, size: 50)
              ),
            )
          ),
          Padding(
            padding: const EdgeInsets.all(18),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(Icons.star, color: Colors.amber, size: 16),
                        Text(' $rating ', style: const TextStyle(fontWeight: FontWeight.bold)),
                        Text('• $dist • $cat', style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                      ],
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(color: const Color(0xFFD8F3DC), borderRadius: BorderRadius.circular(15)),
                  child: Text(price, style: const TextStyle(color: Color(0xFF1B4332), fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNav() {
    return BottomNavigationBar(
      currentIndex: _selectedIndex,
      onTap: (i) => setState(() => _selectedIndex = i),
      type: BottomNavigationBarType.fixed,
      selectedItemColor: const Color(0xFF1B4332),
      unselectedItemColor: Colors.grey[400],
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home_filled), label: 'Anasayfa'),
        BottomNavigationBarItem(icon: Icon(Icons.map_outlined), label: 'Harita'),
        BottomNavigationBarItem(icon: Icon(Icons.receipt_long_outlined), label: 'Siparişler'),
        BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: 'Profil'),
      ],
    );
  }
}

class CategoryChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  const CategoryChip({super.key, required this.icon, required this.label, this.isSelected = false});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 18),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: isSelected ? const Color(0xFFD8F3DC) : const Color(0xFFF3F5F7),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(icon, color: const Color(0xFF1B4332), size: 26),
          ),
          const SizedBox(height: 8),
          Text(label, style: TextStyle(fontSize: 12, fontWeight: isSelected ? FontWeight.bold : FontWeight.w500)),
        ],
      ),
    );
  }
}

class _HomeData {
  final List<Product> products;
  final List<Restaurant> restaurants;
  const _HomeData({required this.products, required this.restaurants});
}