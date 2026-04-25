import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:food_waste_app/core/app_state.dart';
import 'package:food_waste_app/data/services/api_client.dart';

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

class _ProfileScreenState extends State<ProfileScreen> {
  static const primary = Color(0xFF0F5238);
  static const background = Color(0xFFF8FAF8);
  static const surfaceLow = Color(0xFFF2F4F2);
  static const textDark = Color(0xFF191C1B);
  static const textSoft = Color(0xFF707973);

  late Future<Map<String, dynamic>> _profileFuture;

  final _fullNameController = TextEditingController();
  final _phoneController = TextEditingController();

  bool _editing = false;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _profileFuture = _loadProfile();
  }

  Future<Map<String, dynamic>> _loadProfile() async {
    final data = await widget.apiClient.getMe();
    _fullNameController.text = data['fullName']?.toString() ?? '';
    _phoneController.text = data['phone']?.toString() ?? '';
    return data;
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _phoneController.dispose();
    super.dispose();
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

      setState(() {
        _editing = false;
        _profileFuture = _loadProfile();
      });

      _showMessage('Profil başarıyla güncellendi.');
    } catch (e) {
      _showMessage(e.toString().replaceAll('ApiException: ', ''));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
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

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>>(
      future: _profileFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Text(
                snapshot.error.toString().replaceAll('ApiException: ', ''),
                textAlign: TextAlign.center,
              ),
            ),
          );
        }

        final data = snapshot.data ?? {};
        final fullName = data['fullName']?.toString() ??
            AppState.currentUser?.fullName ??
            'Kullanıcı';
        final email =
            data['email']?.toString() ?? AppState.currentUser?.email ?? '-';
        final role =
            data['role']?.toString() ?? AppState.currentUser?.role ?? '-';
        final phone = data['phone']?.toString() ?? '-';

        return Scaffold(
          backgroundColor: background,
          body: SafeArea(
            child: RefreshIndicator(
              onRefresh: () async {
                setState(() {
                  _profileFuture = _loadProfile();
                });
                await _profileFuture;
              },
              child: ListView(
                padding: const EdgeInsets.fromLTRB(22, 18, 22, 32),
                children: [
                  _header(),
                  const SizedBox(height: 24),
                  _profileCard(fullName, email, role),
                  const SizedBox(height: 18),
                  _infoCard(email, phone, role),
                  const SizedBox(height: 18),
                  _editProfileCard(),
                  const SizedBox(height: 18),
                  _menuItem(
                    icon: Icons.receipt_long,
                    title: 'Sipariş ve Rezervasyonlarım',
                    subtitle: 'Aktif ve geçmiş işlemlerini görüntüle',
                    onTap: widget.onOrdersTap,
                  ),
                  _menuItem(
                    icon: Icons.notifications_outlined,
                    title: 'Bildirimlerim',
                    subtitle: 'Rezervasyon ve sipariş güncellemeleri',
                    onTap: () {
                      _showMessage('Bildirim ekranı sonraki adımda bağlanacak.');
                    },
                  ),
                  const SizedBox(height: 16),
                  _logoutButton(),
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
        Text(
          'Profilim',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 24,
            fontWeight: FontWeight.w800,
            color: primary,
          ),
        ),
        const Spacer(),
        IconButton(
          onPressed: () {
            setState(() {
              _profileFuture = _loadProfile();
            });
          },
          icon: const Icon(Icons.refresh, color: primary),
        ),
      ],
    );
  }

  Widget _profileCard(String fullName, String email, String role) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: surfaceLow,
        borderRadius: BorderRadius.circular(28),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 38,
            backgroundColor: const Color(0xFFB1F0CE),
            child: Text(
              _initials(fullName),
              style: GoogleFonts.plusJakartaSans(
                color: primary,
                fontSize: 24,
                fontWeight: FontWeight.w800,
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
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 21,
                    fontWeight: FontWeight.w800,
                    color: textDark,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  email,
                  style: GoogleFonts.manrope(
                    fontSize: 13,
                    color: textSoft,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                  decoration: BoxDecoration(
                    color: primary.withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    role,
                    style: GoogleFonts.manrope(
                      color: primary,
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
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

 

  

  Widget _infoCard(String email, String phone, String role) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: surfaceLow,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: [
          _infoRow(Icons.email_outlined, 'E-posta', email),
          const Divider(),
          _infoRow(Icons.phone_outlined, 'Telefon', phone),
          const Divider(),
          _infoRow(Icons.verified_user_outlined, 'Rol', role),
        ],
      ),
    );
  }

  Widget _infoRow(IconData icon, String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: Row(
        children: [
          Icon(icon, color: primary, size: 22),
          const SizedBox(width: 12),
          Text(
            title,
            style: GoogleFonts.manrope(
              fontWeight: FontWeight.w800,
              color: textDark,
            ),
          ),
          const Spacer(),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: GoogleFonts.manrope(color: textSoft),
            ),
          ),
        ],
      ),
    );
  }

  Widget _editProfileCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Profil Bilgilerini Güncelle',
                style: GoogleFonts.plusJakartaSans(
                  fontWeight: FontWeight.w800,
                  fontSize: 16,
                  color: textDark,
                ),
              ),
              const Spacer(),
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
          if (_editing) ...[
            const SizedBox(height: 12),
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
              height: 48,
              child: ElevatedButton(
                onPressed: _saving ? null : _saveProfile,
                style: ElevatedButton.styleFrom(
                  backgroundColor: primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
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
                    : const Text('Kaydet'),
              ),
            ),
          ],
        ],
      ),
    );
  }

  InputDecoration _input(String hint, IconData icon) {
    return InputDecoration(
      hintText: hint,
      prefixIcon: Icon(icon, color: textSoft),
      filled: true,
      fillColor: surfaceLow,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: BorderSide.none,
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
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        onTap: onTap,
        tileColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        leading: CircleAvatar(
          backgroundColor: surfaceLow,
          child: Icon(icon, color: primary),
        ),
        title: Text(
          title,
          style: GoogleFonts.manrope(fontWeight: FontWeight.w800),
        ),
        subtitle: Text(
          subtitle,
          style: GoogleFonts.manrope(fontSize: 12, color: textSoft),
        ),
        trailing: const Icon(Icons.chevron_right),
      ),
    );
  }

  Widget _logoutButton() {
    return SizedBox(
      height: 52,
      child: OutlinedButton.icon(
        onPressed: widget.onLogout,
        icon: const Icon(Icons.logout),
        label: const Text('Oturumu Kapat'),
        style: OutlinedButton.styleFrom(
          foregroundColor: Colors.red.shade700,
          side: BorderSide(color: Colors.red.shade100),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
        ),
      ),
    );
  }
}