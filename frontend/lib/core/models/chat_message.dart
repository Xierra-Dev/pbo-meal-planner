class ChatMessage {
  final String id;
  final String userId;
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
}