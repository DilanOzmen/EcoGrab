import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(const FoodWasteApp());
}

class FoodWasteApp extends StatelessWidget {
  const FoodWasteApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Food Waste App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
      ),
      home: const LoginPage(),
    );
  }
}

class ApiClient {
  static const String baseUrl = 'http://localhost:5141';

  Future<Map<String, dynamic>> login(String email, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );

    if (response.statusCode != 200) {
      throw Exception('Giris basarisiz');
    }

    return jsonDecode(response.body) as Map<String, dynamic>;
  }

  Future<void> register(String fullName, String email, String password, String phone, String role) async {
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
      throw Exception('Kayit basarisiz');
    }
  }
}

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _apiClient = ApiClient();
  String _error = '';

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    setState(() => _error = '');
    try {
      final result = await _apiClient.login(
        _emailController.text.trim(),
        _passwordController.text,
      );

      final role = (result['role'] ?? '').toString();
      if (!mounted) {
        return;
      }

      if (role == 'Seller') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const SellerHomePage()),
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const CustomerHomePage()),
        );
      }
    } catch (_) {
      setState(() => _error = 'Giris basarisiz. Bilgileri kontrol edin.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Giris')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: 'E-posta'),
            ),
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'Sifre'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(onPressed: _login, child: const Text('Giris Yap')),
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const RegisterPage()),
                );
              },
              child: const Text('Kayit Ol'),
            ),
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const GuestHomePage()),
                );
              },
              child: const Text('Misafir devam et'),
            ),
            if (_error.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(_error, style: const TextStyle(color: Colors.red)),
              ),
          ],
        ),
      ),
    );
  }
}

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _phoneController = TextEditingController();
  final _apiClient = ApiClient();
  String _selectedRole = 'Customer';
  String _message = '';

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    setState(() => _message = '');
    try {
      await _apiClient.register(
        _fullNameController.text.trim(),
        _emailController.text.trim(),
        _passwordController.text,
        _phoneController.text.trim(),
        _selectedRole,
      );
      setState(() => _message = 'Kayit basarili. Giris yapabilirsiniz.');
    } catch (_) {
      setState(() => _message = 'Kayit basarisiz.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Kayit')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            TextField(
              controller: _fullNameController,
              decoration: const InputDecoration(labelText: 'Ad Soyad'),
            ),
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: 'E-posta'),
            ),
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'Sifre'),
            ),
            TextField(
              controller: _phoneController,
              decoration: const InputDecoration(labelText: 'Telefon'),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              initialValue: _selectedRole,
              items: const [
                DropdownMenuItem(value: 'Customer', child: Text('Musteri')),
                DropdownMenuItem(value: 'Seller', child: Text('Isletme')),
              ],
              onChanged: (value) {
                if (value != null) {
                  setState(() => _selectedRole = value);
                }
              },
              decoration: const InputDecoration(labelText: 'Kayit Turu'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(onPressed: _register, child: const Text('Kayit Ol')),
            if (_message.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(_message),
              ),
          ],
        ),
      ),
    );
  }
}

class GuestHomePage extends StatelessWidget {
  const GuestHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Misafir Anasayfa')),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            showDialog<void>(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text('Giris Gerekli'),
                content: const Text('Islem yapmak icin giris yapmalisiniz.'),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (_) => const LoginPage()),
                      );
                    },
                    child: const Text('Giris Ekranina Git'),
                  ),
                ],
              ),
            );
          },
          child: const Text('Urun detaya tikla (misafir testi)'),
        ),
      ),
    );
  }
}

class CustomerHomePage extends StatelessWidget {
  const CustomerHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Musteri Anasayfa')),
      body: const Center(
        child: Text('Musteri ekranlari (ana sayfa, urun detay, harita, siparislerim) icin temel yonlendirme hazir.'),
      ),
    );
  }
}

class SellerHomePage extends StatelessWidget {
  const SellerHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Satici Paneli')),
      body: const Center(
        child: Text('Satici urun yonetimi ve siparis durum guncelleme API hazir.'),
      ),
    );
  }
}
