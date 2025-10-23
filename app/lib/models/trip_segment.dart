import 'place.dart';

class TripSegment {
  final String id;
  final Place fromPlace;
  final Place toPlace;
  final String transportMode;
  final int estimatedDuration; // in minutes
  final double distance; // in km
  final String routeDescription;
  final List<String> highlights;

  TripSegment({
    required this.id,
    required this.fromPlace,
    required this.toPlace,
    required this.transportMode,
    required this.estimatedDuration,
    required this.distance,
    required this.routeDescription,
    required this.highlights,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fromPlace': fromPlace.toJson(),
      'toPlace': toPlace.toJson(),
      'transportMode': transportMode,
      'estimatedDuration': estimatedDuration,
      'distance': distance,
      'routeDescription': routeDescription,
      'highlights': highlights,
    };
  }

  factory TripSegment.fromJson(Map<String, dynamic> json) {
    return TripSegment(
      id: json['id'] ?? '',
      fromPlace: Place.fromJson(json['fromPlace']),
      toPlace: Place.fromJson(json['toPlace']),
      transportMode: json['transportMode'] ?? '',
      estimatedDuration: json['estimatedDuration'] ?? 0,
      distance: (json['distance'] ?? 0).toDouble(),
      routeDescription: json['routeDescription'] ?? '',
      highlights: List<String>.from(json['highlights'] ?? []),
    );
  }
}
