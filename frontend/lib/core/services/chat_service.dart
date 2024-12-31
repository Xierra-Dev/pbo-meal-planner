import 'package:dio/dio.dart';
import '../models/chat_message.dart';

class ChatService {
  final Dio _dio;
  final String baseUrl = 'http://localhost:8080/api/assistant';

  ChatService() : _dio = Dio() {
    _dio.options.headers['Content-Type'] = 'application/json';
    _dio.options.connectTimeout = const Duration(seconds: 5);
    _dio.options.receiveTimeout = const Duration(seconds: 3);
    
    // Add interceptor for logging
    _dio.interceptors.add(LogInterceptor(
      requestBody: true,
      responseBody: true,
      error: true,
    ));
  }

  Future<ChatMessage> sendMessage(String userId, String message) async {
    try {
      final response = await _dio.post(
        baseUrl,
        data: {
          'userId': userId,
          'message': message,
        },
      );

      if (response.statusCode == 200) {
        return ChatMessage(
          id: response.data['id'].toString(),
          userId: response.data['userId'],
          message: response.data['message'],
          response: response.data['response'],
          timestamp: DateTime.parse(response.data['timestamp']),
          isUser: false,
        );
      } else {
        throw Exception('Server returned ${response.statusCode}');
      }
    } on DioException catch (e) {
      print('Dio error: ${e.message}');
      if (e.type == DioExceptionType.connectionTimeout) {
        throw Exception('Connection timed out');
      }
      throw Exception('Network error: ${e.message}');
    } catch (e) {
      print('Error sending message: $e');
      throw Exception('Failed to send message: $e');
    }
  }

  Future<List<ChatMessage>> getChatHistory(String userId) async {
    try {
      print('Fetching chat history for user: $userId');
      final response = await _dio.get('$baseUrl/history/$userId');
      
      print('Response status: ${response.statusCode}');
      print('Response data: ${response.data}');

      if (response.statusCode == 200 && response.data != null) {
        final List<dynamic> historyData = response.data as List<dynamic>;
        
        return historyData.map((json) {
          return ChatMessage(
            id: json['id'].toString(),
            userId: json['userId'] ?? '',
            message: json['message'] ?? '',
            response: json['response'] ?? '',
            timestamp: DateTime.parse(json['timestamp']),
            isUser: false,
          );
        }).toList();
      } else {
        throw Exception('Invalid response from server');
      }
    } catch (e) {
      print('Error getting chat history: $e');
      rethrow;
    }
  }
}