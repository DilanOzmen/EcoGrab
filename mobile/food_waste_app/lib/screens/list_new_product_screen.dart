import 'package:flutter/material.dart';
import 'package:food_waste_app/data/services/api_client.dart';
import 'package:food_waste_app/widgets/product_listing_header.dart';
import 'package:food_waste_app/widgets/product_details_form.dart';
import 'package:food_waste_app/widgets/stock_collection_section.dart';

class ListNewProductScreen extends StatefulWidget {
  const ListNewProductScreen({super.key});

  @override
  State<ListNewProductScreen> createState() => _ListNewProductScreenState();
}

class _ListNewProductScreenState extends State<ListNewProductScreen> {
  final titleController = TextEditingController(
    text: 'Organic Seasonal Veggie Box',
  );

  final descriptionController = TextEditingController(
    text:
        "A mix of today's harvest. Includes carrots, kale, and tomatoes. Best for immediate consumption to reduce waste!",
  );

  final priceController = TextEditingController(text: '12.50');

  String selectedCategory = 'Vegetables';
  double stockValue = 14;
  TimeOfDay fromTime = const TimeOfDay(hour: 17, minute: 0);
  TimeOfDay untilTime = const TimeOfDay(hour: 20, minute: 0);
  bool _isSubmitting = false;
  final ApiClient _apiClient = ApiClient();

  @override
  void dispose() {
    titleController.dispose();
    descriptionController.dispose();
    priceController.dispose();
    super.dispose();
  }

  String _formatTime(TimeOfDay time) {
    final h = time.hour.toString().padLeft(2, '0');
    final m = time.minute.toString().padLeft(2, '0');
    return '$h:$m:00';
  }

  Future<void> _saveDraft() async {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Taslak kaydedildi (yerel).')),
    );
  }

  Future<void> _listProduct() async {
    final name = titleController.text.trim();
    final description = descriptionController.text.trim();
    final priceText = priceController.text.trim();

    if (name.isEmpty || description.isEmpty || priceText.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lutfen tum alanlari doldurun.')),
      );
      return;
    }

    final price = double.tryParse(priceText);
    if (price == null || price <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Gecerli bir fiyat girin.')),
      );
      return;
    }

    setState(() => _isSubmitting = true);
    try {
      await _apiClient.createProduct(
        name: name,
        description: description,
        originalPrice: price,
        discountedPrice: price * 0.6,
        category: selectedCategory,
        stock: stockValue.round(),
        collectionFrom: _formatTime(fromTime),
        collectionUntil: _formatTime(untilTime),
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Urun basariyla listelendi!')),
      );
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  Future<void> pickTime({required bool isFrom}) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: isFrom ? fromTime : untilTime,
    );

    if (picked != null) {
      setState(() {
        if (isFrom) {
          fromTime = picked;
        } else {
          untilTime = picked;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    const background = Color(0xFFF8FAF8);

    return Scaffold(
      backgroundColor: background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const ProductListingHeader(),
              const SizedBox(height: 24),
              ProductDetailsForm(
                titleController: titleController,
                descriptionController: descriptionController,
                priceController: priceController,
                selectedCategory: selectedCategory,
                onCategoryChanged: (value) {
                  setState(() {
                    selectedCategory = value;
                  });
                },
              ),
              const SizedBox(height: 24),
              StockCollectionSection(
                stockValue: stockValue,
                fromTime: fromTime,
                untilTime: untilTime,
                onStockChanged: (value) {
                  setState(() {
                    stockValue = value;
                  });
                },
                onPickFrom: () => pickTime(isFrom: true),
                onPickUntil: () => pickTime(isFrom: false),
                onSaveDraft: _saveDraft,
                onListProduct: _listProduct,
                isSubmitting: _isSubmitting,
              ),
            ],
          ),
        ),
      ),
    );
  }
}