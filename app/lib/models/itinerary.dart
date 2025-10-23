import 'day_plan.dart';

class Itinerary {
  final String id;
  final String title;
  final String description;
  final String destination;
  final String startDate;
  final String endDate;
  final int travelers;
  final List<DayPlan> itinerary;
  final double totalEstimatedCost;

  Itinerary({
    required this.id,
    required this.title,
    required this.description,
    required this.destination,
    required this.startDate,
    required this.endDate,
    required this.travelers,
    required this.itinerary,
    required this.totalEstimatedCost,
  });

  // Computed properties
  List<DayPlan> get days => itinerary;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'destination': destination,
      'start_date': startDate,
      'end_date': endDate,
      'travelers': travelers,
      'itinerary': itinerary.map((day) => day.toJson()).toList(),
      'total_estimated_cost': totalEstimatedCost,
    };
  }

  factory Itinerary.fromJson(Map<String, dynamic> json) {
    return Itinerary(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      destination: json['destination'] ?? '',
      startDate: json['start_date'] ?? '',
      endDate: json['end_date'] ?? '',
      travelers: json['travelers'] ?? 1,
      itinerary: (json['itinerary'] as List<dynamic>?)
          ?.map((day) => DayPlan.fromJson(day))
          .toList() ?? [],
      totalEstimatedCost: (json['total_estimated_cost'] ?? 0).toDouble(),
    );
  }
}
