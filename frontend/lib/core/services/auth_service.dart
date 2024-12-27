import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import '../constants/api_constants.dart';

class AuthService with ChangeNotifier {
  final _storage = const FlutterSecureStorage();
  String? _userId;
  String? _token;
  String? _username;
  bool _isInitialized = false;
  bool _isLoading = false;

  bool get isLoading => _isLoading;

  Future<bool> get isInitialized async {
    if (!_isInitialized) {
      await initializeAuth();
    }
    return _isInitialized;
  }

  Future<void> initializeAuth() async {
    if (_isInitialized) return;
    
    try {
      _isLoading = true;
      notifyListeners();

      // Load stored credentials
      _userId = await _storage.read(key: 'user_id');
      _token = await _storage.read(key: 'auth_token');
      _username = await _storage.read(key: 'username');
      
      print('Auth initialized - userId: $_userId, username: $_username');
      
      _isInitialized = true;
    } catch (e) {
      print('Error initializing auth: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> isLoggedIn() async {
    await isInitialized;
    return _userId != null && _token != null;
  }

  Future<String?> getCurrentUserId() async {
    await isInitialized;
    return _userId;
  }

  Future<String?> getToken() async {
    await isInitialized;
    return _token;
  }

  Future<String?> getUsername() async {
    await isInitialized;
    return _username;
  }

  Future<void> login(String email, String password) async {
    try {
      _isLoading = true;
      notifyListeners();

      final response = await http.post(
        Uri.parse('${ApiConstants.baseUrl}/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'email': email,
          'password': password,
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        if (data['data'] != null) {
          _userId = data['data']['userId'].toString();
          _token = data['data']['token'] ?? _userId;
          _username = data['data']['username'];
          
          // Save user data
          await _storage.write(key: 'user_id', value: _userId);
          await _storage.write(key: 'auth_token', value: _token);
          await _storage.write(key: 'username', value: _username);
          
          print('Login successful - userId: $_userId, username: $_username');
          
          notifyListeners();
        } else {
          throw Exception('Invalid response data');
        }
      } else {
        final error = json.decode(response.body);
        throw Exception(error['message'] ?? 'Login failed');
      }
    } catch (e) {
      print('Login error: $e');
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> register(String username, String email, String password) async {
    try {
      _isLoading = true;
      notifyListeners();

      final response = await http.post(
        Uri.parse('${ApiConstants.baseUrl}/auth/register'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'username': username,
          'email': email,
          'password': password,
        }),
      );

      if (response.statusCode != 200) {
        final error = json.decode(response.body);
        throw Exception(error['message'] ?? 'Registration failed');
      }
    } catch (e) {
      print('Registration error: $e');
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    try {
      _isLoading = true;
      notifyListeners();

      await _storage.deleteAll();
      
      _userId = null;
      _token = null;
      _username = null;
      _isInitialized = false;
      
      print('Logout successful');
      
      notifyListeners();
    } catch (e) {
      print('Logout error: $e');
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> resetPassword(String email) async {
    try {
      _isLoading = true;
      notifyListeners();

      final response = await http.post(
        Uri.parse('${ApiConstants.baseUrl}/auth/reset-password'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'email': email}),
      );

      if (response.statusCode != 200) {
        final error = json.decode(response.body);
        throw Exception(error['message'] ?? 'Password reset failed');
      }
    } catch (e) {
      print('Password reset error: $e');
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}