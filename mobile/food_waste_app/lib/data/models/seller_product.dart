class SellerProduct {
  final int id;
  final int restaurantId;
  final String restaurantName;
  final String category;
  final String name;
  final String description;
  final double originalPrice;
  final double discountedPrice;
  final int stock;
  final DateTime expiryDate;
  final bool isActive;

  const SellerProduct({
    required this.id,
    required this.restaurantId,
    required this.restaurantName,
    required this.category,
    required this.name,
    required this.description,
    required this.originalPrice,
    required this.discountedPrice,
    required this.stock,
    required this.expiryDate,
    required this.isActive,
  });

  factory SellerProduct.fromJson(Map<String, dynamic> json) {
    return SellerProduct(
      id: json['id'] ?? 0,
      restaurantId: json['restaurantId'] ?? 0,
      restaurantName: json['restaurantName']?.toString() ?? '',
      category: json['category']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      originalPrice: (json['originalPrice'] ?? 0).toDouble(),
      discountedPrice: (json['discountedPrice'] ?? 0).toDouble(),
      stock: json['stock'] ?? 0,
      expiryDate:
          DateTime.tryParse(json['expiryDate']?.toString() ?? '') ??
          DateTime.now(),
      isActive: json['isActive'] == true,
    );
  }
}
