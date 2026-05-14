import 'dart:convert';

import 'package:food_waste_app/data/models/auth_response.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppState {
  AppState._();

  static const String _userStorageKey = 'current_user';
  static const String _locationLatKey = 'location_latitude';
  static const String _locationLngKey = 'location_longitude';
  static const String _locationAddressKey = 'location_address';

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

  // Konumu güncellemek ve kaydetmek için yardımcı metod
  static Future<void> setLocation(double lat, double lng, {String? address}) async {
    latitude = lat;
    longitude = lng;
    currentAddress = address;
    
    // SharedPreferences'e kaydet
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setDouble(_locationLatKey, lat);
      await prefs.setDouble(_locationLngKey, lng);
      if (address != null) {
        await prefs.setString(_locationAddressKey, address);
      }
    } catch (_) {
      // Hata olsa da bellek'te tutmaya devam et
    }
  }

  // Kaydedilmiş konumu yükle
  static Future<void> loadLocation() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      latitude = prefs.getDouble(_locationLatKey);
      longitude = prefs.getDouble(_locationLngKey);
      currentAddress = prefs.getString(_locationAddressKey);
    } catch (_) {
      // Yükleme hatası - defaults kalır
    }
  }

  static Future<void> clear() async {
    _currentUser = null;
    latitude = null;
    longitude = null;
    currentAddress = null;

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_userStorageKey);
    await prefs.remove(_locationLatKey);
    await prefs.remove(_locationLngKey);
    await prefs.remove(_locationAddressKey);
  }
}