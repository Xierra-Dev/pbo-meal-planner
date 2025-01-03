import 'dart:convert';
import 'package:http/http.dart' as http;
import '../constants/api_constants.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AdminService {
  static const String baseUrl = ApiConstants.baseUrl;

  Future<bool> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/admin/login'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'email': email,
          'password': password,
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['success'] ?? false;
      }
      return false;
    } catch (e) {
      throw Exception('Failed to login: $e');
    }
  }

  Future<List<Map<String, dynamic>>> getAllUsers() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/admin/users'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.cast<Map<String, dynamic>>();
      } else {
        throw Exception('Failed to load users');
      }
    } catch (e) {
      throw Exception('Failed to load users: $e');
    }
  }

    Future<Map<String, dynamic>> updateUser(String userId, Map<String, dynamic> userData) async {
    try {
      print('UserID: $userId'); // Debug print
      
      final Map<String, dynamic> requestData = {
        'username': userData['username'],
        'email': userData['email'],
        'firstName': userData['firstName'] ?? '',
        'lastName': userData['lastName'] ?? '',
        'userType': userData['userType']
      };

      print('Request data: $requestData'); // Debug print

      final response = await http.put(
        Uri.parse('$baseUrl/admin/users/$userId'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(requestData)
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        print('Error response: ${response.body}'); // Debug print
        throw Exception(json.decode(response.body)['message']);
      }
    } catch (e) {
      throw Exception('Failed to update user: $e');
    }
  }

  Future<void> deleteUser(String userId) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/admin/users/$userId'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to delete user');
      }
    } catch (e) {
      throw Exception('Failed to delete user: $e');
    }
  }

  Future<bool> checkAdminSession() async {
    // Get stored admin credentials from secure storage or shared preferences
    // For now, return a simple check
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('isAdminLoggedIn') ?? false;
  }
}