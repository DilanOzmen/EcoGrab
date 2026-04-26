class SellerOrderItem {
  final int productId;
  final String productName;
  final int quantity;
  final double unitPrice;

  const SellerOrderItem({
    required this.productId,
    required this.productName,
    required this.quantity,
    required this.unitPrice,
  });

  factory SellerOrderItem.fromJson(Map<String, dynamic> json) {
    return SellerOrderItem(
      productId: json['productId'] ?? 0,
      productName: json['productName']?.toString() ?? '',
      quantity: json['quantity'] ?? 0,
      unitPrice: (json['unitPrice'] ?? 0).toDouble(),
    );
  }
}

class SellerOrder {
  final int orderId;
  final int customerId;
  final String customerName;
  final DateTime createdAt;
  final String status;
  final double totalAmount;
  final List<SellerOrderItem> items;

  const SellerOrder({
    required this.orderId,
    required this.customerId,
    required this.customerName,
    required this.createdAt,
    required this.status,
    required this.totalAmount,
    required this.items,
  });

  factory SellerOrder.fromJson(Map<String, dynamic> json) {
    final itemsRaw = json['items'] as List<dynamic>? ?? [];
    return SellerOrder(
      orderId: json['orderId'] ?? 0,
      customerId: json['customerId'] ?? 0,
      customerName: json['customerName']?.toString() ?? '',
      createdAt:
          DateTime.tryParse(json['createdAt']?.toString() ?? '') ??
          DateTime.now(),
      status: json['status']?.toString() ?? '',
      totalAmount: (json['totalAmount'] ?? 0).toDouble(),
      items: itemsRaw
          .map((e) => SellerOrderItem.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}
