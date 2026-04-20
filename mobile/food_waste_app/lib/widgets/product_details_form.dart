import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ProductDetailsForm extends StatelessWidget {
  final TextEditingController titleController;
  final TextEditingController descriptionController;
  final TextEditingController priceController;
  final String selectedCategory;
  final ValueChanged<String> onCategoryChanged;

  const ProductDetailsForm({
    super.key,
    required this.titleController,
    required this.descriptionController,
    required this.priceController,
    required this.selectedCategory,
    required this.onCategoryChanged,
  });

  InputDecoration _inputDecoration() {
    const outlineVariant = Color(0xFFBBCBBB);
    const surfaceContainerLowest = Color(0xFFFFFFFF);
    const primary = Color(0xFF006D37);

    return InputDecoration(
      filled: true,
      fillColor: surfaceContainerLowest,
      contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
        borderSide: BorderSide(color: outlineVariant.withValues(alpha: 0.25)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
        borderSide: BorderSide(color: outlineVariant.withValues(alpha: 0.25)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
        borderSide: const BorderSide(color: primary, width: 1.4),
      ),
    );
  }

  Widget _label(String text) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        text,
        style: GoogleFonts.manrope(
          fontSize: 13,
          fontWeight: FontWeight.w700,
          color: const Color(0xFF3D4A3E),
        ),
      ),
    );
  }

  Widget _photoBox({
    String? imageUrl,
    bool isAdd = false,
  }) {
    const surfaceContainerLow = Color(0xFFF3F4F4);
    const outlineVariant = Color(0xFFBBCBBB);

    if (imageUrl != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: Stack(
          children: [
            Positioned.fill(
              child: Image.network(imageUrl, fit: BoxFit.cover),
            ),
            Positioned(
              top: 8,
              right: 8,
              child: Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.35),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.close, color: Colors.white, size: 16),
              ),
            ),
          ],
        ),
      );
    }

    if (isAdd) {
      return Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: outlineVariant.withValues(alpha: 0.35)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add_a_photo_outlined,
                color: Colors.grey.shade500, size: 30),
            const SizedBox(height: 6),
            Text(
              'Add Photo',
              style: GoogleFonts.manrope(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: surfaceContainerLow.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: outlineVariant.withValues(alpha: 0.15)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const onSurface = Color(0xFF191C1C);
    const primary = Color(0xFF006D37);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Product Visuals',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: onSurface,
              ),
            ),
            Text(
              'Done',
              style: GoogleFonts.manrope(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: primary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 100,
          child: Row(
            children: [
              Expanded(
                child: _photoBox(
                  imageUrl:
                      'https://lh3.googleusercontent.com/aida-public/AB6AXuCNhYRiOoaYasaiKGybechJeZSm--j0DyJBLBAdEtep1nKeb5JKZ581n82IfOdrajgwKpXMkZUSajs6z3Nie7Vo71TtmjD_DJXozz7HxE6yALzCfymITlOBC0_IOYLg4CUZ7xb7JNCgd5yAXf3QPSLWAqCEA3hOJyDM9U011LIu6_QLewUJXew4zftC_yUWForSJplLoZlMJclrt1hu0Wz58UnHV4-i7lG67RrtDX_Z9s8i9M0bEFcB6QBXZUyTIZ9TUdjRvRbFFsPa',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(child: _photoBox(isAdd: true)),
              const SizedBox(width: 12),
              Expanded(child: _photoBox()),
            ],
          ),
        ),
        const SizedBox(height: 28),
        Text(
          'Product Details',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: onSurface,
          ),
        ),
        const SizedBox(height: 18),
        _label('Title'),
        TextField(
          controller: titleController,
          decoration: _inputDecoration(),
        ),
        const SizedBox(height: 16),
        _label('Description'),
        TextField(
          controller: descriptionController,
          maxLines: 4,
          decoration: _inputDecoration(),
        ),
        const SizedBox(height: 16),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 2,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _label('Category'),
                  DropdownButtonFormField<String>(
                    initialValue: selectedCategory,
                    decoration: _inputDecoration(),
                    items: const [
                      DropdownMenuItem(
                        value: 'Vegetables',
                        child: Text('Vegetables'),
                      ),
                      DropdownMenuItem(
                        value: 'Bakery',
                        child: Text('Bakery'),
                      ),
                      DropdownMenuItem(
                        value: 'Dairy',
                        child: Text('Dairy'),
                      ),
                    ],
                    onChanged: (value) {
                      if (value != null) onCategoryChanged(value);
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _label('Price (\$)'),
                  TextField(
                    controller: priceController,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    decoration: _inputDecoration(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}