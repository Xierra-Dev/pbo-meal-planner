import 'package:dio/dio.dart';
import '../models/user_preferences.dart';

class PreferencesService {
  final Dio _dio;
  final String userId;

  PreferencesService(this._dio, this.userId);

  Future<void> savePreferences(UserPreferences preferences) async {
    print('Sending preferences to backend...'); // Debug print
    print('User ID: $userId'); // Debug print
    print('Preferences data: ${preferences.toJson()}'); // Debug print
    
    try {
      final response = await _dio.put(
        '/api/preferences/$userId',
        data: preferences.toJson(),
      );
      
      print('Response from backend: ${response.data}'); // Debug print
    } catch (e) {
      print('Error in savePreferences: $e'); // Debug print
      rethrow;
    }
  }

  Future<UserPreferences> getPreferences() async {
    try {
      print('Attempting to get preferences for user $userId');

      final response = await _dio.get('/api/preferences/$userId');

      print('Response status: ${response.statusCode}');
      print('Response data: ${response.data}');

      return UserPreferences.fromJson(response.data);
    } catch (e) {
      print('Error getting preferences: $e');
      rethrow;
    }
  }
}