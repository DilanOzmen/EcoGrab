import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:food_waste_app/core/app_assets.dart';
import 'package:food_waste_app/core/app_colors.dart';
import 'package:food_waste_app/core/app_state.dart';
import 'package:food_waste_app/data/services/api_client.dart';
import 'package:food_waste_app/screens/notifications_screen.dart';

class ProfileScreen extends StatefulWidget {
  final ApiClient apiClient;
  final VoidCallback onLogout;
  final VoidCallback onOrdersTap;

  const ProfileScreen({
    super.key,
    required this.apiClient,
    required this.onLogout,
    required this.onOrdersTap,
  });

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with SingleTickerProviderStateMixin {
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
    try {
      final data = await widget.apiClient.getMe();
      _fullNameController.text = data['fullName']?.toString() ?? '';
      _phoneController.text = data['phone']?.toString() ?? '';
      return data;
    } catch (_) {
      final fallback = <String, dynamic>{
        'fullName': AppState.currentUser?.fullName ?? 'Kullanıcı',
        'email': AppState.currentUser?.email ?? '-',
        'role': AppState.currentUser?.role ?? '-',
        'phone': '-',
      };
      _fullNameController.text = fallback['fullName'].toString();
      _phoneController.text = fallback['phone'].toString();
      return fallback;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _fullNameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _refreshProfile() async {
    final future = _loadProfile();
    if (mounted) {
      setState(() {
        _profileFuture = future;
      });
    }
    await future;
  }

  Future<void> _saveProfile() async {
    if (_fullNameController.text.trim().isEmpty ||
        _phoneController.text.trim().isEmpty) {
      _showMessage('Ad soyad ve telefon zorunludur.');
      return;
    }

    setState(() => _saving = true);

    try {
      await widget.apiClient.updateMe(
        fullName: _fullNameController.text.trim(),
        phone: _phoneController.text.trim(),
      );

      if (!mounted) return;

      setState(() {
        _editing = false;
        _profileFuture = _loadProfile();
      });

      _showMessage('Profil başarıyla güncellendi.');
    } catch (e) {
      if (!mounted) return;
      _showMessage(e.toString().replaceAll('ApiException: ', ''));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  String _initials(String nameOrEmail) {
    final value = nameOrEmail.trim();
    if (value.isEmpty) return '?';

    final parts = value.split(' ').where((e) => e.isNotEmpty).toList();

    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }

    return value[0].toUpperCase();
  }

  String _friendlyRole(String role) {
    final normalized = role.toLowerCase();

    if (normalized == 'customer' || normalized == 'musteri') {
      return 'Müşteri';
    }

    if (normalized == 'seller' || normalized == 'satici') {
      return 'Satıcı';
    }

    return role;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>>(
      future: _profileFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.primaryGreen),
          );
        }

        if (snapshot.hasError) {
          return _errorState(snapshot.error.toString());
        }

        final data = snapshot.data ?? {};

        final fullName =
            data['fullName']?.toString() ??
            AppState.currentUser?.fullName ??
            'Kullanıcı';

        final email =
            data['email']?.toString() ?? AppState.currentUser?.email ?? '-';

        final role =
            data['role']?.toString() ?? AppState.currentUser?.role ?? '-';

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
                          _profileHeroCard(fullName, email, role),
                          const SizedBox(height: 18),
                          _infoCard(email, phone, role),
                          const SizedBox(height: 18),
                          _editProfileCard(),
                          const SizedBox(height: 18), // Boşluk ekledik
                          _changePasswordCard(), // <-- MÜŞTERİ İÇİN ŞİFRE DEĞİŞTİRME KARTI BURADA
                          const SizedBox(height: 18), // Boşluk ekledik
                          _menuItem(
                            icon: Icons.receipt_long_rounded,
                            title: 'Sipariş ve Rezervasyonlarım',
                            subtitle: 'Aktif ve geçmiş işlemlerini görüntüle',
                            onTap: widget.onOrdersTap,
                          ),
                          _menuItem(
                            icon: Icons.notifications_outlined,
                            title: 'Bildirimlerim',
                            subtitle: 'Rezervasyon ve sipariş güncellemeleri',
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => NotificationsScreen(
                                    apiClient: widget.apiClient,
                                  ),
                                ),
                              );
                            },
                          ),
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
        Image.asset(
          AppAssets.ecograbLogo,
          width: 40,
          height: 40,
          fit: BoxFit.contain,
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            'Profilim',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 24,
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

  Widget _profileHeroCard(String fullName, String email, String role) {
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
              Icons.eco,
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

  // Şifre değiştirme penceresini açan fonksiyon
  void _showChangePasswordDialog() {
    final oldController = TextEditingController();
    final newController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text(
          'Şifre Değiştir',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: oldController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Mevcut Şifre',
                prefixIcon: Icon(Icons.lock_open),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: newController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Yeni Şifre',
                prefixIcon: Icon(Icons.lock_outline),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Vazgeç'),
          ),
          ElevatedButton(
            onPressed: () =>
                _handleChangePassword(oldController.text, newController.text),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryGreen,
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

  // API isteğini atan fonksiyon
  Future<void> _handleChangePassword(String oldP, String newP) async {
    try {
      final apiClient =
          ApiClient(); // Dosyanın başında import edildiğinden emin ol
      await apiClient.changePassword(oldPassword: oldP, newPassword: newP);
      if (!mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Şifre başarıyla güncellendi.')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.toString())));
    }
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
                  'Profil Bilgilerini Güncelle',
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
                'Ad soyad ve telefon bilgilerini buradan güncelleyebilirsin.',
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

  Widget _menuItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: _cardDecoration(),
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: _miniIcon(icon),
        title: Text(
          title,
          style: GoogleFonts.manrope(
            fontWeight: FontWeight.w900,
            color: AppColors.textDark,
            fontSize: 14,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: GoogleFonts.manrope(
            fontSize: 12,
            color: AppColors.textSoft,
            fontWeight: FontWeight.w600,
          ),
        ),
        trailing: const Icon(
          Icons.chevron_right_rounded,
          color: AppColors.primaryGreen,
        ),
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

  Widget _changePasswordCard() {
    return Container(
      margin: const EdgeInsets.only(top: 18), // Diğer kartlarla arayı açar
      padding: const EdgeInsets.all(18),
      decoration: _cardDecoration(), // Mevcut kart tasarımıyla aynı olur
      child: Row(
        children: [
          _miniIcon(Icons.lock_reset_rounded), // Kilit ikonu
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Şifre İşlemleri',
                  style: GoogleFonts.plusJakartaSans(
                    fontWeight: FontWeight.w900,
                    fontSize: 15,
                    color: AppColors.textDark,
                  ),
                ),
                Text(
                  'Güvenliğin için şifreni buradan güncelleyebilirsin.',
                  style: GoogleFonts.manrope(
                    color: AppColors.textSoft,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: _showChangePasswordDialog, // Pop-up'ı açar
            child: const Text('Değiştir'),
          ),
        ],
      ),
    );
  }
}
