import 'package:cloud_firestore/cloud_firestore.dart';
import 'itinerary.dart';
import 'storytelling_response.dart';
import 'flight_models.dart';

class SavedTrip {
  final String id;
  final String userId;
  final String title;
  final String description;
  final Itinerary itinerary;
  final StorytellingResponse? storytellingResponse;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<String> tags;
  final String? coverImageUrl;
  final String? originLocation;
  final String? destinationLocation;
  final Airport? originAirport;
  final Airport? destinationAirport;

  SavedTrip({
    required this.id,
    required this.userId,
    required this.title,
    required this.description,
    required this.itinerary,
    this.storytellingResponse,
    required this.createdAt,
    required this.updatedAt,
    this.tags = const [],
    this.coverImageUrl,
    this.originLocation,
    this.destinationLocation,
    this.originAirport,
    this.destinationAirport,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'title': title,
      'description': description,
      'itinerary': itinerary.toJson(),
      'storytellingResponse': storytellingResponse?.toJson(),
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'tags': tags,
      'coverImageUrl': coverImageUrl,
      'originLocation': originLocation,
      'destinationLocation': destinationLocation,
      'originAirport': originAirport?.toJson(),
      'destinationAirport': destinationAirport?.toJson(),
    };
  }

  factory SavedTrip.fromJson(Map<String, dynamic> json) {
    return SavedTrip(
      id: json['id'] ?? '',
      userId: json['userId'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      itinerary: Itinerary.fromJson(json['itinerary'] ?? {}),
      storytellingResponse: json['storytellingResponse'] != null
          ? StorytellingResponse.fromJson(json['storytellingResponse'])
          : null,
      createdAt: (json['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (json['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      tags: (json['tags'] as List<dynamic>?)
          ?.map((tag) => tag.toString())
          .toList() ?? [],
      coverImageUrl: json['coverImageUrl'],
      originLocation: json['originLocation'],
      destinationLocation: json['destinationLocation'],
      originAirport: json['originAirport'] != null 
          ? Airport.fromJson(json['originAirport']) 
          : null,
      destinationAirport: json['destinationAirport'] != null 
          ? Airport.fromJson(json['destinationAirport']) 
          : null,
    );
  }

  SavedTrip copyWith({
    String? id,
    String? userId,
    String? title,
    String? description,
    Itinerary? itinerary,
    StorytellingResponse? storytellingResponse,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<String>? tags,
    String? coverImageUrl,
    String? originLocation,
    String? destinationLocation,
    Airport? originAirport,
    Airport? destinationAirport,
  }) {
    return SavedTrip(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      description: description ?? this.description,
      itinerary: itinerary ?? this.itinerary,
      storytellingResponse: storytellingResponse ?? this.storytellingResponse,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      tags: tags ?? this.tags,
      coverImageUrl: coverImageUrl ?? this.coverImageUrl,
      originLocation: originLocation ?? this.originLocation,
      destinationLocation: destinationLocation ?? this.destinationLocation,
      originAirport: originAirport ?? this.originAirport,
      destinationAirport: destinationAirport ?? this.destinationAirport,
    );
  }
}
