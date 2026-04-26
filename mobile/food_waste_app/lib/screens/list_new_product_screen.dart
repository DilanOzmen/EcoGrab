import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:food_waste_app/data/services/api_client.dart';
import 'package:image_picker/image_picker.dart';

class ListNewProductScreen extends StatefulWidget {
  const ListNewProductScreen({super.key});

  @override
  State<ListNewProductScreen> createState() => _ListNewProductScreenState();
}

class _ListNewProductScreenState extends State<ListNewProductScreen> {
  static const primary = Color(0xFF0F5238);
  static const background = Color(0xFFF8FAF8);
  static const surfaceLow = Color(0xFFF2F4F2);
  static const inputBg = Color(0xFFFFFFFF);
  static const textDark = Color(0xFF191C1B);
  static const textSoft = Color(0xFF707973);

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

  @override
  void dispose() {
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

    if (image != null) {
      setState(() => isSubmitting = true);
      try {
        final bytes = await image.readAsBytes();
        final imageUrl = await _apiClient.uploadProductImage(bytes, image.name);
        
        setState(() {
          _uploadedImageUrl = imageUrl;
          _showMessage('Görsel başarıyla yüklendi!');
        });
      } catch (e) {
        _showMessage('Görsel yüklenemedi: $e');
      } finally {
        setState(() => isSubmitting = false);
      }
    }
  }

  Future<void> _pickExpiryDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: expiryDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (picked != null) {
      setState(() => expiryDate = picked);
    }
  }

  Future<void> _listProduct() async {
    if (!_formKey.currentState!.validate()) return;

    final restaurantId = int.tryParse(restaurantIdController.text.trim());
    final originalPrice = double.tryParse(originalPriceController.text.trim());
    final discountedPrice = double.tryParse(discountedPriceController.text.trim());

    if (restaurantId == null || restaurantId <= 0) {
      _showMessage('Lütfen geçerli bir Restoran ID girin.');
      return;
    }
    if (originalPrice == null || originalPrice <= 0) {
      _showMessage('Orijinal fiyat boş olamaz.');
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
        _showMessage('Ürün başarıyla yayınlandı!');
        Navigator.pop(context, true);
      }
    } catch (e) {
      _showMessage(e.toString().replaceAll('ApiException: ', ''));
    } finally {
      if (mounted) setState(() => isSubmitting = false);
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  InputDecoration _inputDecoration({required String hint, IconData? icon}) {
    return InputDecoration(
      hintText: hint,
      prefixIcon: icon != null ? Icon(icon, color: textSoft) : null,
      filled: true,
      fillColor: inputBg,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: BorderSide(color: Colors.grey.shade200),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: BorderSide(color: Colors.grey.shade200),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: const BorderSide(color: primary, width: 1.4),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
            children: [
              _buildHeader(),
              const SizedBox(height: 22),
              _buildProgress(),
              const SizedBox(height: 28),
              _buildVisualSection(),
              const SizedBox(height: 28),
              _buildProductDetails(),
              const SizedBox(height: 28),
              _buildStockAndExpiry(),
              const SizedBox(height: 28),
              _buildActionButtons(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back, color: primary),
        ),
        Expanded(
          child: Text(
            'Yeni Ürün Ekle',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: textDark,
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
          decoration: BoxDecoration(
            color: primary.withValues(alpha: 0.10), // Güncellendi: withValues
            borderRadius: BorderRadius.circular(999),
          ),
          child: Text(
            'Satıcı',
            style: GoogleFonts.manrope(
              color: primary,
              fontSize: 12,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildProgress() {
    return Row(
      children: [
        Expanded(child: _progressLine(true)),
        const SizedBox(width: 6),
        Expanded(child: _progressLine(true)),
        const SizedBox(width: 6),
        Expanded(child: _progressLine(true)),
      ],
    );
  }

  Widget _progressLine(bool active) {
    return Container(
      height: 5,
      decoration: BoxDecoration(
        color: active ? primary : Colors.grey.shade300,
        borderRadius: BorderRadius.circular(999),
      ),
    );
  }

  Widget _buildVisualSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Ürün Görseli',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: InkWell(
                onTap: _pickAndUploadImage,
                child: _uploadedImageUrl == null 
                  ? _photoBox(icon: Icons.add_a_photo_outlined, text: 'Fotoğraf Ekle')
                  : ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: Image.network(
                        '${ApiClient.baseUrl}$_uploadedImageUrl', // Güncellendi: ApiClient.baseUrl
                        height: 105,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => 
                          _photoBox(icon: Icons.error_outline, text: 'Hata oluştu'),
                      ),
                    ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(child: _photoBox(icon: Icons.image_outlined, text: 'Boş')),
            const SizedBox(width: 12),
            Expanded(child: _photoBox(icon: Icons.image_outlined, text: 'Boş')),
          ],
        ),
      ],
    );
  }

  Widget _photoBox({required IconData icon, required String text}) {
    return Container(
      height: 105,
      decoration: BoxDecoration(
        color: surfaceLow,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: textSoft, size: 28),
          const SizedBox(height: 6),
          Text(
            text,
            style: GoogleFonts.manrope(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: textSoft,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductDetails() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionTitle('Ürün Bilgileri'),
        const SizedBox(height: 16),
        _label('Restaurant ID'),
        TextFormField(
          controller: restaurantIdController,
          keyboardType: TextInputType.number,
          decoration: _inputDecoration(hint: 'Orn: 1', icon: Icons.storefront),
          validator: (value) => (value == null || value.trim().isEmpty) ? 'Zorunlu' : null,
        ),
        const SizedBox(height: 16),
        _label('Ürün Adı'),
        TextFormField(
          controller: nameController,
          decoration: _inputDecoration(hint: 'Örn: Organik Sebze Kutusu', icon: Icons.shopping_bag_outlined),
          validator: (value) => (value == null || value.trim().isEmpty) ? 'Zorunlu' : null,
        ),
        const SizedBox(height: 16),
        _label('Açıklama'),
        TextFormField(
          controller: descriptionController,
          maxLines: 3,
          decoration: _inputDecoration(hint: 'Ürün detaylarını yazın.', icon: Icons.description_outlined),
          validator: (value) => (value == null || value.trim().isEmpty) ? 'Zorunlu' : null,
        ),
        const SizedBox(height: 16),
        _label('Kategori'),
        DropdownButtonFormField<String>(
          initialValue: selectedCategory, // Güncellendi: initialValue
          decoration: _inputDecoration(hint: 'Kategori seçin', icon: Icons.category_outlined),
          items: ['Vegetables', 'Bakery', 'Dairy', 'Fruit', 'Meal']
              .map((c) => DropdownMenuItem(value: c, child: Text(c)))
              .toList(),
          onChanged: (value) => setState(() => selectedCategory = value!),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _label('Orijinal Fiyat'),
                  TextFormField(
                    controller: originalPriceController,
                    keyboardType: TextInputType.number,
                    decoration: _inputDecoration(hint: '100', icon: Icons.attach_money),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _label('İndirimli Fiyat'),
                  TextFormField(
                    controller: discountedPriceController,
                    keyboardType: TextInputType.number,
                    decoration: _inputDecoration(hint: '60', icon: Icons.local_offer_outlined),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStockAndExpiry() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionTitle('Stok ve Son Kullanma'),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(color: surfaceLow, borderRadius: BorderRadius.circular(24)),
          child: Column(
            children: [
              Row(
                children: [
                  Text('Stok', style: GoogleFonts.plusJakartaSans(fontSize: 17, fontWeight: FontWeight.w800, color: textDark)),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(color: primary, borderRadius: BorderRadius.circular(999)),
                    child: Text('${stockValue.round()} adet', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800)),
                  ),
                ],
              ),
              Slider(
                value: stockValue,
                min: 1, max: 50,
                activeColor: primary,
                onChanged: (value) => setState(() => stockValue = value),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        ListTile(
          tileColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          leading: const Icon(Icons.calendar_today, color: primary),
          title: const Text('Son Kullanma Tarihi'),
          subtitle: Text('${expiryDate.day}.${expiryDate.month}.${expiryDate.year}'),
          trailing: const Icon(Icons.chevron_right),
          onTap: _pickExpiryDate,
        ),
        const SizedBox(height: 12),
        SwitchListTile(
          value: isActive,
          activeThumbColor: primary, // Güncellendi: activeThumbColor
          tileColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text('Ürün Aktif Olsun'),
          onChanged: (value) => setState(() => isActive = value),
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: SizedBox(
            height: 54,
            child: OutlinedButton(
              onPressed: isSubmitting ? null : () => Navigator.pop(context),
              child: const Text('Vazgeç'),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          flex: 2,
          child: SizedBox(
            height: 54,
            child: ElevatedButton.icon(
              onPressed: isSubmitting ? null : _listProduct,
              icon: isSubmitting
                  ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : const Icon(Icons.rocket_launch),
              label: Text(isSubmitting ? 'Ekleniyor...' : 'Ürünü Yayınla'),
              style: ElevatedButton.styleFrom(backgroundColor: primary, foregroundColor: Colors.white),
            ),
          ),
        ),
      ],
    );
  }

  Widget _sectionTitle(String text) {
    return Text(text, style: GoogleFonts.plusJakartaSans(fontSize: 20, fontWeight: FontWeight.w800, color: textDark));
  }

  Widget _label(String text) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(text, style: GoogleFonts.manrope(fontSize: 13, fontWeight: FontWeight.w800, color: textDark)),
    );
  }
}