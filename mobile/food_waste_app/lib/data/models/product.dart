class Product {
  final int id;
  final int restaurantId;
  final String restaurantName;
  final String? imageUrl;
  final String category;
  final String name;
  final String description;
  final double originalPrice;
  final double discountedPrice;
  final double discountPercent;
  final int stock;
  final DateTime? expiryDate;

  const Product({
    required this.id,
    required this.restaurantId,
    required this.restaurantName,
    this.imageUrl,
    required this.category,
    required this.name,
    required this.description,
    required this.originalPrice,
    required this.discountedPrice,
    required this.discountPercent,
    required this.stock,
    this.expiryDate,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] ?? 0,
      restaurantId: json['restaurantId'] ?? 0,
      restaurantName: json['restaurantName'] ?? '',
      imageUrl: (json['imageUrl'] ?? json['primaryImage'])?.toString(),
      category: json['category'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      originalPrice: (json['originalPrice'] ?? 0).toDouble(),
      discountedPrice: (json['discountedPrice'] ?? 0).toDouble(),
      discountPercent: (json['discountPercent'] ?? 0).toDouble(),
      stock: json['stock'] ?? 0,
      expiryDate: json['expiryDate'] != null
          ? DateTime.tryParse(json['expiryDate'] as String)
          : null,
    );
  }
}
