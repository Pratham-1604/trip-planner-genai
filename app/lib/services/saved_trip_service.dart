import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/saved_trip.dart';
import '../models/itinerary.dart';
import '../models/storytelling_response.dart';
import '../models/trip_segment.dart';
import '../models/place.dart';
import 'storytelling_service.dart';

class SavedTripService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Get current user ID
  String? get currentUserId => _auth.currentUser?.uid;

  // Save a trip with itinerary and optional storytelling
  Future<String> saveTrip({
    required String title,
    required String description,
    required Itinerary itinerary,
    StorytellingResponse? storytellingResponse,
    List<String> tags = const [],
    String? coverImageUrl,
  }) async {
    final userId = currentUserId;
    if (userId == null) {
      throw Exception('User not authenticated');
    }

    try {
      final tripId = _firestore.collection('savedTrips').doc().id;
      final now = DateTime.now();

      final savedTrip = SavedTrip(
        id: tripId,
        userId: userId,
        title: title,
        description: description,
        itinerary: itinerary,
        storytellingResponse: storytellingResponse,
        createdAt: now,
        updatedAt: now,
        tags: tags,
        coverImageUrl: coverImageUrl,
      );

      await _firestore
          .collection('savedTrips')
          .doc(tripId)
          .set(savedTrip.toJson());

      // Add trip ID to user's saved trips list
      await _firestore.collection('users').doc(userId).update({
        'savedTrips': FieldValue.arrayUnion([tripId]),
      });

      return tripId;
    } catch (e) {
      throw Exception('Failed to save trip: $e');
    }
  }

  // Get all saved trips for current user
  Future<List<SavedTrip>> getSavedTrips() async {
    final userId = currentUserId;
    if (userId == null) {
      throw Exception('User not authenticated');
    }

    try {
      final querySnapshot = await _firestore
          .collection('savedTrips')
          .where('userId', isEqualTo: userId)
          .get();

      // Sort in memory to avoid index requirement
      final trips = querySnapshot.docs
          .map((doc) => SavedTrip.fromJson(doc.data()))
          .toList();

      trips.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
      return trips;
    } catch (e) {
      throw Exception('Failed to get saved trips: $e');
    }
  }

  // Get a specific saved trip by ID
  Future<SavedTrip?> getSavedTrip(String tripId) async {
    try {
      final doc = await _firestore.collection('savedTrips').doc(tripId).get();
      if (doc.exists) {
        return SavedTrip.fromJson(doc.data()!);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get saved trip: $e');
    }
  }

  // Update a saved trip
  Future<void> updateSavedTrip({
    required String tripId,
    String? title,
    String? description,
    Itinerary? itinerary,
    StorytellingResponse? storytellingResponse,
    List<String>? tags,
    String? coverImageUrl,
  }) async {
    final userId = currentUserId;
    if (userId == null) {
      throw Exception('User not authenticated');
    }

    try {
      final updateData = <String, dynamic>{
        'updatedAt': Timestamp.fromDate(DateTime.now()),
      };

      if (title != null) updateData['title'] = title;
      if (description != null) updateData['description'] = description;
      if (itinerary != null) updateData['itinerary'] = itinerary.toJson();
      if (storytellingResponse != null) {
        updateData['storytellingResponse'] = storytellingResponse.toJson();
      }
      if (tags != null) updateData['tags'] = tags;
      if (coverImageUrl != null) updateData['coverImageUrl'] = coverImageUrl;

      await _firestore.collection('savedTrips').doc(tripId).update(updateData);
    } catch (e) {
      throw Exception('Failed to update saved trip: $e');
    }
  }

  // Delete a saved trip
  Future<void> deleteSavedTrip(String tripId) async {
    final userId = currentUserId;
    if (userId == null) {
      throw Exception('User not authenticated');
    }

    try {
      // Remove trip from Firestore
      await _firestore.collection('savedTrips').doc(tripId).delete();

      // Remove trip ID from user's saved trips list
      await _firestore.collection('users').doc(userId).update({
        'savedTrips': FieldValue.arrayRemove([tripId]),
      });
    } catch (e) {
      throw Exception('Failed to delete saved trip: $e');
    }
  }

  // Stream of saved trips for real-time updates
  Stream<List<SavedTrip>> getSavedTripsStream() {
    final userId = currentUserId;
    if (userId == null) {
      return Stream.value([]);
    }

    return _firestore
        .collection('savedTrips')
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) {
          final trips = snapshot.docs
              .map((doc) => SavedTrip.fromJson(doc.data()))
              .toList();

          // Sort in memory to avoid index requirement
          trips.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
          return trips;
        });
  }

  // Add storytelling to an existing saved trip
  Future<void> addStorytellingToTrip({
    required String tripId,
    required StorytellingResponse storytellingResponse,
  }) async {
    await updateSavedTrip(
      tripId: tripId,
      storytellingResponse: storytellingResponse,
    );
  }

  // Generate and add storytelling to an existing saved trip
  Future<void> generateAndAddStorytellingToTrip({
    required String tripId,
    required Itinerary itinerary,
  }) async {
    try {
      // Import the storytelling service
      final storytellingService = StorytellingService();
      
      // Generate storytelling experience
      final storytellingResponse = await storytellingService.generateStorytellingExperience(itinerary);
      
      // Update the saved trip with storytelling
      await updateSavedTrip(
        tripId: tripId,
        storytellingResponse: storytellingResponse,
      );
    } catch (e) {
      throw Exception('Failed to generate storytelling: $e');
    }
  }

  // Generate a default title from itinerary
  String generateDefaultTitle(Itinerary itinerary) {
    final dayCount = itinerary.itinerary.length;
    final totalCost = itinerary.totalEstimatedCost;

    if (dayCount == 1) {
      return '1-Day Trip (₹${totalCost.toInt()})';
    } else {
      return '${dayCount}-Day Trip (₹${totalCost.toInt()})';
    }
  }

  // Generate a default description from itinerary
  String generateDefaultDescription(Itinerary itinerary) {
    final dayCount = itinerary.itinerary.length;
    final totalCost = itinerary.totalEstimatedCost;

    return 'A ${dayCount}-day trip with an estimated budget of ₹${totalCost.toInt()}. '
        'This itinerary includes ${dayCount} days of carefully planned activities and experiences.';
  }

  // Generate trip segments from storytelling response (for compatibility)
  List<TripSegment> generateTripSegmentsFromStorytelling(
    StorytellingResponse storytellingResponse,
  ) {
    // Convert storytelling days to trip segments
    final List<TripSegment> segments = [];

    for (final day in storytellingResponse.days) {
      for (int i = 0; i < day.places.length - 1; i++) {
        final fromPlace = day.places[i];
        final toPlace = day.places[i + 1];

        // Create a basic trip segment
        final segment = TripSegment(
          id: '${day.day}_${i}',
          fromPlace: Place(
            id: fromPlace.id,
            name: fromPlace.name,
            description: fromPlace.description,
            latitude: fromPlace.latitude,
            longitude: fromPlace.longitude,
            imageUrl: fromPlace.imageUrl,
            rating: fromPlace.rating,
            address: fromPlace.address,
            category: fromPlace.category,
            tags: fromPlace.tags,
          ),
          toPlace: Place(
            id: toPlace.id,
            name: toPlace.name,
            description: toPlace.description,
            latitude: toPlace.latitude,
            longitude: toPlace.longitude,
            imageUrl: toPlace.imageUrl,
            rating: toPlace.rating,
            address: toPlace.address,
            category: toPlace.category,
            tags: toPlace.tags,
          ),
          transportMode: 'walking', // Default transport mode
          distance: _calculateDistance(
            fromPlace.latitude,
            fromPlace.longitude,
            toPlace.latitude,
            toPlace.longitude,
          ),
          estimatedDuration: 30, // Default duration
          routeDescription: 'Travel from ${fromPlace.name} to ${toPlace.name}',
          highlights: [],
        );

        segments.add(segment);
      }
    }

    return segments;
  }

  // Calculate distance between two points (simplified)
  double _calculateDistance(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    // Simple distance calculation (not accurate for long distances)
    const double earthRadius = 6371; // km
    final double dLat = _degreesToRadians(lat2 - lat1);
    final double dLon = _degreesToRadians(lon2 - lon1);
    final double a =
        sin(dLat / 2) * sin(dLat / 2) +
        sin(dLon / 2) *
            sin(dLon / 2) *
            cos(_degreesToRadians(lat1)) *
            cos(_degreesToRadians(lat2));
    final double c = 2 * asin(sqrt(a));
    return earthRadius * c;
  }

  double _degreesToRadians(double degrees) {
    return degrees * (pi / 180);
  }
}
