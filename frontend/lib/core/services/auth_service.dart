import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import '../constants/api_constants.dart';
import '../models/user.dart';

class AuthService with ChangeNotifier {
  final _storage = const FlutterSecureStorage();
  String? _userId;
  String? _token;
  String? _username;
  String? _email;
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
      _email = await _storage.read(key: 'email');
      
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

  Future<String?> getEmail() async {
    await isInitialized;
    return _email;
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
          _email = data['data']['email'];
          
          // Save user data
          await _storage.write(key: 'user_id', value: _userId);
          await _storage.write(key: 'auth_token', value: _token);
          await _storage.write(key: 'username', value: _username);
          await _storage.write(key: 'email', value: _email);
          
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
      _email = null;
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

  Future<void> updateProfile(Map<String, dynamic> profileData) async {
    final userId = await getCurrentUserId();
    final currentEmail = await getEmail(); // Tambahkan method untuk get email
    
    // Tambahkan email ke profileData
    profileData['email'] = currentEmail;
    
    final response = await http.put(
      Uri.parse('${ApiConstants.baseUrl}/users/$userId/profile'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(profileData),
    );
    
    if (response.statusCode != 200) {
      throw Exception('Failed to update profile');
    }
  }

  Future<Map<String, dynamic>> getUserProfile([String? userId]) async {
    try {
      _isLoading = true;
      notifyListeners();

      // Get current user ID if not provided
      final currentUserId = userId ?? await getCurrentUserId();
      if (currentUserId == null) {
        throw Exception('No user logged in');
      }

      // Get auth token
      final token = await getToken();
      if (token == null) {
        throw Exception('No auth token found');
      }

      // Make API request
      final response = await http.get(
        Uri.parse('${ApiConstants.baseUrl}/users/$currentUserId/profile'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        // Update stored user data
        if (data['email'] != null) {
          await _storage.write(key: 'email', value: data['email']);
          _email = data['email'];
        }
        if (data['username'] != null) {
          await _storage.write(key: 'username', value: data['username']);
          _username = data['username'];
        }

        notifyListeners();
        return data;
      } else {
        final error = json.decode(response.body);
        throw Exception(error['message'] ?? 'Failed to get user profile');
      }
    } catch (e) {
      print('Error getting user profile: $e');
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}