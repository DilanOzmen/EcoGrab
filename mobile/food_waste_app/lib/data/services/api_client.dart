import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/auth_response.dart';

class ApiClient {
  static const String baseUrl = 'http://localhost:5141';

  Future<AuthResponse> login(String email, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': email,
        'password': password,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('Login failed');
    }

    final data = jsonDecode(response.body);
    return AuthResponse.fromJson(data);
  }
}