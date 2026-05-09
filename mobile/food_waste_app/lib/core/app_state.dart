import 'package:food_waste_app/data/models/auth_response.dart';

class AppState {
  AppState._();

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

  static void setUser(AuthResponse user) {
    _currentUser = user;
  }

  // Konumu güncellemek için yardımcı metod
  static void setLocation(double lat, double lng, {String? address}) {
    latitude = lat;
    longitude = lng;
    currentAddress = address;
  }

  static void clear() {
    _currentUser = null;
    latitude = null;
    longitude = null;
    currentAddress = null;
  }
}