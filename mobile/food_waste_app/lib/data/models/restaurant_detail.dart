class RestaurantDetail {
  final int id;
  final String name;
  final String address;
  final String city;
  final String phone;
  final double latitude;
  final double longitude;

  RestaurantDetail({
    required this.id,
    required this.name,
    required this.address,
    required this.city,
    required this.phone,
    required this.latitude,
    required this.longitude,
  });

  factory RestaurantDetail.fromJson(Map<String, dynamic> json) {
    return RestaurantDetail(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      address: json['address'] ?? '',
      city: json['city'] ?? '',
      phone: json['phone'] ?? '',
      latitude: (json['latitude'] ?? 0.0).toDouble(),
      longitude: (json['longitude'] ?? 0.0).toDouble(),
    );
  }
}
