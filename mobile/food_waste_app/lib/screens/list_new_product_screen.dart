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
  // Renk Paleti
  static const primary = Color(0xFF0F5238);
  static const background = Color(0xFFF8FAF8);
  static const surfaceLow = Color(0xFFF1F3F1);
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

  Future<void> _listProduct() async {
    if (!_formKey.currentState!.validate()) return;
    
    final restaurantId = int.tryParse(restaurantIdController.text.trim());
    final originalPrice = double.tryParse(originalPriceController.text.trim());
    final discountedPrice = double.tryParse(discountedPriceController.text.trim());

    if (restaurantId == null || restaurantId <= 0) {
      _showMessage('Lütfen geçerli bir Restoran ID girin.');
      return;
    }

    setState(() => isSubmitting = true);
    try {
      final newProductId = await _apiClient.createProduct(
        restaurantId: restaurantId,
        name: nameController.text.trim(),
        description: descriptionController.text.trim(),
        originalPrice: originalPrice!,
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        backgroundColor: background,
        elevation: 0,
        centerTitle: true,
        title: Text('Yeni Ürün Listele', style: GoogleFonts.plusJakartaSans(color: textDark, fontWeight: FontWeight.bold)),
        leading: IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close, color: textDark)),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 40),
          children: [
            // 1. MODERN FOTOĞRAF YÜKLEME ALANI
            _buildPhotoPickerArea(),
            const SizedBox(height: 32),

            // 2. ÜRÜN BİLGİLERİ SEKSİYONU
            _sectionTitle('Ürün Detayları'),
            _buildInputField(
              label: 'Restaurant ID',
              controller: restaurantIdController,
              hint: 'Örn: 1',
              icon: Icons.storefront_rounded,
              keyboardType: TextInputType.number,
            ),
            _buildInputField(
              label: 'Ürün Adı',
              controller: nameController,
              hint: 'Örn: Organik Domates Sepeti',
              icon: Icons.shopping_bag_outlined,
            ),
            _buildInputField(
              label: 'Açıklama',
              controller: descriptionController,
              hint: 'Ürünün içeriğini kısaca anlatın...',
              icon: Icons.notes_rounded,
              maxLines: 3,
            ),

            // 3. KATEGORİ SEÇİMİ
            _buildLabel('Kategori'),
            DropdownButtonFormField<String>(
              initialValue: selectedCategory,
              icon: const Icon(Icons.keyboard_arrow_down_rounded, color: primary),
              decoration: _inputDecoration(icon: Icons.category_outlined),
              items: ['Vegetables', 'Bakery', 'Dairy', 'Fruit', 'Meal']
                  .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                  .toList(),
              onChanged: (v) => setState(() => selectedCategory = v!),
            ),
            const SizedBox(height: 24),

            // 4. FİYATLAR (YAN YANA)
            Row(
              children: [
                Expanded(
                  child: _buildInputField(
                    label: 'Orijinal Fiyat',
                    controller: originalPriceController,
                    hint: '100',
                    icon: Icons.sell_outlined,
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildInputField(
                    label: 'İndirimli Fiyat',
                    controller: discountedPriceController,
                    hint: '60',
                    icon: Icons.local_offer_rounded,
                    keyboardType: TextInputType.number,
                  ),
                ),
              ],
            ),

            // 5. STOK VE TARİH
            const SizedBox(height: 8),
            _buildStockSlider(),
            const SizedBox(height: 20),
            _buildDatePicker(),
            
            const SizedBox(height: 40),
            _buildSubmitButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildPhotoPickerArea() {
    return GestureDetector(
      onTap: _pickAndUploadImage,
      child: Container(
        width: double.infinity,
        height: 180,
        decoration: BoxDecoration(
          color: const Color(0xFFD8F3DC).withValues(alpha: 0.4),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: primary.withValues(alpha: 0.2), width: 2, style: BorderStyle.solid),
          image: _uploadedImageUrl != null 
            ? DecorationImage(image: NetworkImage('${ApiClient.baseUrl}$_uploadedImageUrl'), fit: BoxFit.cover)
            : null,
        ),
        child: _uploadedImageUrl == null ? Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.add_a_photo_rounded, size: 48, color: primary),
            const SizedBox(height: 12),
            Text("Ürün Fotoğrafı Ekle", style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w800, color: primary, fontSize: 16)),
            const Text("Müşteriler görsellere güvenir", style: TextStyle(color: textSoft, fontSize: 12)),
          ],
        ) : Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            color: Colors.black.withValues(alpha: 0.3),
          ),
          child: const Icon(Icons.edit, color: Colors.white, size: 30),
        ),
      ),
    );
  }

  Widget _buildInputField({
    required String label,
    required TextEditingController controller,
    required String hint,
    IconData? icon,
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel(label),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          keyboardType: keyboardType,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
          decoration: _inputDecoration(hint: hint, icon: icon),
          validator: (v) => (v == null || v.isEmpty) ? 'Bu alan boş bırakılamaz' : null,
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  InputDecoration _inputDecoration({String? hint, IconData? icon}) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: textSoft, fontSize: 14, fontWeight: FontWeight.normal),
      prefixIcon: icon != null ? Icon(icon, color: primary, size: 22) : null,
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.all(18),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(18), borderSide: BorderSide(color: Colors.grey.shade200)),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(18), borderSide: BorderSide(color: Colors.grey.shade200)),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(18), borderSide: const BorderSide(color: primary, width: 1.5)),
    );
  }

  Widget _buildStockSlider() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white, 
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.grey.shade100)
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Stok Miktarı", style: TextStyle(fontWeight: FontWeight.bold)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(color: primary, borderRadius: BorderRadius.circular(10)),
                child: Text("${stockValue.round()} adet", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
              ),
            ],
          ),
          Slider(
            value: stockValue,
            min: 1, max: 50,
            activeColor: primary,
            inactiveColor: surfaceLow,
            onChanged: (v) => setState(() => stockValue = v),
          ),
        ],
      ),
    );
  }

  Widget _buildDatePicker() {
    return ListTile(
      tileColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18), side: BorderSide(color: Colors.grey.shade100)),
      leading: const Icon(Icons.event_available, color: primary),
      title: const Text("Son Kullanma Tarihi", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
      subtitle: Text("${expiryDate.day}.${expiryDate.month}.${expiryDate.year}", style: const TextStyle(color: textSoft)),
      trailing: const Icon(Icons.edit_calendar_rounded, size: 20, color: primary),
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: expiryDate,
          firstDate: DateTime.now(),
          lastDate: DateTime.now().add(const Duration(days: 365)),
        );
        if (picked != null) setState(() => expiryDate = picked);
      },
    );
  }

  Widget _buildSubmitButton() {
    return Container(
      width: double.infinity,
      height: 60,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(color: primary.withValues(alpha: 0.2), blurRadius: 12, offset: const Offset(0, 6))
        ],
      ),
      child: ElevatedButton(
        onPressed: isSubmitting ? null : _listProduct,
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          elevation: 0,
        ),
        child: isSubmitting 
          ? const CircularProgressIndicator(color: Colors.white)
          : const Text("ÜRÜNÜ YAYINLA", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16, letterSpacing: 1.1)),
      ),
    );
  }

  Widget _buildLabel(String text) => Padding(
    padding: const EdgeInsets.only(left: 4, bottom: 8),
    child: Text(text, style: GoogleFonts.manrope(fontSize: 13, fontWeight: FontWeight.w800, color: primary)),
  );

  Widget _sectionTitle(String text) => Padding(
    padding: const EdgeInsets.only(bottom: 16),
    child: Text(text, style: GoogleFonts.plusJakartaSans(fontSize: 18, fontWeight: FontWeight.w800, color: textDark)),
  );
}