class Restaurant {
  final int id;
  final String name;
  final String address;
  final String city;
  final double latitude;
  final double longitude;
  final double? distanceKm;

  const Restaurant({
    required this.id,
    required this.name,
    required this.address,
    required this.city,
    required this.latitude,
    required this.longitude,
    this.distanceKm,
  });

  factory Restaurant.fromJson(Map<String, dynamic> json) {
    return Restaurant(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      address: json['address'] ?? '',
      city: json['city'] ?? '',
      latitude: (json['latitude'] ?? 0).toDouble(),
      longitude: (json['longitude'] ?? 0).toDouble(),
      distanceKm: json['distanceKm'] != null
          ? (json['distanceKm']).toDouble()
          : null,
    );
  }
}



