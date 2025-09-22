class DayPlan {
  final int day;
  final String morning;
  final String afternoon;
  final String evening;
  final double estimatedCost;
  final String? note;

  DayPlan({
    required this.day,
    required this.morning,
    required this.afternoon,
    required this.evening,
    required this.estimatedCost,
    this.note,
  });

  Map<String, dynamic> toJson() {
    return {
      'day': day,
      'morning': morning,
      'afternoon': afternoon,
      'evening': evening,
      'estimated_cost': estimatedCost,
      'note': note,
    };
  }

  factory DayPlan.fromJson(Map<String, dynamic> json) {
    return DayPlan(
      day: json['day'] ?? 0,
      morning: json['morning'] ?? '',
      afternoon: json['afternoon'] ?? '',
      evening: json['evening'] ?? '',
      estimatedCost: (json['estimated_cost'] ?? 0).toDouble(),
      note: json['note'],
    );
  }
}
