class ChatMessage {
  final String id;
  final int userId;
  final String message;
  final String response;
  final DateTime timestamp;
  final bool isUser;

  ChatMessage({
    required this.id,
    required this.userId,
    required this.message,
    required this.response,
    required this.timestamp,
    required this.isUser,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      id: json['id'].toString(),
      userId: json['userId'] as int,
      message: json['message'] as String, 
      response: json['response'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      // Set isUser based on whether this is a user message
      isUser: json['isUser'] ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'userId': userId,
    'message': message,
    'response': response,
    'timestamp': timestamp.toIso8601String(),
    'isUser': isUser,
  };
}