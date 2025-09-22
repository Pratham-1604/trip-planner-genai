import 'package:google_frontend/models/day_plan.dart';

import '../models/itinerary.dart';
import '../models/trip_segment.dart';
import '../models/place.dart';
import '../models/storytelling_response.dart';
import '../repository/trip_repository.dart';

class StorytellingService {
  final TripRepository _repository = TripRepository();

  // Sample places data for Mumbai (static for MVP)
  static final Map<String, Place> _samplePlaces = {
    'gateway_of_india': Place(
      id: 'gateway_of_india',
      name: 'Gateway of India',
      description: 'An iconic monument and historical landmark in Mumbai, built to commemorate the visit of King George V and Queen Mary to India in 1911.',
      latitude: 18.9220,
      longitude: 72.8347,
      imageUrl: 'https://images.unsplash.com/photo-1587474260584-136574528ed5?w=800',
      category: 'Monument',
      rating: 4.5,
      address: 'Apollo Bandar, Colaba, Mumbai, Maharashtra 400001',
      tags: ['historical', 'monument', 'photography'],
    ),
    'juhu_beach': Place(
      id: 'juhu_beach',
      name: 'Juhu Beach',
      description: 'One of Mumbai\'s most popular beaches, known for its street food, sunset views, and Bollywood connections.',
      latitude: 19.1074,
      longitude: 72.8263,
      imageUrl: 'https://images.unsplash.com/photo-1578662996442-48f60103fc96?w=800',
      category: 'Beach',
      rating: 4.2,
      address: 'Juhu Beach, Juhu, Mumbai, Maharashtra 400049',
      tags: ['beach', 'food', 'sunset', 'entertainment'],
    ),
    'marine_drive': Place(
      id: 'marine_drive',
      name: 'Marine Drive',
      description: 'A 3.6 km long boulevard in South Mumbai, known as the "Queen\'s Necklace" due to its curved shape and street lights.',
      latitude: 18.9440,
      longitude: 72.8239,
      imageUrl: 'https://images.unsplash.com/photo-1587474260584-136574528ed5?w=800',
      category: 'Landmark',
      rating: 4.6,
      address: 'Marine Drive, Mumbai, Maharashtra 400020',
      tags: ['scenic', 'walking', 'photography', 'sunset'],
    ),
    'cst_station': Place(
      id: 'cst_station',
      name: 'Chhatrapati Shivaji Terminus',
      description: 'A UNESCO World Heritage Site and historic railway station, showcasing Victorian Gothic architecture.',
      latitude: 18.9400,
      longitude: 72.8355,
      imageUrl: 'https://images.unsplash.com/photo-1587474260584-136574528ed5?w=800',
      category: 'Heritage',
      rating: 4.4,
      address: 'Chhatrapati Shivaji Terminus Area, Fort, Mumbai, Maharashtra 400001',
      tags: ['heritage', 'architecture', 'unesco', 'photography'],
    ),
    'hotel_taj': Place(
      id: 'hotel_taj',
      name: 'The Taj Mahal Palace',
      description: 'A luxury heritage hotel overlooking the Gateway of India, known for its opulent architecture and rich history.',
      latitude: 18.9217,
      longitude: 72.8331,
      imageUrl: 'https://images.unsplash.com/photo-1587474260584-136574528ed5?w=800',
      category: 'Hotel',
      rating: 4.8,
      address: 'Apollo Bunder, Colaba, Mumbai, Maharashtra 400001',
      tags: ['luxury', 'heritage', 'hotel', 'dining'],
    ),
  };

  // Generate storytelling experience from itinerary
  Future<StorytellingResponse> generateStorytellingExperience(Itinerary itinerary) async {
    try {
      // Call the storytelling API
      final response = await _repository.generateStorytelling(itinerary);
      return StorytellingResponse.fromJson(response);
    } catch (e) {
      print('Error generating storytelling experience: $e');
      // Fall back to sample data
      return _getSampleStorytellingResponse();
    }
  }

  // Generate trip segments from storytelling response
  List<TripSegment> generateTripSegmentsFromStorytelling(StorytellingResponse storytellingResponse) {
    List<TripSegment> segments = [];
    
    for (final storyDay in storytellingResponse.days) {
      // Create segments for each day's places
      for (int i = 0; i < storyDay.places.length - 1; i++) {
        final fromPlace = _convertStoryPlaceToPlace(storyDay.places[i]);
        final toPlace = _convertStoryPlaceToPlace(storyDay.places[i + 1]);
        
        segments.add(TripSegment(
          id: 'day_${storyDay.day}_segment_${i + 1}',
          fromPlace: fromPlace,
          toPlace: toPlace,
          transportMode: _determineTransportModeFromPlaces(fromPlace, toPlace),
          estimatedDuration: _calculateDuration(fromPlace, toPlace, 'Taxi'),
          distance: _calculateDistance(fromPlace, toPlace),
          routeDescription: 'Travel from ${fromPlace.name} to ${toPlace.name} as part of your ${storyDay.title} experience.',
          highlights: _extractHighlightsFromStoryDay(storyDay),
        ));
      }
    }

    return segments;
  }

  // Legacy method for backward compatibility
  List<TripSegment> generateTripSegments(Itinerary itinerary) {
    // For now, return sample segments
    // In the future, this could call generateStorytellingExperience and convert
    return _getSampleSegments();
  }

  // Extract locations from a day's activities
  List<Place> _extractLocationsFromDay(DayPlan dayPlan) {
    List<Place> locations = [];
    
    // Combine all activities for the day
    final allActivities = [
      dayPlan.morning,
      dayPlan.afternoon,
      dayPlan.evening,
    ].where((activity) => activity.isNotEmpty).toList();
    
    // Look for known locations in the activities
    for (final activity in allActivities) {
      final location = _findLocationInText(activity);
      if (location != null && !locations.any((l) => l.id == location.id)) {
        locations.add(location);
      }
    }
    
    // If no specific locations found, create generic places based on destination
    if (locations.isEmpty) {
      locations = _createGenericPlacesForDay(dayPlan);
    }
    
    return locations;
  }

  // Find a location in the activity text
  Place? _findLocationInText(String activity) {
    final activityLower = activity.toLowerCase();
    
    // Check against known places
    for (final place in _samplePlaces.values) {
      if (activityLower.contains(place.name.toLowerCase()) ||
          activityLower.contains(place.address.toLowerCase())) {
        return place;
      }
    }
    
    // Look for common location keywords
    if (activityLower.contains('airport')) {
      return _createPlaceFromKeyword('airport', activity);
    } else if (activityLower.contains('beach')) {
      return _createPlaceFromKeyword('beach', activity);
    } else if (activityLower.contains('market')) {
      return _createPlaceFromKeyword('market', activity);
    } else if (activityLower.contains('restaurant') || activityLower.contains('cafe')) {
      return _createPlaceFromKeyword('restaurant', activity);
    }
    
    return null;
  }

  // Create a place from a keyword found in the text
  Place _createPlaceFromKeyword(String keyword, String context) {
    // Extract the name from the context
    String name = keyword;
    if (context.contains('Goa Airport')) name = 'Goa Airport';
    else if (context.contains('Mandrem Beach')) name = 'Mandrem Beach';
    else if (context.contains('Anjuna Flea Market')) name = 'Anjuna Flea Market';
    else if (context.contains('Artjuna')) name = 'Artjuna';
    else if (context.contains('Old Goa')) name = 'Old Goa';
    else if (context.contains('Palolem Beach')) name = 'Palolem Beach';
    else if (context.contains('Agonda Beach')) name = 'Agonda Beach';
    else if (context.contains('Madgaon Market')) name = 'Madgaon Market';
    
    return Place(
      id: name.toLowerCase().replaceAll(' ', '_'),
      name: name,
      description: 'A location mentioned in your itinerary',
      latitude: 15.2993, // Default Goa coordinates
      longitude: 74.1240,
      imageUrl: 'https://images.unsplash.com/photo-1506905925346-14bda2d134d4?w=800',
      category: _getCategoryFromKeyword(keyword),
      rating: 4.0,
      address: 'Goa, India',
      tags: [keyword],
    );
  }

  // Get category from keyword
  String _getCategoryFromKeyword(String keyword) {
    switch (keyword.toLowerCase()) {
      case 'airport':
        return 'Transport';
      case 'beach':
        return 'Beach';
      case 'market':
        return 'Shopping';
      case 'restaurant':
        return 'Dining';
      default:
        return 'Attraction';
    }
  }

  // Create generic places for a day if no specific locations found
  List<Place> _createGenericPlacesForDay(DayPlan dayPlan) {
    return [
      Place(
        id: 'day_${dayPlan.day}_start',
        name: 'Day ${dayPlan.day} Starting Point',
        description: 'Starting point for your day ${dayPlan.day} activities',
        latitude: 15.2993,
        longitude: 74.1240,
        imageUrl: 'https://images.unsplash.com/photo-1506905925346-14bda2d134d4?w=800',
        category: 'Starting Point',
        rating: 4.0,
        address: 'Goa, India',
        tags: ['starting_point'],
      ),
      Place(
        id: 'day_${dayPlan.day}_end',
        name: 'Day ${dayPlan.day} Ending Point',
        description: 'Ending point for your day ${dayPlan.day} activities',
        latitude: 15.2993,
        longitude: 74.1240,
        imageUrl: 'https://images.unsplash.com/photo-1506905925346-14bda2d134d4?w=800',
        category: 'Ending Point',
        rating: 4.0,
        address: 'Goa, India',
        tags: ['ending_point'],
      ),
    ];
  }

  // Determine transport mode based on context
  String _determineTransportMode(DayPlan dayPlan, Place fromPlace, Place toPlace) {
    final allActivities = [
      dayPlan.morning,
      dayPlan.afternoon,
      dayPlan.evening,
    ].join(' ').toLowerCase();
    
    if (allActivities.contains('scooter') || allActivities.contains('rent a scooter')) {
      return 'Scooter';
    } else if (allActivities.contains('taxi') || allActivities.contains('cab')) {
      return 'Taxi';
    } else if (allActivities.contains('walk') || allActivities.contains('walking')) {
      return 'Walking';
    } else if (allActivities.contains('train') || allActivities.contains('local train')) {
      return 'Train';
    } else if (allActivities.contains('boat') || allActivities.contains('ferry')) {
      return 'Boat';
    } else {
      return 'Taxi'; // Default transport mode
    }
  }

  // Calculate estimated duration
  int _calculateDuration(Place fromPlace, Place toPlace, String transportMode) {
    // Simple calculation based on transport mode
    switch (transportMode.toLowerCase()) {
      case 'walking':
        return 15;
      case 'scooter':
        return 30;
      case 'taxi':
        return 25;
      case 'train':
        return 45;
      case 'boat':
        return 20;
      default:
        return 30;
    }
  }

  // Calculate distance (simplified)
  double _calculateDistance(Place fromPlace, Place toPlace) {
    // Simple distance calculation (in reality, you'd use proper geocoding)
    return 5.0; // Default distance
  }

  // Generate route description
  String _generateRouteDescription(Place fromPlace, Place toPlace, String transportMode, DayPlan dayPlan) {
    return 'Travel from ${fromPlace.name} to ${toPlace.name} by $transportMode. This route is part of your day ${dayPlan.day} itinerary.';
  }

  // Extract highlights from day plan
  List<String> _extractHighlights(DayPlan dayPlan, Place fromPlace, Place toPlace) {
    List<String> highlights = [];
    
    final allActivities = [
      dayPlan.morning,
      dayPlan.afternoon,
      dayPlan.evening,
    ].join(' ');
    
    // Extract cost information
    final costMatch = RegExp(r'₹(\d+)').firstMatch(allActivities);
    if (costMatch != null) {
      highlights.add('Estimated cost: ₹${costMatch.group(1)}');
    }
    
    // Extract time information
    if (allActivities.contains('morning')) highlights.add('Best time: Morning');
    if (allActivities.contains('afternoon')) highlights.add('Best time: Afternoon');
    if (allActivities.contains('evening')) highlights.add('Best time: Evening');
    
    // Extract special mentions
    if (allActivities.contains('photography')) highlights.add('Great for photography');
    if (allActivities.contains('food') || allActivities.contains('dining')) highlights.add('Food options available');
    if (allActivities.contains('shopping')) highlights.add('Shopping opportunities');
    
    return highlights;
  }

  // Fallback sample segments
  List<TripSegment> _getSampleSegments() {
    return [
      TripSegment(
        id: 'segment_1',
        fromPlace: _samplePlaces['hotel_taj']!,
        toPlace: _samplePlaces['gateway_of_india']!,
        transportMode: 'Walking',
        estimatedDuration: 5,
        distance: 0.2,
        routeDescription: 'A short walk from your hotel to the iconic Gateway of India. Perfect for morning photography with fewer crowds.',
        highlights: [
          'Best time: Early morning for photography',
          'Street vendors selling local snacks',
          'Horse carriage rides available',
        ],
      ),
      TripSegment(
        id: 'segment_2',
        fromPlace: _samplePlaces['gateway_of_india']!,
        toPlace: _samplePlaces['marine_drive']!,
        transportMode: 'Taxi',
        estimatedDuration: 20,
        distance: 8.5,
        routeDescription: 'Take a taxi along the scenic route to Marine Drive. You\'ll pass through the financial district and see the city\'s skyline.',
        highlights: [
          'Scenic drive through Mumbai\'s financial district',
          'Pass by Nariman Point business area',
          'Beautiful coastal views',
        ],
      ),
    ];
  }

  // Get place details by ID
  Place? getPlaceById(String placeId) {
    return _samplePlaces[placeId];
  }

  // Get all available places
  List<Place> getAllPlaces() {
    return _samplePlaces.values.toList();
  }

  // Convert StoryPlace to Place
  Place _convertStoryPlaceToPlace(StoryPlace storyPlace) {
    return Place(
      id: storyPlace.id,
      name: storyPlace.name,
      description: storyPlace.description,
      latitude: storyPlace.latitude,
      longitude: storyPlace.longitude,
      imageUrl: storyPlace.imageUrl,
      category: storyPlace.category,
      rating: storyPlace.rating,
      address: storyPlace.address,
      tags: storyPlace.tags,
    );
  }

  // Determine transport mode from places
  String _determineTransportModeFromPlaces(Place fromPlace, Place toPlace) {
    // Simple logic based on distance
    final distance = _calculateDistance(fromPlace, toPlace);
    if (distance < 1.0) return 'Walking';
    if (distance < 10.0) return 'Taxi';
    return 'Car';
  }

  // Extract highlights from story day
  List<String> _extractHighlightsFromStoryDay(StoryDay storyDay) {
    List<String> highlights = [];
    highlights.add('Day ${storyDay.day}: ${storyDay.title}');
    highlights.add(storyDay.summary);
    return highlights;
  }

  // Sample storytelling response for fallback
  StorytellingResponse _getSampleStorytellingResponse() {
    return StorytellingResponse(
      story: "Welcome to an amazing journey! This is a sample storytelling experience that showcases the rich cultural heritage and beautiful landscapes of your destination.",
      days: [
        StoryDay(
          day: 1,
          title: "Sample Day Adventure",
          summary: "A wonderful day exploring the highlights of your destination with amazing experiences and beautiful sights.",
          places: [
            StoryPlace(
              id: 'sample_place_1',
              name: 'Sample Place 1',
              description: 'A beautiful sample location with amazing views and experiences.',
              latitude: 15.2993,
              longitude: 74.1240,
              imageUrl: 'https://images.unsplash.com/photo-1506905925346-14bda2d134d4?w=800',
              category: 'Attraction',
              rating: 4.5,
              address: 'Sample Address, Goa',
              tags: ['sample', 'attraction'],
            ),
            StoryPlace(
              id: 'sample_place_2',
              name: 'Sample Place 2',
              description: 'Another wonderful location to explore and enjoy.',
              latitude: 15.3000,
              longitude: 74.1250,
              imageUrl: 'https://images.unsplash.com/photo-1506905925346-14bda2d134d4?w=800',
              category: 'Restaurant',
              rating: 4.0,
              address: 'Sample Address 2, Goa',
              tags: ['sample', 'restaurant'],
            ),
          ],
        ),
      ],
    );
  }
}
