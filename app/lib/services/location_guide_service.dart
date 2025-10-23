import '../models/location_guide_models.dart';
import '../models/itinerary.dart';

class LocationGuideService {
  static const String baseUrl = 'https://your-api-server.com'; // Replace with your actual API URL

  // Create a new location guide from itinerary
  Future<LocationGuide> createLocationGuide(Itinerary itinerary) async {
    // For development, always return mock data
    // In production, this would make actual API calls
    return _createMockLocationGuide(itinerary);
  }

  // Get location guide by ID
  Future<LocationGuide> getLocationGuide(String guideId) async {
    // For development, return mock data
    // In production, this would make actual API calls
    throw Exception('Location guide not found');
  }

  // Update current location
  Future<LocationGuide> updateCurrentLocation(
    String guideId,
    String location,
    String address,
    double latitude,
    double longitude,
    String notes,
  ) async {
    // For development, return mock updated guide
    // In production, this would make actual API calls
    return _getMockUpdatedGuide(guideId, location, address, latitude, longitude);
  }

  // Mark step as completed
  Future<LocationGuide> markStepCompleted(String guideId, String stepId, LocationGuide currentGuide) async {
    // For development, simulate moving to next step
    // In production, this would make actual API calls
    return _getMockStepCompletedGuide(guideId, stepId, currentGuide);
  }

  // Get recommendations for current step
  Future<List<GuideRecommendation>> getRecommendations(String guideId, String stepId) async {
    // For development, return mock recommendations
    // In production, this would make actual API calls
    return _getMockRecommendations(stepId);
  }

  // Get directions to next location
  Future<Map<String, dynamic>> getDirections(
    double fromLat,
    double fromLng,
    double toLat,
    double toLng,
  ) async {
    // For development, return mock directions
    // In production, this would make actual API calls
    return _getMockDirections(fromLat, fromLng, toLat, toLng);
  }

  // Mock data for development - simplified version
  LocationGuide _createMockLocationGuide(Itinerary itinerary) {
    final now = DateTime.now();
    final guideId = 'guide_${now.millisecondsSinceEpoch}';
    
    // Create simple guide steps without complex date parsing
    final allSteps = <GuideStep>[];
    
    // Just create a few simple steps for demonstration
    allSteps.add(_createMockStep(
      guideId,
      'First Activity',
      'Start your journey by exploring the local area',
      itinerary.destination,
      'Main tourist area',
      18.9220,
      72.8347,
      now.add(const Duration(hours: 1)),
      120,
      'morning',
      0,
      0,
    ));
    
    if (itinerary.days.isNotEmpty && itinerary.days.first.afternoon.isNotEmpty) {
      allSteps.add(_createMockStep(
        guideId,
        'Afternoon Activity',
        itinerary.days.first.afternoon,
        itinerary.destination,
        'Local attractions',
        18.9220,
        72.8347,
        now.add(const Duration(hours: 4)),
        180,
        'afternoon',
        0,
        1,
      ));
    }
    
    if (itinerary.days.isNotEmpty && itinerary.days.first.evening.isNotEmpty) {
      allSteps.add(_createMockStep(
        guideId,
        'Evening Activity',
        itinerary.days.first.evening,
        itinerary.destination,
        'Evening spots',
        18.9440,
        72.8250,
        now.add(const Duration(hours: 8)),
        120,
        'evening',
        0,
        2,
      ));
    }

    // Simple starting location
    String startingLocation = 'Starting Point';
    if (itinerary.destination.toLowerCase().contains('hotel')) {
      startingLocation = 'Hotel Check-in';
    } else if (itinerary.destination.toLowerCase().contains('mumbai')) {
      startingLocation = 'Mumbai Airport';
    } else if (itinerary.destination.toLowerCase().contains('delhi')) {
      startingLocation = 'Delhi Airport';
    } else if (itinerary.destination.toLowerCase().contains('goa')) {
      startingLocation = 'Goa Airport';
    }

    return LocationGuide(
      id: guideId,
      itineraryId: itinerary.id,
      currentLocation: startingLocation,
      currentDayIndex: 0,
      currentActivityIndex: 0,
      lastUpdated: now,
      completedSteps: [],
      upcomingSteps: allSteps,
      status: GuideStatus.inProgress,
      preferences: {
        'transport_mode': 'walking',
        'notifications_enabled': true,
        'weather_optimization': true,
        'crowd_optimization': true,
      },
    );
  }

  GuideStep _createMockStep(
    String guideId,
    String title,
    String description,
    String location,
    String address,
    double latitude,
    double longitude,
    DateTime scheduledTime,
    int estimatedDuration,
    String category,
    int dayIndex,
    int activityIndex,
  ) {
    return GuideStep(
      id: '${guideId}_step_${dayIndex}_$activityIndex',
      title: title,
      description: description,
      location: location,
      address: address,
      latitude: latitude,
      longitude: longitude,
      scheduledTime: scheduledTime,
      estimatedDuration: estimatedDuration,
      category: category,
      dayIndex: dayIndex,
      activityIndex: activityIndex,
      tips: _getMockTips(location),
      nearbyAttractions: _getMockNearbyAttractions(location),
      metadata: {
        'weather_dependent': true,
        'crowd_level': 'medium',
        'best_time': 'morning',
        'entry_fee': 0,
        'duration_flexible': true,
      },
    );
  }

  List<String> _getMockTips(String location) {
    final tipsMap = {
      'Mumbai': [
        'Best time to visit is early morning or late evening',
        'Carry water and sunscreen',
        'Parking can be limited, consider public transport',
        'Photography is allowed but check for restrictions',
      ],
      'Delhi': [
        'Wear comfortable walking shoes',
        'Bargain at local markets',
        'Try local street food',
        'Respect local customs and traditions',
      ],
      'Goa': [
        'Apply sunscreen regularly',
        'Stay hydrated in the heat',
        'Respect beach rules and regulations',
        'Try local seafood delicacies',
      ],
    };
    
    return tipsMap[location] ?? [
      'Plan your visit during off-peak hours',
      'Check weather conditions before going',
      'Carry necessary documents',
      'Follow local guidelines and rules',
    ];
  }

  List<String> _getMockNearbyAttractions(String location) {
    final attractionsMap = {
      'Mumbai': [
        'Gateway of India',
        'Taj Mahal Palace Hotel',
        'Colaba Causeway',
        'Marine Drive',
        'Elephanta Caves',
      ],
      'Delhi': [
        'Red Fort',
        'India Gate',
        'Lotus Temple',
        'Chandni Chowk',
        'Akshardham Temple',
      ],
      'Goa': [
        'Baga Beach',
        'Calangute Beach',
        'Fort Aguada',
        'Dudhsagar Falls',
        'Old Goa Churches',
      ],
    };
    
    return attractionsMap[location] ?? [
      'Local Market',
      'Historical Monument',
      'Park or Garden',
      'Shopping Center',
      'Restaurant District',
    ];
  }

  LocationGuide _getMockUpdatedGuide(
    String guideId,
    String location,
    String address,
    double latitude,
    double longitude,
  ) {
    // This would normally fetch the updated guide from the server
    // For now, return a mock updated guide
    return LocationGuide(
      id: guideId,
      itineraryId: 'itinerary_123',
      currentLocation: location,
      currentDayIndex: 0,
      currentActivityIndex: 0,
      lastUpdated: DateTime.now(),
      completedSteps: [],
      upcomingSteps: [],
      status: GuideStatus.inProgress,
      preferences: {},
    );
  }

  LocationGuide _getMockStepCompletedGuide(String guideId, String stepId, LocationGuide currentGuide) {
    // Move the completed step from upcoming to completed
    final completedStep = currentGuide.upcomingSteps.firstWhere(
      (step) => step.id == stepId,
      orElse: () => currentGuide.upcomingSteps.first,
    );
    
    final updatedCompletedSteps = [
      ...currentGuide.completedSteps,
      completedStep.copyWith(
        isCompleted: true,
        completedAt: DateTime.now(),
      ),
    ];
    
    // Remove the completed step from upcoming steps
    final updatedUpcomingSteps = currentGuide.upcomingSteps
        .where((step) => step.id != stepId)
        .toList();
    
    // Update current activity index
    int newActivityIndex = currentGuide.currentActivityIndex;
    int newDayIndex = currentGuide.currentDayIndex;
    
    // If we completed the last step of the day, move to next day
    if (updatedUpcomingSteps.isEmpty) {
      // All steps completed
      newDayIndex = currentGuide.currentDayIndex + 1;
      newActivityIndex = 0;
    } else {
      // Move to next activity
      newActivityIndex = currentGuide.currentActivityIndex + 1;
    }
    
    return currentGuide.copyWith(
      completedSteps: updatedCompletedSteps,
      upcomingSteps: updatedUpcomingSteps,
      currentDayIndex: newDayIndex,
      currentActivityIndex: newActivityIndex,
      lastUpdated: DateTime.now(),
      status: updatedUpcomingSteps.isEmpty ? GuideStatus.completed : GuideStatus.inProgress,
    );
  }

  List<GuideRecommendation> _getMockRecommendations(String stepId) {
    return [
      GuideRecommendation(
        id: 'rec_1',
        stepId: stepId,
        type: 'weather',
        title: 'Weather Alert',
        description: 'Light rain expected in 2 hours. Consider bringing an umbrella.',
        priority: 'high',
        actions: ['Bring umbrella', 'Check weather updates', 'Consider indoor alternatives'],
        metadata: {
          'weather_condition': 'light_rain',
          'probability': 0.7,
          'time_until': 120,
        },
        createdAt: DateTime.now(),
      ),
      GuideRecommendation(
        id: 'rec_2',
        stepId: stepId,
        type: 'crowd',
        title: 'Crowd Level High',
        description: 'This location is currently very crowded. Consider visiting during off-peak hours.',
        priority: 'medium',
        actions: ['Visit during off-peak hours', 'Book tickets in advance', 'Consider alternative timing'],
        metadata: {
          'crowd_level': 'high',
          'wait_time': 45,
          'peak_hours': '10:00-16:00',
        },
        createdAt: DateTime.now(),
      ),
      GuideRecommendation(
        id: 'rec_3',
        stepId: stepId,
        type: 'traffic',
        title: 'Traffic Alert',
        description: 'Heavy traffic on the route. Consider alternative transportation or timing.',
        priority: 'medium',
        actions: ['Use public transport', 'Leave 30 minutes earlier', 'Check real-time traffic'],
        metadata: {
          'traffic_level': 'heavy',
          'delay_minutes': 30,
          'alternative_routes': 2,
        },
        createdAt: DateTime.now(),
      ),
    ];
  }

  Map<String, dynamic> _getMockDirections(
    double fromLat,
    double fromLng,
    double toLat,
    double toLng,
  ) {
    return {
      'distance': '2.5 km',
      'duration': '15 minutes',
      'route': [
        {'lat': fromLat, 'lng': fromLng},
        {'lat': (fromLat + toLat) / 2, 'lng': (fromLng + toLng) / 2},
        {'lat': toLat, 'lng': toLng},
      ],
      'instructions': [
        'Head north on Main Street',
        'Turn right at the traffic light',
        'Continue straight for 1.2 km',
        'Turn left at the intersection',
        'Destination will be on your right',
      ],
      'transport_modes': ['walking', 'driving', 'public_transport'],
    };
  }
}
