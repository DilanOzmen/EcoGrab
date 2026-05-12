import 'dart:convert';

import 'package:food_waste_app/data/models/auth_response.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppState {
  AppState._();

  static const String _userStorageKey = 'current_user';

  static AuthResponse? _currentUser;
  
  // Konum bilgileri için yeni alanlar
  static double? latitude;
  static double? longitude;
  static String? currentAddress; // Örn: "Kadıköy, İstanbul"

  static AuthResponse? get currentUser => _currentUser;
  static bool get isLoggedIn => _currentUser != null;
  static String get role => _currentUser?.role ?? '';

  static bool get isCustomer =>
      role.toLowerCase() == 'customer' || role.toLowerCase() == 'musteri';

  static bool get isSeller =>
      role.toLowerCase() == 'seller' || role.toLowerCase() == 'satici';

  static Future<void> loadUser() async {
    final prefs = await SharedPreferences.getInstance();
    final rawUser = prefs.getString(_userStorageKey);

    if (rawUser == null || rawUser.isEmpty) {
      _currentUser = null;
      return;
    }

    try {
      _currentUser = AuthResponse.fromJson(
        jsonDecode(rawUser) as Map<String, dynamic>,
      );
    } catch (_) {
      _currentUser = null;
      await prefs.remove(_userStorageKey);
    }
  }

  static Future<void> setUser(AuthResponse user) async {
    _currentUser = user;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userStorageKey, jsonEncode(user.toJson()));
  }

  // Konumu güncellemek için yardımcı metod
  static void setLocation(double lat, double lng, {String? address}) {
    latitude = lat;
    longitude = lng;
    currentAddress = address;
  }

  static Future<void> clear() async {
    _currentUser = null;
    latitude = null;
    longitude = null;
    currentAddress = null;

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_userStorageKey);
  }
}