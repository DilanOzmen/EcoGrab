import 'package:flutter/material.dart';
import 'map_view_screen.dart';

class RescueHomeScreen extends StatefulWidget {
  const RescueHomeScreen({super.key});
  @override
  State<RescueHomeScreen> createState() => _RescueHomeScreenState();
}

class _RescueHomeScreenState extends State<RescueHomeScreen> {
  int _selectedIndex = 0; // Başlangıçta Home seçili

  // Sayfalar Listesi
  final List<Widget> _pages = [
    const Center(child: Text("Home Page Content - Burası Ana Sayfa", style: TextStyle(fontSize: 20))),
    const MapViewScreen(), // SENİN HARİTA TASARIMIN BURADA
    const Center(child: Text("Orders Page Content", style: TextStyle(fontSize: 20))),
    const Center(child: Text("Profile Page Content", style: TextStyle(fontSize: 20))),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
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