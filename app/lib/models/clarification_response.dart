class ClarificationResponse {
  final String message;
  final String resp;
  final bool needsClarification;

  ClarificationResponse({
    required this.message,
    required this.resp,
    required this.needsClarification,
  });

  factory ClarificationResponse.fromJson(Map<String, dynamic> json) {
    return ClarificationResponse(
      message: json['message'] ?? '',
      resp: json['resp'] ?? '',
      needsClarification: json['message'] == 'Need clarification',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'message': message,
      'resp': resp,
      'needsClarification': needsClarification,
    };
  }
}
