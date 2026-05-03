import 'package:food_waste_app/data/models/auth_response.dart';

class AppState {
  AppState._();

  static AuthResponse? _currentUser;

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

  static void clear() {
    _currentUser = null;
  }
}


