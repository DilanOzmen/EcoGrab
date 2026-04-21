import 'package:flutter/material.dart';

class MapViewScreen extends StatelessWidget {
  const MapViewScreen({super.key});

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
                  const Expanded(
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: "Yerel dükkanları ara...",
                        border: InputBorder.none,
                      ),
                    ),
                  ),
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
            child: _buildModernBox(
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
                    child: const Icon(Icons.bakery_dining, size: 45, color: Color(0xFF0F5238)),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          'Başak Fırın & Pastane',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        const Text(
                          "600m uzakta • 18:00'de kapanıyor",
                          style: TextStyle(color: Colors.grey, fontSize: 12),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("GÜNÜN FIRSATI", style: TextStyle(color: Color(0xFF9D4300), fontSize: 10, fontWeight: FontWeight.bold)),
                                Text(
                                  "₺145,00",
                                  style: TextStyle(
                                    color: Color(0xFF0F5238),
                                    fontWeight: FontWeight.bold,
                                    fontSize: 20,
                                  ),
                                ),
                              ],
                            ),
                            ElevatedButton(
                              onPressed: () {},
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF0F5238),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                              ),
                              child: const Text("Rezerve Et", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
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