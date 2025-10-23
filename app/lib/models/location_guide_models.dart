
class LocationGuide {
  final String id;
  final String itineraryId;
  final String currentLocation;
  final int currentDayIndex;
  final int currentActivityIndex;
  final DateTime lastUpdated;
  final List<GuideStep> completedSteps;
  final List<GuideStep> upcomingSteps;
  final GuideStatus status;
  final Map<String, dynamic> preferences;

  LocationGuide({
    required this.id,
    required this.itineraryId,
    required this.currentLocation,
    required this.currentDayIndex,
    required this.currentActivityIndex,
    required this.lastUpdated,
    required this.completedSteps,
    required this.upcomingSteps,
    required this.status,
    required this.preferences,
  });

  factory LocationGuide.fromJson(Map<String, dynamic> json) {
    return LocationGuide(
      id: json['id'] ?? '',
      itineraryId: json['itineraryId'] ?? '',
      currentLocation: json['currentLocation'] ?? '',
      currentDayIndex: json['currentDayIndex'] ?? 0,
      currentActivityIndex: json['currentActivityIndex'] ?? 0,
      lastUpdated: DateTime.parse(json['lastUpdated']),
      completedSteps: (json['completedSteps'] as List<dynamic>?)
          ?.map((step) => GuideStep.fromJson(step))
          .toList() ?? [],
      upcomingSteps: (json['upcomingSteps'] as List<dynamic>?)
          ?.map((step) => GuideStep.fromJson(step))
          .toList() ?? [],
      status: GuideStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => GuideStatus.notStarted,
      ),
      preferences: json['preferences'] ?? {},
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'itineraryId': itineraryId,
      'currentLocation': currentLocation,
      'currentDayIndex': currentDayIndex,
      'currentActivityIndex': currentActivityIndex,
      'lastUpdated': lastUpdated.toIso8601String(),
      'completedSteps': completedSteps.map((step) => step.toJson()).toList(),
      'upcomingSteps': upcomingSteps.map((step) => step.toJson()).toList(),
      'status': status.name,
      'preferences': preferences,
    };
  }

  LocationGuide copyWith({
    String? id,
    String? itineraryId,
    String? currentLocation,
    int? currentDayIndex,
    int? currentActivityIndex,
    DateTime? lastUpdated,
    List<GuideStep>? completedSteps,
    List<GuideStep>? upcomingSteps,
    GuideStatus? status,
    Map<String, dynamic>? preferences,
  }) {
    return LocationGuide(
      id: id ?? this.id,
      itineraryId: itineraryId ?? this.itineraryId,
      currentLocation: currentLocation ?? this.currentLocation,
      currentDayIndex: currentDayIndex ?? this.currentDayIndex,
      currentActivityIndex: currentActivityIndex ?? this.currentActivityIndex,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      completedSteps: completedSteps ?? this.completedSteps,
      upcomingSteps: upcomingSteps ?? this.upcomingSteps,
      status: status ?? this.status,
      preferences: preferences ?? this.preferences,
    );
  }
}

class GuideStep {
  final String id;
  final String title;
  final String description;
  final String location;
  final String address;
  final double latitude;
  final double longitude;
  final DateTime scheduledTime;
  final int estimatedDuration; // in minutes
  final String category; // morning, afternoon, evening
  final int dayIndex;
  final int activityIndex;
  final List<String> tips;
  final List<String> nearbyAttractions;
  final Map<String, dynamic> metadata;
  final bool isCompleted;
  final DateTime? completedAt;

  GuideStep({
    required this.id,
    required this.title,
    required this.description,
    required this.location,
    required this.address,
    required this.latitude,
    required this.longitude,
    required this.scheduledTime,
    required this.estimatedDuration,
    required this.category,
    required this.dayIndex,
    required this.activityIndex,
    required this.tips,
    required this.nearbyAttractions,
    required this.metadata,
    this.isCompleted = false,
    this.completedAt,
  });

  factory GuideStep.fromJson(Map<String, dynamic> json) {
    return GuideStep(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      location: json['location'] ?? '',
      address: json['address'] ?? '',
      latitude: (json['latitude'] ?? 0.0).toDouble(),
      longitude: (json['longitude'] ?? 0.0).toDouble(),
      scheduledTime: DateTime.parse(json['scheduledTime']),
      estimatedDuration: json['estimatedDuration'] ?? 60,
      category: json['category'] ?? 'morning',
      dayIndex: json['dayIndex'] ?? 0,
      activityIndex: json['activityIndex'] ?? 0,
      tips: List<String>.from(json['tips'] ?? []),
      nearbyAttractions: List<String>.from(json['nearbyAttractions'] ?? []),
      metadata: json['metadata'] ?? {},
      isCompleted: json['isCompleted'] ?? false,
      completedAt: json['completedAt'] != null 
          ? DateTime.parse(json['completedAt']) 
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'location': location,
      'address': address,
      'latitude': latitude,
      'longitude': longitude,
      'scheduledTime': scheduledTime.toIso8601String(),
      'estimatedDuration': estimatedDuration,
      'category': category,
      'dayIndex': dayIndex,
      'activityIndex': activityIndex,
      'tips': tips,
      'nearbyAttractions': nearbyAttractions,
      'metadata': metadata,
      'isCompleted': isCompleted,
      'completedAt': completedAt?.toIso8601String(),
    };
  }

  GuideStep copyWith({
    String? id,
    String? title,
    String? description,
    String? location,
    String? address,
    double? latitude,
    double? longitude,
    DateTime? scheduledTime,
    int? estimatedDuration,
    String? category,
    int? dayIndex,
    int? activityIndex,
    List<String>? tips,
    List<String>? nearbyAttractions,
    Map<String, dynamic>? metadata,
    bool? isCompleted,
    DateTime? completedAt,
  }) {
    return GuideStep(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      location: location ?? this.location,
      address: address ?? this.address,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      scheduledTime: scheduledTime ?? this.scheduledTime,
      estimatedDuration: estimatedDuration ?? this.estimatedDuration,
      category: category ?? this.category,
      dayIndex: dayIndex ?? this.dayIndex,
      activityIndex: activityIndex ?? this.activityIndex,
      tips: tips ?? this.tips,
      nearbyAttractions: nearbyAttractions ?? this.nearbyAttractions,
      metadata: metadata ?? this.metadata,
      isCompleted: isCompleted ?? this.isCompleted,
      completedAt: completedAt ?? this.completedAt,
    );
  }

  String get formattedDuration {
    final hours = estimatedDuration ~/ 60;
    final minutes = estimatedDuration % 60;
    if (hours == 0) {
      return '${minutes}m';
    } else if (minutes == 0) {
      return '${hours}h';
    } else {
      return '${hours}h ${minutes}m';
    }
  }

  String get formattedScheduledTime {
    final hour = scheduledTime.hour;
    final minute = scheduledTime.minute;
    final period = hour >= 12 ? 'PM' : 'AM';
    final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
    return '${displayHour}:${minute.toString().padLeft(2, '0')} $period';
  }
}

enum GuideStatus {
  notStarted,
  inProgress,
  paused,
  completed,
  cancelled,
}

class LocationUpdate {
  final String id;
  final String guideId;
  final String location;
  final String address;
  final double latitude;
  final double longitude;
  final DateTime timestamp;
  final String notes;
  final Map<String, dynamic> metadata;

  LocationUpdate({
    required this.id,
    required this.guideId,
    required this.location,
    required this.address,
    required this.latitude,
    required this.longitude,
    required this.timestamp,
    required this.notes,
    required this.metadata,
  });

  factory LocationUpdate.fromJson(Map<String, dynamic> json) {
    return LocationUpdate(
      id: json['id'] ?? '',
      guideId: json['guideId'] ?? '',
      location: json['location'] ?? '',
      address: json['address'] ?? '',
      latitude: (json['latitude'] ?? 0.0).toDouble(),
      longitude: (json['longitude'] ?? 0.0).toDouble(),
      timestamp: DateTime.parse(json['timestamp']),
      notes: json['notes'] ?? '',
      metadata: json['metadata'] ?? {},
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'guideId': guideId,
      'location': location,
      'address': address,
      'latitude': latitude,
      'longitude': longitude,
      'timestamp': timestamp.toIso8601String(),
      'notes': notes,
      'metadata': metadata,
    };
  }
}

class GuideRecommendation {
  final String id;
  final String stepId;
  final String type; // weather, traffic, crowd, general
  final String title;
  final String description;
  final String priority; // high, medium, low
  final List<String> actions;
  final Map<String, dynamic> metadata;
  final DateTime createdAt;

  GuideRecommendation({
    required this.id,
    required this.stepId,
    required this.type,
    required this.title,
    required this.description,
    required this.priority,
    required this.actions,
    required this.metadata,
    required this.createdAt,
  });

  factory GuideRecommendation.fromJson(Map<String, dynamic> json) {
    return GuideRecommendation(
      id: json['id'] ?? '',
      stepId: json['stepId'] ?? '',
      type: json['type'] ?? 'general',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      priority: json['priority'] ?? 'medium',
      actions: List<String>.from(json['actions'] ?? []),
      metadata: json['metadata'] ?? {},
      createdAt: DateTime.parse(json['createdAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'stepId': stepId,
      'type': type,
      'title': title,
      'description': description,
      'priority': priority,
      'actions': actions,
      'metadata': metadata,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
