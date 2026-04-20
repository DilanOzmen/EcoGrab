import 'package:flutter/material.dart';
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

  @override
  void dispose() {
    titleController.dispose();
    descriptionController.dispose();
    priceController.dispose();
    super.dispose();
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
              ),
            ],
          ),
        ),
      ),
    );
  }
}