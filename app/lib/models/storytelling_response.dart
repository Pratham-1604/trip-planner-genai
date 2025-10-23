class StorytellingResponse {
  final String story;
  final List<StoryDay> days;

  StorytellingResponse({
    required this.story,
    required this.days,
  });

  factory StorytellingResponse.fromJson(Map<String, dynamic> json) {
    return StorytellingResponse(
      story: json['story'] ?? '',
      days: (json['days'] as List<dynamic>?)
          ?.map((day) => StoryDay.fromJson(day))
          .toList() ?? [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'story': story,
      'days': days.map((day) => day.toJson()).toList(),
    };
  }
}

class StoryDay {
  final int day;
  final String title;
  final String summary;
  final List<StoryPlace> places;

  StoryDay({
    required this.day,
    required this.title,
    required this.summary,
    required this.places,
  });

  factory StoryDay.fromJson(Map<String, dynamic> json) {
    return StoryDay(
      day: json['day'] ?? 0,
      title: json['title'] ?? '',
      summary: json['summary'] ?? '',
      places: (json['places'] as List<dynamic>?)
          ?.map((place) => StoryPlace.fromJson(place))
          .toList() ?? [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'day': day,
      'title': title,
      'summary': summary,
      'places': places.map((place) => place.toJson()).toList(),
    };
  }
}

class StoryPlace {
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

  StoryPlace({
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

  factory StoryPlace.fromJson(Map<String, dynamic> json) {
    return StoryPlace(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      latitude: (json['latitude'] ?? 0.0).toDouble(),
      longitude: (json['longitude'] ?? 0.0).toDouble(),
      imageUrl: json['imageUrl'] ?? '',
      category: json['category'] ?? '',
      rating: (json['rating'] ?? 0.0).toDouble(),
      address: json['address'] ?? '',
      tags: (json['tags'] as List<dynamic>?)
          ?.map((tag) => tag.toString())
          .toList() ?? [],
    );
  }

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
}
