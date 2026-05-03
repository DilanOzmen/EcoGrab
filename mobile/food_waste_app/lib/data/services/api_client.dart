import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/foundation.dart';
import '../../core/app_state.dart';
import '../models/auth_response.dart';
import '../models/customer_order.dart';
import '../models/product.dart';
import '../models/restaurant.dart';
import '../models/restaurant_detail.dart';
import '../models/app_notification.dart';
import '../models/seller_product.dart';
import '../models/seller_order.dart';

class ApiClient {
  static String get baseUrl {
    const override = String.fromEnvironment('API_BASE_URL', defaultValue: '');
    if (override.isNotEmpty) {
      return override;
    }

    if (kIsWeb) {
      return 'http://localhost:5141';
    }

    return switch (defaultTargetPlatform) {
      TargetPlatform.android => 'http://10.0.2.2:5141',
      TargetPlatform.iOS => 'http://localhost:5141',
      TargetPlatform.windows => 'http://localhost:5141',
      TargetPlatform.macOS => 'http://localhost:5141',
      TargetPlatform.linux => 'http://localhost:5141',
      TargetPlatform.fuchsia => 'http://localhost:5141',
    };
  }

  // ── Auth ──────────────────────────────────────────────────────────────────

  Future<AuthResponse> login(String email, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );

    if (response.statusCode != 200) {
      throw ApiException(
        _extractErrorMessage(response.body, 'Giris basarisiz.'),
      );
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
      throw ApiException(
        _extractErrorMessage(response.body, 'Kayit basarisiz.'),
      );
    }

    return AuthResponse.fromJson(jsonDecode(response.body));
  }

  // ── Products ──────────────────────────────────────────────────────────────

  Future<List<Product>> getProducts({
    String? search,
    String? category,
    String? homeCategory,
    double? minDiscountPercent,
  }) async {
    final uri = Uri.parse('$baseUrl/api/customer/products').replace(
      queryParameters: {
        if (search != null) 'search': search,
        if (category != null) 'category': category,
        if (homeCategory != null) 'homeCategory': homeCategory,
        if (minDiscountPercent != null)
          'minDiscountPercent': minDiscountPercent.toString(),
      },
    );

    final response = await http.get(uri);
    if (response.statusCode != 200) {
      throw ApiException('Urunler yuklenemedi.');
    }

    final list = jsonDecode(response.body) as List<dynamic>;
    return list
        .map((e) => Product.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  // ── Restaurants ───────────────────────────────────────────────────────────

  Future<List<Restaurant>> getRestaurants({
    String? search,
    String? city,
    String? homeCategory,
  }) async {
    final uri = Uri.parse('$baseUrl/api/customer/restaurants').replace(
      queryParameters: {
        if (search != null) 'search': search,
        if (city != null) 'city': city,
        if (homeCategory != null) 'homeCategory': homeCategory,
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
    final uri = Uri.parse('$baseUrl/api/customer/restaurants/nearby').replace(
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

    return RestaurantDetail.fromJson(
      jsonDecode(response.body) as Map<String, dynamic>,
    );
  }

  Future<List<Product>> getProductsByRestaurant(int restaurantId) async {
    final uri = Uri.parse(
      '$baseUrl/api/customer/restaurants/$restaurantId/products',
    );

    final response = await http.get(uri);
    if (response.statusCode != 200) {
      throw ApiException('Restoran urunleri yuklenemedi.');
    }

    final list = jsonDecode(response.body) as List<dynamic>;
    return list
        .map((e) => Product.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> reserveProduct({
    required int productId,
    required int quantity,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/customer/orders/reserve'),
      headers: _authHeaders(),
      body: jsonEncode({'ProductId': productId, 'Quantity': quantity}),
    );

    if (response.statusCode != 200) {
      throw ApiException(
        _extractErrorMessage(response.body, 'Rezervasyon basarisiz.'),
      );
    }
  }

  // -- Seller Products

  /// Yeni eklenen metod: Satıcının dükkan görselini yükler
  Future<String> uploadProductImage(Uint8List bytes, String fileName) async {
    var request = http.MultipartRequest(
      'POST',
      Uri.parse('$baseUrl/api/seller/upload-image'),
    );

    request.files.add(http.MultipartFile.fromBytes(
      'file',
      bytes,
      filename: fileName,
    ));

    // Token varsa header ekleyelim (kodunda AllowAnonymous yapmıştık ama güvenlik iyidir)
    final token = AppState.currentUser?.token ?? '';
    if (token.isNotEmpty) {
      request.headers['Authorization'] = 'Bearer $token';
    }

    var streamedResponse = await request.send();
    var response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['imageUrl']; // Backend'den gelen yol: /uploads/xxx.jpg
    } else {
      throw ApiException(
        _extractErrorMessage(response.body, 'Gorsel yukleme basarisiz.'),
      );
    }
  }

  Future<int> createProduct({
    required int restaurantId,
    required String name,
    required String description,
    required double originalPrice,
    required double discountedPrice,
    required String category,
    required int stock,
    required DateTime expiryDate,
    required bool isActive,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/seller/products'),
      headers: _authHeaders(),
      body: jsonEncode({
        'restaurantId': restaurantId,
        'category': category,
        'name': name,
        'description': description,
        'originalPrice': originalPrice,
        'discountedPrice': discountedPrice,
        'stock': stock,
        'expiryDate': expiryDate.toIso8601String(),
        'isActive': isActive,
      }),
    );

    if (response.statusCode != 201 && response.statusCode != 200) {
      throw ApiException(
        _extractErrorMessage(response.body, 'Urun olusturma basarisiz.'),
      );
    }

    final responseJson = jsonDecode(response.body) as Map<String, dynamic>;
    return responseJson['id'] ?? 0;
  }

  Future<List<SellerProduct>> getMySellerProducts() async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/seller/products'),
      headers: _authHeaders(),
    );

    if (response.statusCode != 200) {
      throw ApiException(
        _extractErrorMessage(response.body, 'Satici urunleri yuklenemedi.'),
      );
    }

    final list = jsonDecode(response.body) as List<dynamic>;
    return list
        .map((e) => SellerProduct.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> updateSellerProduct({
    required int productId,
    required String category,
    required String name,
    required String description,
    required double originalPrice,
    required double discountedPrice,
    required int stock,
    required DateTime expiryDate,
    required bool isActive,
  }) async {
    final response = await http.put(
      Uri.parse('$baseUrl/api/seller/products/$productId'),
      headers: _authHeaders(),
      body: jsonEncode({
        'category': category,
        'name': name,
        'description': description,
        'originalPrice': originalPrice,
        'discountedPrice': discountedPrice,
        'stock': stock,
        'expiryDate': expiryDate.toIso8601String(),
        'isActive': isActive,
      }),
    );

    if (response.statusCode != 200) {
      throw ApiException(
        _extractErrorMessage(response.body, 'Urun guncellenemedi.'),
      );
    }
  }

  Future<void> deleteSellerProduct(int productId) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/api/seller/products/$productId'),
      headers: _authHeaders(),
    );

    if (response.statusCode != 204) {
      throw ApiException(
        _extractErrorMessage(response.body, 'Urun silinemedi.'),
      );
    }
  }

  Future<List<SellerOrder>> getSellerOrders({bool onlyActive = false}) async {
    final uri = Uri.parse(
      '$baseUrl/api/seller/orders',
    ).replace(queryParameters: {'onlyActive': onlyActive.toString()});
    final response = await http.get(uri, headers: _authHeaders());

    if (response.statusCode != 200) {
      throw ApiException(
        _extractErrorMessage(response.body, 'Satici siparisleri yuklenemedi.'),
      );
    }

    final list = jsonDecode(response.body) as List<dynamic>;
    return list
        .map((e) => SellerOrder.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> updateSellerOrderStatus({
    required int orderId,
    required String status,
  }) async {
    final response = await http.put(
      Uri.parse('$baseUrl/api/seller/orders/$orderId/status'),
      headers: _authHeaders(),
      body: jsonEncode({'status': status}),
    );

    if (response.statusCode != 204) {
      throw ApiException(
        _extractErrorMessage(response.body, 'Siparis durumu guncellenemedi.'),
      );
    }
  }

  // ── User Profile ─────────────────────────────────────────────────────────

  Future<Map<String, dynamic>> getMe() async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/users/me'),
      headers: _authHeaders(),
    );

    if (response.statusCode != 200) {
      throw ApiException(
        _extractErrorMessage(response.body, 'Profil bilgileri yuklenemedi.'),
      );
    }

    return jsonDecode(response.body) as Map<String, dynamic>;
  }

  Future<void> updateMe({
    required String fullName,
    required String phone,
  }) async {
    final response = await http.put(
      Uri.parse('$baseUrl/api/users/me'),
      headers: _authHeaders(),
      body: jsonEncode({'fullName': fullName, 'phone': phone}),
    );

    if (response.statusCode != 204) {
      throw ApiException(
        _extractErrorMessage(response.body, 'Profil guncellenemedi.'),
      );
    }
  }

  Future<List<AppNotification>> getMyNotifications() async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/users/me/notifications'),
      headers: _authHeaders(),
    );

    if (response.statusCode != 200) {
      throw ApiException(
        _extractErrorMessage(response.body, 'Bildirimler yuklenemedi.'),
      );
    }

    final list = jsonDecode(response.body) as List<dynamic>;
    return list
        .map((e) => AppNotification.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> markNotificationAsRead(int notificationId) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/users/me/notifications/$notificationId/read'),
      headers: _authHeaders(),
    );

    if (response.statusCode != 204) {
      throw ApiException(
        _extractErrorMessage(response.body, 'Bildirim guncellenemedi.'),
      );
    }
  }

  // ── Orders ────────────────────────────────────────────────────────────────

  Future<List<CustomerOrder>> getMyOrders({bool onlyActive = false}) async {
    final uri = Uri.parse(
      '$baseUrl/api/customer/orders/my',
    ).replace(queryParameters: {'onlyActive': onlyActive.toString()});
    final response = await http.get(uri, headers: _authHeaders());
    if (response.statusCode != 200) {
      throw ApiException(
        _extractErrorMessage(response.body, 'Siparisler yuklenemedi.'),
      );
    }
    final list = jsonDecode(response.body) as List<dynamic>;
    return list
        .map((e) => CustomerOrder.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<List<CustomerOrder>> getMyReservations() async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/customer/reservations/my'),
      headers: _authHeaders(),
    );
    if (response.statusCode != 200) {
      throw ApiException(
        _extractErrorMessage(response.body, 'Rezervasyonlar yuklenemedi.'),
      );
    }
    final list = jsonDecode(response.body) as List<dynamic>;
    return list
        .map((e) => CustomerOrder.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<CustomerOrder> getOrderDetail(int orderId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/customer/orders/$orderId'),
      headers: _authHeaders(),
    );
    if (response.statusCode == 404) {
      throw ApiException('Siparis bulunamadi.');
    }
    if (response.statusCode != 200) {
      throw ApiException('Siparis detayi yuklenemedi.');
    }
    return CustomerOrder.fromJson(
      jsonDecode(response.body) as Map<String, dynamic>,
    );
  }

  Future<void> cancelOrder(int orderId) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/customer/orders/$orderId/cancel'),
      headers: _authHeaders(),
    );
    if (response.statusCode != 200) {
      throw ApiException(
        _extractErrorMessage(response.body, 'Iptal basarisiz.'),
      );
    }
  }

  // ── helpers ───────────────────────────────────────────────────────────────

  Map<String, String> _authHeaders() {
    final token = AppState.currentUser?.token ?? '';
    return {
      'Content-Type': 'application/json',
      if (token.isNotEmpty) 'Authorization': 'Bearer $token',
    };
  }

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
        final prefix = (message != null && message.isNotEmpty)
            ? '$message\n'
            : '';
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



