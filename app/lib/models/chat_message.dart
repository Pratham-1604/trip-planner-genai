import 'package:google_frontend/models/itinerary.dart';

enum MessageType {
  user,
  assistant,
  system,
}

class ChatMessage {
  final String content;
  final MessageType type;
  final DateTime timestamp;
  final Itinerary? itinerary;

  ChatMessage({
    required this.content,
    required this.type,
    required this.timestamp,
    this.itinerary,
  });

  Map<String, dynamic> toJson() {
    return {
      'content': content,
      'type': type.name,
      'timestamp': timestamp.toIso8601String(),
      'itinerary': itinerary?.toJson(),
    };
  }

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      content: json['content'] ?? '',
      type: MessageType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => MessageType.user,
      ),
      timestamp: DateTime.parse(json['timestamp']),
      itinerary: json['itinerary'] != null 
          ? Itinerary.fromJson(json['itinerary'])
          : null,
    );
  }
}
