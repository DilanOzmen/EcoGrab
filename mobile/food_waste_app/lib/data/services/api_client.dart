import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/auth_response.dart';
import '../models/product.dart';
import '../models/restaurant.dart';
import '../models/restaurant_detail.dart';

class ApiClient {
  static const String baseUrl = 'http://localhost:5141';

  // ── Auth ──────────────────────────────────────────────────────────────────

  Future<AuthResponse> login(String email, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );

    if (response.statusCode != 200) {
      throw ApiException(_extractErrorMessage(response.body, 'Giris basarisiz.'));
    }

    return AuthResponse.fromJson(jsonDecode(response.body));
  }

  Future<AuthResponse> register({
    required String fullName,
    required String email,
    required String password,
    required String phone,
    required String role, // "Customer" | "Seller"
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/auth/register'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'fullName': fullName,
        'email': email,
        'password': password,
        'phone': phone,
        'role': role,
      }),
    );

    if (response.statusCode != 200) {
      throw ApiException(_extractErrorMessage(response.body, 'Kayit basarisiz.'));
    }

    return AuthResponse.fromJson(jsonDecode(response.body));
  }

  // ── Products ──────────────────────────────────────────────────────────────

  Future<List<Product>> getProducts({
    String? search,
    String? category,
    double? minDiscountPercent,
  }) async {
    final uri = Uri.parse('$baseUrl/api/customer/products').replace(
      queryParameters: {
        if (search != null) 'search': search,
        if (category != null) 'category': category,
        if (minDiscountPercent != null)
          'minDiscountPercent': minDiscountPercent.toString(),
      },
    );

    final response = await http.get(uri);
    if (response.statusCode != 200) {
      throw ApiException('Urunler yuklenemedi.');
    }

    final list = jsonDecode(response.body) as List<dynamic>;
    return list.map((e) => Product.fromJson(e as Map<String, dynamic>)).toList();
  }

  // ── Restaurants ───────────────────────────────────────────────────────────

  Future<List<Restaurant>> getRestaurants({String? search, String? city}) async {
    final uri = Uri.parse('$baseUrl/api/customer/restaurants').replace(
      queryParameters: {
        if (search != null) 'search': search,
        if (city != null) 'city': city,
      },
    );

    final response = await http.get(uri);
    if (response.statusCode != 200) {
      throw ApiException('Restoranlar yuklenemedi.');
    }

    final list = jsonDecode(response.body) as List<dynamic>;
    return list
        .map((e) => Restaurant.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<List<Restaurant>> getNearbyRestaurants({
    required double latitude,
    required double longitude,
    double radiusKm = 5,
  }) async {
    final uri =
        Uri.parse('$baseUrl/api/customer/restaurants/nearby').replace(
      queryParameters: {
        'latitude': latitude.toString(),
        'longitude': longitude.toString(),
        'radiusKm': radiusKm.toString(),
      },
    );

    final response = await http.get(uri);
    if (response.statusCode != 200) {
      throw ApiException('Yakin restoranlar yuklenemedi.');
    }

    final list = jsonDecode(response.body) as List<dynamic>;
    return list
        .map((e) => Restaurant.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<Product> getProductDetail(int productId) async {
    final uri = Uri.parse('$baseUrl/api/customer/products/$productId');

    final response = await http.get(uri);
    if (response.statusCode == 404) {
      throw ApiException('Urun bulunamadi.');
    }
    if (response.statusCode != 200) {
      throw ApiException('Urun detaylari yuklenemedi.');
    }

    return Product.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
  }

  Future<RestaurantDetail> getRestaurantDetail(int restaurantId) async {
    final uri = Uri.parse('$baseUrl/api/customer/restaurants/$restaurantId');

    final response = await http.get(uri);
    if (response.statusCode == 404) {
      throw ApiException('Restoran bulunamadi.');
    }
    if (response.statusCode != 200) {
      throw ApiException('Restoran detaylari yuklenemedi.');
    }

    return RestaurantDetail.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
  }

  Future<List<Product>> getProductsByRestaurant(int restaurantId) async {
    final uri = Uri.parse('$baseUrl/api/customer/restaurants/$restaurantId/products');

    final response = await http.get(uri);
    if (response.statusCode != 200) {
      throw ApiException('Restoran urunleri yuklenemedi.');
    }

    final list = jsonDecode(response.body) as List<dynamic>;
    return list.map((e) => Product.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<void> reserveProduct({
    required int productId,
    required int quantity,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/customer/orders/reserve'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'ProductId': productId,
        'Quantity': quantity,
      }),
    );

    if (response.statusCode != 200) {
      throw ApiException(_extractErrorMessage(response.body, 'Rezervasyon basarisiz.'));
    }
  }

  // -- Seller Products

  Future<int> createProduct({
    required String name,
    required String description,
    required double originalPrice,
    required double discountedPrice,
    required String category,
    required int stock,
    required String collectionFrom,
    required String collectionUntil,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/seller/products'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'Name': name,
        'Description': description,
        'OriginalPrice': originalPrice,
        'DiscountedPrice': discountedPrice,
        'Category': category,
        'Stock': stock,
        'CollectionWindowFrom': collectionFrom,
        'CollectionWindowUntil': collectionUntil,
      }),
    );

    if (response.statusCode != 201) {
      throw ApiException(_extractErrorMessage(response.body, 'Urun olusturma basarisiz.'));
    }

    final responseJson = jsonDecode(response.body) as Map<String, dynamic>;
    return responseJson['id'] ?? 0;
  }

  // ── helpers ───────────────────────────────────────────────────────────────

  Map<String, dynamic>? _tryDecode(String body) {
    try {
      return jsonDecode(body) as Map<String, dynamic>;
    } catch (_) {
      return null;
    }
  }

  String _extractErrorMessage(String body, String fallback) {
    final decoded = _tryDecode(body);
    if (decoded == null) {
      return fallback;
    }

    final message = decoded['message']?.toString().trim();
    final errorsRaw = decoded['errors'];

    if (errorsRaw is List) {
      final details = errorsRaw
          .map((e) => e.toString().trim())
          .where((e) => e.isNotEmpty)
          .toList();
      if (details.isNotEmpty) {
        final prefix = (message != null && message.isNotEmpty) ? '$message\n' : '';
        return '$prefix- ${details.join('\n- ')}';
      }
    }

    if (message != null && message.isNotEmpty) {
      return message;
    }

    return fallback;
  }
}

class ApiException implements Exception {
  final String message;
  const ApiException(this.message);

  @override
  String toString() => message;
}
