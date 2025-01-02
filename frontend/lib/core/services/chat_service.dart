import 'package:dio/dio.dart';
import '../models/chat_message.dart';

class ChatService {
  final Dio _dio;
  final String baseUrl = 'http://localhost:8080/api/assistant';

  ChatService() : _dio = Dio() {
    _dio.options.headers['Content-Type'] = 'application/json';
    _dio.options.connectTimeout = const Duration(seconds: 30); // Increased timeout
    _dio.options.receiveTimeout = const Duration(seconds: 30);
    
    _dio.interceptors.add(LogInterceptor(
      requestBody: true,
      responseBody: true,
      error: true,
    ));
  }

  Future<ChatMessage> sendMessage(int userId, String message) async {
    try {
      if (userId <= 0) {
        throw Exception('Invalid userId');
      }

      // Create user message
      final userMessage = ChatMessage(
        id: DateTime.now().toIso8601String(),
        userId: userId,
        message: message,
        response: '',
        timestamp: DateTime.now(),
        isUser: true,
      );

      final response = await _dio.post(
        baseUrl,
        data: {
          'userId': userId,
          'message': message,
        },
      );

      if (response.statusCode == 200) {
        // Create assistant message from response
        return ChatMessage(
          id: response.data['id'].toString(),
          userId: userId,
          message: message,
          response: response.data['response'] ?? '',
          timestamp: DateTime.parse(response.data['timestamp']),
          isUser: false,
        );
      } else {
        throw Exception('Server returned ${response.statusCode}');
      }
    } catch (e) {
      print('Error sending message: $e');
      rethrow;
    }
  }

  Future<List<ChatMessage>> getChatHistory(int userId) async {
    try {
      if (userId <= 0) {
        throw Exception('Invalid userId');
      }

      final response = await _dio.get('$baseUrl/history/$userId');
      
      if (response.statusCode == 200 && response.data != null) {
        final List<dynamic> historyData = response.data as List<dynamic>;
        
        // Convert each message to both user message and assistant response
        List<ChatMessage> messages = [];
        for (var item in historyData) {
          // Add user message
          messages.add(ChatMessage(
            id: '${item['id']}_user',
            userId: userId,
            message: item['message'],
            response: '',
            timestamp: DateTime.parse(item['timestamp']),
            isUser: true,
          ));
          
          // Add assistant response
          messages.add(ChatMessage(
            id: item['id'].toString(),
            userId: userId,
            message: '',
            response: item['response'],
            timestamp: DateTime.parse(item['timestamp']),
            isUser: false,
          ));
        }
        
        // Sort messages by timestamp
        messages.sort((a, b) => a.timestamp.compareTo(b.timestamp));
        return messages;
      } else {
        throw Exception('Invalid response from server');
      }
    } catch (e) {
      print('Error getting chat history: $e');
      rethrow;
    }
  }
}

