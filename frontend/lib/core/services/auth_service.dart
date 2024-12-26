import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import '../constants/api_constants.dart';

class AuthService extends ChangeNotifier {
  final _storage = const FlutterSecureStorage();
  String? _userId;
  String? _token;
  bool _isInitialized = false;

  AuthService() {
    initializeAuth();
  }

  Future<void> initializeAuth() async {
    if (_isInitialized) return;
    
    try {
      _userId = await _storage.read(key: 'user_id');
      _token = await _storage.read(key: 'auth_token');
      print('Auth initialized - userId: $_userId, hasToken: ${_token != null}');
      _isInitialized = true;
      notifyListeners();
    } catch (e) {
      print('Error initializing auth: $e');
      rethrow;
    }
  }

  Future<String?> getCurrentUserId() async {
    if (!_isInitialized) {
      await initializeAuth();
    }
    print('Getting current userId: $_userId');
    return _userId;
  }

  Future<String?> getToken() async {
    if (!_isInitialized) {
      await initializeAuth();
    }
    return _token;
  }

  Future<void> login(String email, String password) async {
    try {
      print('Attempting login for email: $email');
      final response = await http.post(
        Uri.parse('${ApiConstants.baseUrl}/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'email': email,
          'password': password,
        }),
      );

      print('Login response status: ${response.statusCode}');
      print('Login response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        // Pastikan data['data'] ada dan memiliki userId
        if (data['data'] != null && data['data']['userId'] != null) {
          _userId = data['data']['userId'].toString();
          _token = _userId; // Menggunakan userId sebagai token
          
          print('Login successful - userId: $_userId');
          
          // Simpan ke secure storage
          await _storage.write(key: 'user_id', value: _userId);
          await _storage.write(key: 'auth_token', value: _token);
          
          _isInitialized = true;
          notifyListeners();
        } else {
          throw Exception('Invalid login response format');
        }
      } else {
        final error = json.decode(response.body);
        throw Exception(error['message'] ?? 'Login failed');
      }
    } catch (e) {
      print('Login error: $e');
      throw Exception('Login failed: $e');
    }
  }

  Future<void> register(String username, String email, String password) async {
    try {
      print('Attempting registration for username: $username, email: $email');
      final response = await http.post(
        Uri.parse('${ApiConstants.baseUrl}/auth/register'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'username': username,
          'email': email,
          'password': password,
        }),
      );

      print('Register response status: ${response.statusCode}');
      print('Register response body: ${response.body}');

      if (response.statusCode != 200) {
        final error = json.decode(response.body);
        throw Exception(error['message'] ?? 'Registration failed');
      }
    } catch (e) {
      print('Registration error: $e');
      throw Exception('Registration failed: $e');
    }
  }

  Future<void> logout() async {
    try {
      print('Logging out...');
      _userId = null;
      _token = null;
      _isInitialized = false;
      await _storage.deleteAll();
      notifyListeners();
      print('Logout successful');
    } catch (e) {
      print('Logout error: $e');
      throw Exception('Logout failed: $e');
    }
  }

  Future<bool> isLoggedIn() async {
    if (!_isInitialized) {
      await initializeAuth();
    }
    final hasUserId = _userId != null;
    print('Checking login state - hasUserId: $hasUserId');
    return hasUserId;
  }
}