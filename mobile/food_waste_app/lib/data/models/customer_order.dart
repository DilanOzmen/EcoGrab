class CustomerOrderItem {
  final int productId;
  final String productName;
  final int quantity;
  final double unitPrice;

  const CustomerOrderItem({
    required this.productId,
    required this.productName,
    required this.quantity,
    required this.unitPrice,
  });

  factory CustomerOrderItem.fromJson(Map<String, dynamic> json) {
    return CustomerOrderItem(
      productId: json['productId'] ?? 0,
      productName: json['productName'] ?? '',
      quantity: json['quantity'] ?? 0,
      unitPrice: (json['unitPrice'] ?? 0).toDouble(),
    );
  }
}

class CustomerOrder {
  final int id;
  final DateTime createdAt;
  final String status;
  final double totalAmount;
  final List<CustomerOrderItem> items;

  const CustomerOrder({
    required this.id,
    required this.createdAt,
    required this.status,
    required this.totalAmount,
    required this.items,
  });

  factory CustomerOrder.fromJson(Map<String, dynamic> json) {
    final itemsRaw = json['items'] as List<dynamic>? ?? [];
    return CustomerOrder(
      id: json['id'] ?? 0,
      createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
      status: json['status'] ?? '',
      totalAmount: (json['totalAmount'] ?? 0).toDouble(),
      items: itemsRaw
          .map((e) => CustomerOrderItem.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}
