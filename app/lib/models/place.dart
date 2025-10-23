class Place {
  final String id;
  final String name;
  final String description;
  final double latitude;
  final double longitude;
  final String imageUrl;
  final String category;
  final double rating;
  final String address;
  final List<String> tags;

  Place({
    required this.id,
    required this.name,
    required this.description,
    required this.latitude,
    required this.longitude,
    required this.imageUrl,
    required this.category,
    required this.rating,
    required this.address,
    required this.tags,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'latitude': latitude,
      'longitude': longitude,
      'imageUrl': imageUrl,
      'category': category,
      'rating': rating,
      'address': address,
      'tags': tags,
    };
  }

  factory Place.fromJson(Map<String, dynamic> json) {
    return Place(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      latitude: (json['latitude'] ?? 0).toDouble(),
      longitude: (json['longitude'] ?? 0).toDouble(),
      imageUrl: json['imageUrl'] ?? '',
      category: json['category'] ?? '',
      rating: (json['rating'] ?? 0).toDouble(),
      address: json['address'] ?? '',
      tags: List<String>.from(json['tags'] ?? []),
    );
  }
}
