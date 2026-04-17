import 'package:flutter/material.dart';
import '../core/app_colors.dart'; // Bu importun doğruluğundan emin ol

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool isCustomer = true; 
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 60),
              _buildHeader(),
              const SizedBox(height: 48),
              _buildWelcomeText(),
              const SizedBox(height: 32),
              _buildRoleToggle(),
              const SizedBox(height: 40),
              _buildForm(),
              const SizedBox(height: 32),
              _buildLoginButton(),
              const SizedBox(height: 40),
              _buildSecurityBadge(),
            ],
          ),
        ),
      ),
    );
  }

  // Widget Parçaları (Kodun okunabilirliği için metodlara böldük)
  Widget _buildHeader() => Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      const Text("The Living Larder", style: TextStyle(color: AppColors.primaryGreen, fontSize: 22, fontWeight: FontWeight.w800)),
      const Icon(Icons.location_on, color: AppColors.primaryGreen),
    ],
  );

  Widget _buildWelcomeText() => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const Text("Hoş Geldiniz", style: TextStyle(fontSize: 32, fontWeight: FontWeight.w800)),
      Text("Platformu nasıl kullanmak istersiniz?", style: TextStyle(color: AppColors.onSurfaceVariant, fontWeight: FontWeight.w500)),
    ],
  );

  Widget _buildRoleToggle() => Container(
    padding: const EdgeInsets.all(6),
    decoration: BoxDecoration(color: const Color(0xFFF2F4F2), borderRadius: BorderRadius.circular(16)),
    child: Row(
      children: [
        _roleButton("Müşteri", isCustomer, Icons.person, () => setState(() => isCustomer = true)),
        _roleButton("Satıcı", !isCustomer, Icons.storefront, () => setState(() => isCustomer = false)),
      ],
    ),
  );

  Widget _buildForm() => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const Text("E-posta Adresi", style: TextStyle(fontWeight: FontWeight.bold)),
      const SizedBox(height: 8),
      _customTextField(_emailController, "ornek@email.com", Icons.email_outlined),
      const SizedBox(height: 24),
      const Text("Şifre", style: TextStyle(fontWeight: FontWeight.bold)),
      const SizedBox(height: 8),
      _customTextField(_passwordController, "••••••••", Icons.lock_outline, isPass: true),
    ],
  );

  Widget _buildLoginButton() => Container(
    width: double.infinity,
    height: 56,
    decoration: BoxDecoration(
      gradient: AppColors.editorialGradient,
      borderRadius: BorderRadius.circular(16),
      boxShadow: [BoxShadow(color: AppColors.primaryGreen.withValues(alpha: 0.2), blurRadius: 20, offset: const Offset(0, 8))],
    ),
    child: ElevatedButton(
      style: ElevatedButton.styleFrom(backgroundColor: Colors.transparent, shadowColor: Colors.transparent),
      onPressed: () { /* UC3: Auth Service Çağrısı Buraya */ },
      child: const Text("Giriş Yap", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
    ),
  );

  Widget _buildSecurityBadge() => Center(
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(color: AppColors.primaryGreen.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(20)),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.verified_user, size: 16, color: AppColors.primaryGreen),
          SizedBox(width: 8),
          Text("JWT-tabanlı güvenli oturum yönetimi", style: TextStyle(color: AppColors.primaryGreen, fontSize: 12, fontWeight: FontWeight.bold)),
        ],
      ),
    ),
  );

  // Helper Widgetlar
  Widget _roleButton(String lbl, bool sel, IconData icon, VoidCallback tap) => Expanded(
    child: GestureDetector(
      onTap: tap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(color: sel ? Colors.white : Colors.transparent, borderRadius: BorderRadius.circular(12)),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: sel ? AppColors.primaryGreen : Colors.grey, size: 20),
            const SizedBox(width: 8),
            Text(lbl, style: TextStyle(color: sel ? AppColors.primaryGreen : Colors.grey, fontWeight: sel ? FontWeight.bold : FontWeight.normal)),
          ],
        ),
      ),
    ),
  );

  Widget _customTextField(TextEditingController c, String h, IconData i, {bool isPass = false}) => TextField(
    controller: c,
    obscureText: isPass,
    decoration: InputDecoration(
      hintText: h,
      prefixIcon: Icon(i, color: AppColors.onSurfaceVariant),
      filled: true,
      fillColor: AppColors.surfaceContainer,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
    ),
  );
}