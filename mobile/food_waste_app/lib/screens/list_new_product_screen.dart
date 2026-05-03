import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';

import 'package:food_waste_app/core/app_colors.dart';
import 'package:food_waste_app/core/app_assets.dart';
import 'package:food_waste_app/data/services/api_client.dart';

class ListNewProductScreen extends StatefulWidget {
  const ListNewProductScreen({super.key});

  @override
  State<ListNewProductScreen> createState() => _ListNewProductScreenState();
}

class _ListNewProductScreenState extends State<ListNewProductScreen>
    with SingleTickerProviderStateMixin {
  final _apiClient = ApiClient();
  final _formKey = GlobalKey<FormState>();

  final restaurantIdController = TextEditingController();
  final nameController = TextEditingController();
  final descriptionController = TextEditingController();
  final originalPriceController = TextEditingController();
  final discountedPriceController = TextEditingController();

  String selectedCategory = 'Vegetables';
  double stockValue = 10;
  DateTime expiryDate = DateTime.now().add(const Duration(days: 1));
  bool isActive = true;
  bool isSubmitting = false;
  String? _uploadedImageUrl;

  late final AnimationController _controller;
  late final Animation<double> _fade;
  late final Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 650),
    );

    _fade = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
    _slide = Tween<Offset>(
      begin: const Offset(0, 0.06),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    restaurantIdController.dispose();
    nameController.dispose();
    descriptionController.dispose();
    originalPriceController.dispose();
    discountedPriceController.dispose();
    super.dispose();
  }

  Future<void> _pickAndUploadImage() async {
    final ImagePicker picker = ImagePicker();

    final XFile? image = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1024,
      imageQuality: 80,
    );

    if (image == null) return;

    setState(() => isSubmitting = true);

    try {
      final bytes = await image.readAsBytes();
      final imageUrl = await _apiClient.uploadProductImage(bytes, image.name);

      if (!mounted) return;

      setState(() {
        _uploadedImageUrl = imageUrl;
      });

      _showMessage('Görsel başarıyla yüklendi.');
    } catch (e) {
      _showMessage('Görsel yüklenemedi: $e');
    } finally {
      if (mounted) setState(() => isSubmitting = false);
    }
  }

  Future<void> _listProduct() async {
    if (!_formKey.currentState!.validate()) return;

    final restaurantId = int.tryParse(restaurantIdController.text.trim());
    final originalPrice = double.tryParse(originalPriceController.text.trim());
    final discountedPrice =
        double.tryParse(discountedPriceController.text.trim());

    if (restaurantId == null || restaurantId <= 0) {
      _showMessage('Lütfen geçerli bir restoran ID girin.');
      return;
    }

    if (originalPrice == null || originalPrice <= 0) {
      _showMessage('Lütfen geçerli bir orijinal fiyat girin.');
      return;
    }

    setState(() => isSubmitting = true);

    try {
      final newProductId = await _apiClient.createProduct(
        restaurantId: restaurantId,
        name: nameController.text.trim(),
        description: descriptionController.text.trim(),
        originalPrice: originalPrice,
        discountedPrice: discountedPrice ?? originalPrice,
        category: selectedCategory,
        stock: stockValue.round(),
        expiryDate: expiryDate,
        isActive: isActive,
      );

      if (!mounted) return;

      if (newProductId > 0) {
        _showMessage('Ürün başarıyla yayınlandı.');
        Navigator.pop(context, true);
      }
    } catch (e) {
      _showMessage(e.toString().replaceAll('ApiException: ', ''));
    } finally {
      if (mounted) setState(() => isSubmitting = false);
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  String _imageUrl(String path) {
    if (path.startsWith('http')) return path;
    return '${ApiClient.baseUrl}$path';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Stack(
          children: [
            _backgroundLeaves(),
            Column(
              children: [
                _topBar(),
                Expanded(
                  child: Form(
                    key: _formKey,
                    child: FadeTransition(
                      opacity: _fade,
                      child: SlideTransition(
                        position: _slide,
                        child: ListView(
                          padding: const EdgeInsets.fromLTRB(20, 12, 20, 110),
                          children: [
                            _photoPicker(),
                            const SizedBox(height: 24),
                            _sectionTitle('Ürün Detayları'),
                            _inputField(
                              label: 'Restoran ID',
                              controller: restaurantIdController,
                              hint: 'Örn: 1',
                              icon: Icons.storefront_rounded,
                              keyboardType: TextInputType.number,
                            ),
                            _inputField(
                              label: 'Ürün Adı',
                              controller: nameController,
                              hint: 'Örn: Organik Domates Sepeti',
                              icon: Icons.shopping_bag_outlined,
                            ),
                            _inputField(
                              label: 'Açıklama',
                              controller: descriptionController,
                              hint: 'Ürünün içeriğini kısaca anlatın...',
                              icon: Icons.notes_rounded,
                              maxLines: 3,
                            ),
                            _categoryPicker(),
                            const SizedBox(height: 18),
                            Row(
                              children: [
                                Expanded(
                                  child: _inputField(
                                    label: 'Orijinal Fiyat',
                                    controller: originalPriceController,
                                    hint: '100',
                                    icon: Icons.sell_outlined,
                                    keyboardType: TextInputType.number,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: _inputField(
                                    label: 'İndirimli Fiyat',
                                    controller: discountedPriceController,
                                    hint: '60',
                                    icon: Icons.local_offer_rounded,
                                    keyboardType: TextInputType.number,
                                    requiredField: false,
                                  ),
                                ),
                              ],
                            ),
                            _stockCard(),
                            const SizedBox(height: 18),
                            _dateCard(),
                            const SizedBox(height: 18),
                            _activeCard(),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            _bottomButton(),
          ],
        ),
      ),
    );
  }

  Widget _backgroundLeaves() {
    return Stack(
      children: [
        Positioned(
          top: -60,
          right: -60,
          child: Icon(
            Icons.eco,
            size: 210,
            color: AppColors.freshGreen.withValues(alpha: 0.09),
          ),
        ),
        Positioned(
          bottom: -105,
          left: -110,
          child: Icon(
            Icons.eco,
            size: 280,
            color: AppColors.primaryGreen.withValues(alpha: 0.06),
          ),
        ),
      ],
    );
  }

  Widget _topBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 10, 16, 8),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.close_rounded),
            color: AppColors.textDark,
          ),
          Expanded(
            child: Text(
              'Yeni Ürün Listele',
              textAlign: TextAlign.center,
              style: GoogleFonts.plusJakartaSans(
                color: AppColors.textDark,
                fontSize: 20,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          Image.asset(
            AppAssets.ecograbLogo,
            width: 34,
            height: 34,
          ),
        ],
      ),
    );
  }

  Widget _photoPicker() {
    return GestureDetector(
      onTap: isSubmitting ? null : _pickAndUploadImage,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        height: 190,
        decoration: BoxDecoration(
          color: AppColors.freshGreen.withValues(alpha: 0.13),
          borderRadius: BorderRadius.circular(30),
          border: Border.all(
            color: AppColors.primaryGreen.withValues(alpha: 0.18),
            width: 1.4,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.035),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
          ],
          image: _uploadedImageUrl != null
              ? DecorationImage(
                  image: NetworkImage(_imageUrl(_uploadedImageUrl!)),
                  fit: BoxFit.cover,
                )
              : null,
        ),
        child: _uploadedImageUrl == null ? _photoEmptyContent() : _photoOverlay(),
      ),
    );
  }

  Widget _photoEmptyContent() {
    return Stack(
      children: [
        Positioned(
          right: -20,
          top: -24,
          child: Icon(
            Icons.eco,
            size: 120,
            color: AppColors.primaryGreen.withValues(alpha: 0.07),
          ),
        ),
        Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 66,
                height: 66,
                decoration: BoxDecoration(
                  color: AppColors.primaryGreen,
                  borderRadius: BorderRadius.circular(22),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primaryGreen.withValues(alpha: 0.24),
                      blurRadius: 18,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.add_a_photo_rounded,
                  size: 32,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 14),
              Text(
                'Ürün Fotoğrafı Ekle',
                style: GoogleFonts.plusJakartaSans(
                  color: AppColors.primaryGreen,
                  fontSize: 17,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Müşteriler görsellere güvenir.',
                style: GoogleFonts.manrope(
                  color: AppColors.textSoft,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _photoOverlay() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        color: Colors.black.withValues(alpha: 0.22),
      ),
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.92),
            borderRadius: BorderRadius.circular(999),
          ),
          child: Text(
            'Fotoğrafı Değiştir',
            style: GoogleFonts.manrope(
              color: AppColors.primaryGreen,
              fontWeight: FontWeight.w900,
              fontSize: 12,
            ),
          ),
        ),
      ),
    );
  }

  Widget _sectionTitle(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Text(
        text,
        style: GoogleFonts.plusJakartaSans(
          color: AppColors.textDark,
          fontSize: 18,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }

  Widget _inputField({
    required String label,
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
    bool requiredField = true,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _label(label),
          const SizedBox(height: 8),
          TextFormField(
            controller: controller,
            maxLines: maxLines,
            keyboardType: keyboardType,
            style: GoogleFonts.manrope(
              color: AppColors.textDark,
              fontWeight: FontWeight.w700,
              fontSize: 14,
            ),
            decoration: _inputDecoration(hint: hint, icon: icon),
            validator: (value) {
              if (!requiredField) return null;
              if (value == null || value.trim().isEmpty) {
                return 'Bu alan boş bırakılamaz.';
              }
              return null;
            },
          ),
        ],
      ),
    );
  }

  InputDecoration _inputDecoration({
    String? hint,
    IconData? icon,
  }) {
    return InputDecoration(
      hintText: hint,
      hintStyle: GoogleFonts.manrope(
        color: AppColors.textSoft.withValues(alpha: 0.75),
        fontSize: 13,
        fontWeight: FontWeight.w500,
      ),
      prefixIcon: icon != null
          ? Icon(icon, color: AppColors.primaryGreen, size: 21)
          : null,
      filled: true,
      fillColor: AppColors.surface,
      contentPadding: const EdgeInsets.all(18),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
        borderSide: BorderSide(color: AppColors.surfaceContainer),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
        borderSide: BorderSide(color: AppColors.surfaceContainer),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
        borderSide: const BorderSide(
          color: AppColors.primaryGreen,
          width: 1.4,
        ),
      ),
    );
  }

  Widget _categoryPicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _label('Kategori'),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          initialValue: selectedCategory,
          icon: const Icon(
            Icons.keyboard_arrow_down_rounded,
            color: AppColors.primaryGreen,
          ),
          decoration: _inputDecoration(icon: Icons.category_outlined),
          items: ['Vegetables', 'Bakery', 'Dairy', 'Fruit', 'Meal']
              .map(
                (category) => DropdownMenuItem(
                  value: category,
                  child: Text(
                    category,
                    style: GoogleFonts.manrope(
                      fontWeight: FontWeight.w700,
                      color: AppColors.textDark,
                    ),
                  ),
                ),
              )
              .toList(),
          onChanged: (value) {
            if (value == null) return;
            setState(() => selectedCategory = value);
          },
        ),
      ],
    );
  }

  Widget _stockCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: _cardDecoration(),
      child: Column(
        children: [
          Row(
            children: [
              const Icon(
                Icons.inventory_2_outlined,
                color: AppColors.primaryGreen,
                size: 21,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Stok Miktarı',
                  style: GoogleFonts.plusJakartaSans(
                    color: AppColors.textDark,
                    fontWeight: FontWeight.w900,
                    fontSize: 14,
                  ),
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                decoration: BoxDecoration(
                  color: AppColors.primaryGreen,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  '${stockValue.round()} adet',
                  style: GoogleFonts.manrope(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    fontSize: 11,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Slider(
            value: stockValue,
            min: 1,
            max: 50,
            activeColor: AppColors.primaryGreen,
            inactiveColor: AppColors.surfaceContainer,
            onChanged: (value) => setState(() => stockValue = value),
          ),
        ],
      ),
    );
  }

  Widget _dateCard() {
    return InkWell(
      onTap: _selectDate,
      borderRadius: BorderRadius.circular(22),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: _cardDecoration(),
        child: Row(
          children: [
            const Icon(
              Icons.event_available_rounded,
              color: AppColors.primaryGreen,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Son Kullanma Tarihi',
                    style: GoogleFonts.plusJakartaSans(
                      color: AppColors.textDark,
                      fontWeight: FontWeight.w900,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${expiryDate.day}.${expiryDate.month}.${expiryDate.year}',
                    style: GoogleFonts.manrope(
                      color: AppColors.textSoft,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.edit_calendar_rounded,
              color: AppColors.primaryGreen,
              size: 22,
            ),
          ],
        ),
      ),
    );
  }

  Widget _activeCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: _cardDecoration(),
      child: Row(
        children: [
          const Icon(
            Icons.visibility_outlined,
            color: AppColors.primaryGreen,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Ürün müşterilere görünür olsun',
              style: GoogleFonts.manrope(
                color: AppColors.textDark,
                fontSize: 13,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          Switch(
            value: isActive,
            // ignore: deprecated_member_use
            activeColor: AppColors.primaryGreen,
            onChanged: (value) => setState(() => isActive = value),
          ),
        ],
      ),
    );
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: expiryDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primaryGreen,
              onPrimary: Colors.white,
              onSurface: AppColors.textDark,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() => expiryDate = picked);
    }
  }

  Widget _bottomButton() {
    return Positioned(
      left: 20,
      right: 20,
      bottom: 18,
      child: SafeArea(
        child: SizedBox(
          height: 58,
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: AppColors.editorialGradient,
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primaryGreen.withValues(alpha: 0.25),
                  blurRadius: 20,
                  offset: const Offset(0, 9),
                ),
              ],
            ),
            child: ElevatedButton(
              onPressed: isSubmitting ? null : _listProduct,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
              ),
              child: isSubmitting
                  ? const CircularProgressIndicator(color: Colors.white)
                  : Text(
                      'ÜRÜNÜ YAYINLA',
                      style: GoogleFonts.plusJakartaSans(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                        fontSize: 15,
                        letterSpacing: 0.8,
                      ),
                    ),
            ),
          ),
        ),
      ),
    );
  }

  BoxDecoration _cardDecoration() {
    return BoxDecoration(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(22),
      border: Border.all(color: AppColors.surfaceContainer),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.025),
          blurRadius: 16,
          offset: const Offset(0, 7),
        ),
      ],
    );
  }

  Widget _label(String text) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(
        text,
        style: GoogleFonts.manrope(
          fontSize: 12,
          fontWeight: FontWeight.w900,
          color: AppColors.primaryGreen,
        ),
      ),
    );
  }
}