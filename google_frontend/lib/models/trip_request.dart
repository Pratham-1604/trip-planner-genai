class TripRequest {
  final String destination;
  final int duration;
  final double budget;
  final List<String> interests;
  final String? startDate;
  final String? endDate;

  TripRequest({
    required this.destination,
    required this.duration,
    required this.budget,
    required this.interests,
    this.startDate,
    this.endDate,
  });

  Map<String, dynamic> toJson() {
    return {
      'destination': destination,
      'duration': duration,
      'budget': budget,
      'interests': interests,
      'start_date': startDate,
      'end_date': endDate,
    };
  }

  factory TripRequest.fromJson(Map<String, dynamic> json) {
    return TripRequest(
      destination: json['destination'] ?? '',
      duration: json['duration'] ?? 0,
      budget: (json['budget'] ?? 0).toDouble(),
      interests: List<String>.from(json['interests'] ?? []),
      startDate: json['start_date'],
      endDate: json['end_date'],
    );
  }
}
