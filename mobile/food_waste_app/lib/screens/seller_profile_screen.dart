import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:food_waste_app/core/app_assets.dart';
import 'package:food_waste_app/core/app_colors.dart';
import 'package:food_waste_app/core/app_state.dart';
import 'package:food_waste_app/data/services/api_client.dart';

class SellerProfileScreen extends StatefulWidget {
  final VoidCallback onLogout;

  const SellerProfileScreen({super.key, required this.onLogout});

  @override
  State<SellerProfileScreen> createState() => _SellerProfileScreenState();
}

class _SellerProfileScreenState extends State<SellerProfileScreen>
    with SingleTickerProviderStateMixin {
  final ApiClient _apiClient = ApiClient();

  late Future<Map<String, dynamic>> _profileFuture;

  final _fullNameController = TextEditingController();
  final _phoneController = TextEditingController();

  bool _editing = false;
  bool _saving = false;

  late final AnimationController _controller;
  late final Animation<double> _fade;
  late final Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();

    _profileFuture = _loadProfile();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 650),
    );

    _fade = CurvedAnimation(parent: _controller, curve: Curves.easeOut);

    _slide = Tween<Offset>(
      begin: const Offset(0, 0.05),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));

    _controller.forward();
  }

  Future<Map<String, dynamic>> _loadProfile() async {
    final data = await _apiClient.getMe();

    _fullNameController.text = data['fullName']?.toString() ?? '';
    _phoneController.text = data['phone']?.toString() ?? '';

    return data;
  }

  Future<void> _refreshProfile() async {
    final future = _loadProfile();
    setState(() => _profileFuture = future);
    await future;
  }

  // 1. Şifre değiştirme mantığını yöneten metod
  Future<void> _handleChangePassword(String oldP, String newP) async {
    try {
      await _apiClient.changePassword(oldPassword: oldP, newPassword: newP);
      if (!mounted) return;
      Navigator.pop(context); // Dialog'u kapat
      _showMessage('Şifreniz başarıyla değiştirildi.');
    } catch (e) {
      if (!mounted) return;
      _showMessage(e.toString());
    }
  }

  // 2. Şifre değiştirme pop-up'ını (Dialog) gösteren metod
  void _showChangePasswordDialog() {
    final oldController = TextEditingController();
    final newController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text(
          'Şifre Değiştir',
          style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w800),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: oldController,
              obscureText: true,
              decoration: _input('Mevcut Şifre', Icons.lock_open_rounded),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: newController,
              obscureText: true,
              decoration: _input('Yeni Şifre', Icons.lock_outline_rounded),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Vazgeç', style: TextStyle(color: AppColors.textSoft)),
          ),
          ElevatedButton(
            onPressed: () {
              if (oldController.text.isEmpty || newController.text.isEmpty) {
                _showMessage('Lütfen tüm alanları doldurun.');
                return;
              }
              _handleChangePassword(oldController.text, newController.text);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryGreen,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'Güncelle',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _saveProfile() async {
    if (_fullNameController.text.trim().isEmpty ||
        _phoneController.text.trim().isEmpty) {
      _showMessage('Ad soyad ve telefon zorunludur.');
      return;
    }

    setState(() => _saving = true);

    try {
      await _apiClient.updateMe(
        fullName: _fullNameController.text.trim(),
        phone: _phoneController.text.trim(),
      );

      if (!mounted) return;

      setState(() {
        _editing = false;
        _profileFuture = _loadProfile();
      });

      _showMessage('Satıcı profili başarıyla güncellendi.');
    } catch (e) {
      if (!mounted) return;
      _showMessage(e.toString().replaceAll('ApiException: ', ''));
    } finally {
      if (mounted) {
        setState(() => _saving = false);
      }
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  String _initials(String value) {
    final text = value.trim();

    if (text.isEmpty) return '?';

    final parts = text.split(' ').where((item) => item.isNotEmpty).toList();

    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }

    return text[0].toUpperCase();
  }

  String _friendlyRole(String role) {
    final normalized = role.toLowerCase();

    if (normalized == 'seller' || normalized == 'satici') {
      return 'Satıcı';
    }

    if (normalized == 'customer' || normalized == 'musteri') {
      return 'Müşteri';
    }

    return role;
  }

  @override
  void dispose() {
    _controller.dispose();
    _fullNameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>>(
      future: _profileFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            backgroundColor: AppColors.background,
            body: Center(
              child: CircularProgressIndicator(color: AppColors.primaryGreen),
            ),
          );
        }

        if (snapshot.hasError) {
          return _errorState(snapshot.error.toString());
        }

        final data = snapshot.data ?? {};

        final fullName =
            data['fullName']?.toString() ??
            AppState.currentUser?.fullName ??
            'Satıcı';

        final email =
            data['email']?.toString() ?? AppState.currentUser?.email ?? '-';

        final role =
            data['role']?.toString() ?? AppState.currentUser?.role ?? 'seller';

        final phone = data['phone']?.toString() ?? '-';

        return Scaffold(
          backgroundColor: AppColors.background,
          body: SafeArea(
            child: RefreshIndicator(
              color: AppColors.primaryGreen,
              onRefresh: _refreshProfile,
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(20, 18, 20, 36),
                children: [
                  FadeTransition(
                    opacity: _fade,
                    child: SlideTransition(
                      position: _slide,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _header(),
                          const SizedBox(height: 20),
                          _sellerHeroCard(fullName, email, role),
                          const SizedBox(height: 18),
                          _infoCard(email, phone, role),
                          const SizedBox(height: 18),
                          _editProfileCard(),
                          const SizedBox(height: 18),
                          _changePasswordCard(), // <-- ŞİFRE DEĞİŞTİRME KARTI BURAYA EKLENDİ
                          const SizedBox(height: 18),
                          _sellerNoteCard(),
                          const SizedBox(height: 16),
                          _logoutButton(),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _header() {
    return Row(
      children: [
        IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back_rounded),
          color: AppColors.primaryGreen,
        ),
        Image.asset(
          AppAssets.ecograbLogo,
          width: 40,
          height: 40,
          fit: BoxFit.contain,
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            'Satıcı Profilim',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 23,
              fontWeight: FontWeight.w900,
              color: AppColors.primaryGreen,
            ),
          ),
        ),
        IconButton(
          onPressed: _refreshProfile,
          icon: const Icon(Icons.refresh_rounded),
          color: AppColors.primaryGreen,
        ),
      ],
    );
  }

  Widget _sellerHeroCard(String fullName, String email, String role) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: AppColors.splashGradient,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryGreen.withValues(alpha: 0.25),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -35,
            top: -45,
            child: Icon(
              Icons.storefront_rounded,
              size: 150,
              color: Colors.white.withValues(alpha: 0.08),
            ),
          ),
          Row(
            children: [
              CircleAvatar(
                radius: 40,
                backgroundColor: Colors.white.withValues(alpha: 0.18),
                child: Text(
                  _initials(fullName),
                  style: GoogleFonts.plusJakartaSans(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      fullName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.plusJakartaSans(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      email,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.manrope(
                        color: Colors.white.withValues(alpha: 0.78),
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.12),
                        ),
                      ),
                      child: Text(
                        _friendlyRole(role),
                        style: GoogleFonts.manrope(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _infoCard(String email, String phone, String role) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: _cardDecoration(),
      child: Column(
        children: [
          _infoRow(Icons.email_outlined, 'E-posta', email),
          const Divider(height: 22),
          _infoRow(Icons.phone_outlined, 'Telefon', phone),
          const Divider(height: 22),
          _infoRow(Icons.verified_user_outlined, 'Rol', _friendlyRole(role)),
        ],
      ),
    );
  }

  Widget _infoRow(IconData icon, String title, String value) {
    return Row(
      children: [
        _miniIcon(icon),
        const SizedBox(width: 12),
        Text(
          title,
          style: GoogleFonts.manrope(
            fontWeight: FontWeight.w900,
            color: AppColors.textDark,
            fontSize: 13,
          ),
        ),
        const Spacer(),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: GoogleFonts.manrope(
              color: AppColors.textSoft,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _editProfileCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _miniIcon(Icons.edit_outlined),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Satıcı Bilgilerini Güncelle',
                  style: GoogleFonts.plusJakartaSans(
                    fontWeight: FontWeight.w900,
                    fontSize: 15,
                    color: AppColors.textDark,
                  ),
                ),
              ),
              TextButton(
                onPressed: _saving
                    ? null
                    : () {
                        setState(() => _editing = !_editing);
                      },
                child: Text(_editing ? 'Vazgeç' : 'Düzenle'),
              ),
            ],
          ),
          AnimatedCrossFade(
            duration: const Duration(milliseconds: 240),
            crossFadeState: _editing
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            firstChild: Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                'Satıcı hesabına ait ad soyad ve telefon bilgilerini buradan güncelleyebilirsin.',
                style: GoogleFonts.manrope(
                  color: AppColors.textSoft,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            secondChild: Column(
              children: [
                const SizedBox(height: 14),
                TextField(
                  controller: _fullNameController,
                  decoration: _input('Ad Soyad', Icons.person_outline),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  decoration: _input('Telefon', Icons.phone_outlined),
                ),
                const SizedBox(height: 14),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: AppColors.editorialGradient,
                      borderRadius: BorderRadius.circular(18),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primaryGreen.withValues(alpha: 0.18),
                          blurRadius: 18,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: ElevatedButton(
                      onPressed: _saving ? null : _saveProfile,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                      ),
                      child: _saving
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : Text(
                              'Kaydet',
                              style: GoogleFonts.plusJakartaSans(
                                color: Colors.white,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _changePasswordCard() {
    return InkWell(
      // Tıklanabilir olması için InkWell ekledik
      onTap: _showChangePasswordDialog,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white, // Rengi garantilemek için direkt beyaz verdik
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: Colors.grey.shade200,
          ), // Kenarlık belirgin olsun
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.5),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.vpn_key_outlined, color: Colors.green),
            ),
            const SizedBox(width: 15),
            const Expanded(
              child: Text(
                'Şifremi Değiştir',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ),
            const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  Widget _sellerNoteCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: _cardDecoration(),
      child: Row(
        children: [
          _miniIcon(Icons.eco_outlined),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Satıcı panelinde ürünlerini ekleyebilir, stoklarını takip edebilir ve gelen siparişleri yönetebilirsin.',
              style: GoogleFonts.manrope(
                color: AppColors.textSoft,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  InputDecoration _input(String hint, IconData icon) {
    return InputDecoration(
      hintText: hint,
      prefixIcon: Icon(icon, color: AppColors.textSoft),
      filled: true,
      fillColor: AppColors.surfaceContainer.withValues(alpha: 0.65),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: const BorderSide(color: AppColors.primaryGreen, width: 1.3),
      ),
    );
  }

  Widget _logoutButton() {
    return SizedBox(
      height: 54,
      child: OutlinedButton.icon(
        onPressed: widget.onLogout,
        icon: const Icon(Icons.logout_rounded),
        label: const Text('Oturumu Kapat'),
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.error,
          side: BorderSide(color: AppColors.error.withValues(alpha: 0.22)),
          backgroundColor: AppColors.error.withValues(alpha: 0.04),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
        ),
      ),
    );
  }

  Widget _miniIcon(IconData icon) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: AppColors.freshGreen.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Icon(icon, color: AppColors.primaryGreen, size: 21),
    );
  }

  BoxDecoration _cardDecoration() {
    return BoxDecoration(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(24),
      border: Border.all(color: AppColors.surfaceContainer),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.035),
          blurRadius: 18,
          offset: const Offset(0, 8),
        ),
      ],
    );
  }

  Widget _errorState(String error) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Container(
            padding: const EdgeInsets.all(22),
            decoration: _cardDecoration(),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.error_outline_rounded,
                  color: AppColors.error,
                  size: 42,
                ),
                const SizedBox(height: 12),
                Text(
                  error.replaceAll('ApiException: ', ''),
                  textAlign: TextAlign.center,
                  style: GoogleFonts.manrope(
                    color: AppColors.error,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 14),
                TextButton(
                  onPressed: _refreshProfile,
                  child: const Text('Tekrar Dene'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
