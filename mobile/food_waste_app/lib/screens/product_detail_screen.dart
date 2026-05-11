import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:food_waste_app/core/app_colors.dart';
import '../data/models/product.dart';
import '../data/services/api_client.dart';

class ProductDetailScreen extends StatefulWidget {
  final Product product;
  final ApiClient apiClient;

  const ProductDetailScreen({
    super.key,
    required this.product,
    required this.apiClient,
  });

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  late int _quantity;
  bool _isLoading = false;
  String _error = '';

  @override
  void initState() {
    super.initState();
    _quantity = 1;
  }

  Future<void> _reserve() async {
    if (_quantity <= 0 || _quantity > widget.product.stock) {
      setState(() => _error = 'Geçersiz miktar seçimi.');
      return;
    }

    setState(() {
      _isLoading = true;
      _error = '';
    });

    try {
      await widget.apiClient.reserveProduct(
        productId: widget.product.id,
        quantity: _quantity,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Ürün başarıyla rezerve edildi.'),
          backgroundColor: AppColors.primaryGreen,
        ),
      );

      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = e.toString().replaceAll('ApiException: ', ''));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  double get _totalPrice => widget.product.discountedPrice * _quantity;

  String? _absoluteImageUrl(String? imageUrl) {
    final value = imageUrl?.trim();
    if (value == null || value.isEmpty) {
      return null;
    }

    if (value.startsWith('http://') || value.startsWith('https://')) {
      return value;
    }

    if (value.startsWith('/')) {
      return '${ApiClient.baseUrl}$value';
    }

    return '${ApiClient.baseUrl}/$value';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          _appBar(),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 22, 20, 120),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _titleBlock(),
                  const SizedBox(height: 18),
                  _chipsRow(),
                  const SizedBox(height: 22),
                  _priceCard(),
                  const SizedBox(height: 18),
                  _descriptionCard(),
                  const SizedBox(height: 18),
                  if (widget.product.expiryDate != null) _expiryCard(),
                  if (widget.product.expiryDate != null)
                    const SizedBox(height: 18),
                  if (_error.isNotEmpty) _errorCard(),
                  if (_error.isNotEmpty) const SizedBox(height: 18),
                  _quantityCard(),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: _bottomReserveBar(),
    );
  }

  Widget _appBar() {
    return SliverAppBar(
      expandedHeight: 270,
      pinned: true,
      backgroundColor: AppColors.primaryGreen,
      leading: Padding(
        padding: const EdgeInsets.all(8),
        child: CircleAvatar(
          backgroundColor: Colors.white.withValues(alpha: 0.92),
          child: IconButton(
            icon: const Icon(Icons.arrow_back, color: AppColors.primaryGreen),
            onPressed: () => Navigator.pop(context),
          ),
        ),
      ),
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: const BoxDecoration(gradient: AppColors.splashGradient),
          child: Stack(
            children: [
              Positioned(
                right: -30,
                bottom: -40,
                child: Icon(
                  Icons.eco,
                  size: 180,
                  color: Colors.white.withValues(alpha: 0.08),
                ),
              ),
              Center(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(38),
                  child: Container(
                    width: 132,
                    height: 132,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.13),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.12),
                      ),
                    ),
                    child: _absoluteImageUrl(widget.product.imageUrl) == null
                        ? const Icon(
                            Icons.fastfood_rounded,
                            size: 74,
                            color: Colors.white,
                          )
                        : Image.network(
                            _absoluteImageUrl(widget.product.imageUrl)!,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => const Icon(
                              Icons.broken_image_outlined,
                              size: 64,
                              color: Colors.white,
                            ),
                          ),
                  ),
                ),
              ),
              Positioned(
                left: 20,
                right: 20,
                bottom: 24,
                child: _discountBadge(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _discountBadge() {
    return Align(
      alignment: Alignment.bottomLeft,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 7),
        decoration: BoxDecoration(
          color: AppColors.secondaryOrange,
          borderRadius: BorderRadius.circular(999),
        ),
        child: Text(
          '-%${widget.product.discountPercent.toStringAsFixed(0)} indirim',
          style: GoogleFonts.manrope(
            color: Colors.white,
            fontWeight: FontWeight.w900,
            fontSize: 12,
          ),
        ),
      ),
    );
  }

  Widget _titleBlock() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.product.name,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 27,
            fontWeight: FontWeight.w900,
            color: AppColors.textDark,
          ),
        ),
        const SizedBox(height: 7),
        Text(
          widget.product.restaurantName,
          style: GoogleFonts.manrope(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: AppColors.textSoft,
          ),
        ),
      ],
    );
  }

  Widget _chipsRow() {
    return Row(
      children: [
        _chip(Icons.category_outlined, widget.product.category),
        const Spacer(),
        _chip(
          Icons.inventory_2_outlined,
          'Stok: ${widget.product.stock}',
          danger: widget.product.stock <= 0,
        ),
      ],
    );
  }

  Widget _chip(IconData icon, String text, {bool danger = false}) {
    final color = danger ? AppColors.error : AppColors.primaryGreen;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.16)),
      ),
      child: Row(
        children: [
          Icon(icon, size: 15, color: color),
          const SizedBox(width: 6),
          Text(
            text,
            style: GoogleFonts.manrope(
              color: color,
              fontWeight: FontWeight.w900,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _priceCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: _cardDecoration(),
      child: Column(
        children: [
          _priceRow(
            'Orijinal Fiyat',
            '${widget.product.originalPrice.toStringAsFixed(2)} ₺',
            muted: true,
            lineThrough: true,
          ),
          const Divider(height: 24),
          _priceRow(
            'İndirimli Fiyat',
            '${widget.product.discountedPrice.toStringAsFixed(2)} ₺',
            highlight: true,
          ),
          const Divider(height: 24),
          _priceRow(
            'Toplam',
            '${_totalPrice.toStringAsFixed(2)} ₺',
            highlight: true,
          ),
        ],
      ),
    );
  }

  Widget _priceRow(
    String label,
    String value, {
    bool muted = false,
    bool lineThrough = false,
    bool highlight = false,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.manrope(
            color: AppColors.textSoft,
            fontWeight: FontWeight.w700,
            fontSize: 13,
          ),
        ),
        Text(
          value,
          style: GoogleFonts.plusJakartaSans(
            color: highlight ? AppColors.primaryGreen : AppColors.textSoft,
            fontSize: highlight ? 19 : 13,
            fontWeight: highlight ? FontWeight.w900 : FontWeight.w700,
            decoration: lineThrough ? TextDecoration.lineThrough : null,
          ),
        ),
      ],
    );
  }

  Widget _descriptionCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _cardTitle(Icons.notes_rounded, 'Açıklama'),
          const SizedBox(height: 12),
          Text(
            widget.product.description,
            style: GoogleFonts.manrope(
              color: AppColors.textSoft,
              fontSize: 13,
              height: 1.55,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _expiryCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.secondaryOrange.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: AppColors.secondaryOrange.withValues(alpha: 0.20),
        ),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.event_available_rounded,
            color: AppColors.secondaryOrange,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Son kullanma: ${widget.product.expiryDate}',
              style: GoogleFonts.manrope(
                color: AppColors.secondaryOrange,
                fontWeight: FontWeight.w800,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _errorCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.error.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.error.withValues(alpha: 0.18)),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline_rounded, color: AppColors.error),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              _error,
              style: GoogleFonts.manrope(
                color: AppColors.error,
                fontWeight: FontWeight.w700,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _quantityCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _cardTitle(Icons.add_shopping_cart_rounded, 'Miktar Seç'),
          const SizedBox(height: 16),
          Container(
            height: 58,
            decoration: BoxDecoration(
              color: AppColors.surfaceContainer.withValues(alpha: 0.55),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _quantityButton(
                  icon: Icons.remove_rounded,
                  enabled: _quantity > 1,
                  onTap: () => setState(() => _quantity--),
                ),
                Text(
                  _quantity.toString(),
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    color: AppColors.textDark,
                  ),
                ),
                _quantityButton(
                  icon: Icons.add_rounded,
                  enabled: _quantity < widget.product.stock,
                  onTap: () => setState(() => _quantity++),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _quantityButton({
    required IconData icon,
    required bool enabled,
    required VoidCallback onTap,
  }) {
    return IconButton(
      onPressed: enabled ? onTap : null,
      icon: Icon(icon),
      color: AppColors.primaryGreen,
      disabledColor: AppColors.textSoft.withValues(alpha: 0.35),
    );
  }

  Widget _bottomReserveBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 24,
            offset: const Offset(0, -8),
          ),
        ],
      ),
      child: SafeArea(
        child: SizedBox(
          height: 58,
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: widget.product.stock > 0
                  ? AppColors.editorialGradient
                  : const LinearGradient(colors: [Colors.grey, Colors.grey]),
              borderRadius: BorderRadius.circular(18),
            ),
            child: ElevatedButton(
              onPressed: widget.product.stock > 0 && !_isLoading
                  ? _reserve
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                disabledBackgroundColor: Colors.transparent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
              ),
              child: _isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : Text(
                      widget.product.stock > 0
                          ? 'Rezerve Et'
                          : 'Stok Bulunamadı',
                      style: GoogleFonts.plusJakartaSans(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                        fontSize: 15,
                      ),
                    ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _cardTitle(IconData icon, String title) {
    return Row(
      children: [
        Icon(icon, color: AppColors.primaryGreen, size: 20),
        const SizedBox(width: 8),
        Text(
          title,
          style: GoogleFonts.plusJakartaSans(
            color: AppColors.textDark,
            fontSize: 16,
            fontWeight: FontWeight.w900,
          ),
        ),
      ],
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
}
