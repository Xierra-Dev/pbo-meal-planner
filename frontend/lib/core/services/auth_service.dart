import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import '../constants/api_constants.dart';
import '../models/user.dart';
import 'package:dio/dio.dart';

class AuthService with ChangeNotifier {
  final _storage = const FlutterSecureStorage();
  String? _userId;
  String? _username;
  String? _email;
  String? _roleUser;
  String? _token;
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

      _userId = await _storage.read(key: 'user_id');
      _username = await _storage.read(key: 'username');
      _email = await _storage.read(key: 'email');
      _roleUser = await _storage.read(key: 'role_user');
      _token = await _storage.read(key: 'auth_token');
      
      print('Auth initialized - userId: $_userId, username: $_username, role: $_roleUser');
      
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
        Uri.parse('${ApiConstants.baseUrl}/api/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'email': email,
          'password': password,
        }),
      );

      final responseData = json.decode(response.body);
      
      if (response.statusCode == 200 && responseData['success'] == true) {
        final userData = responseData['data'];
        
        // Store user data
        _userId = userData['id'].toString();
        _username = userData['username'];
        _email = userData['email'];
        _roleUser = userData['roleUser'];
        _token = userData['token']; // Store token from response
        
        // Save to storage
        await _storage.write(key: 'user_id', value: _userId);
        await _storage.write(key: 'username', value: _username);
        await _storage.write(key: 'email', value: _email);
        await _storage.write(key: 'role_user', value: _roleUser);
        await _storage.write(key: 'auth_token', value: _token);
        
        _isInitialized = true;
        notifyListeners();
      } else {
        throw Exception(responseData['message'] ?? 'Login failed');
      }
    } catch (e) {
      print('Login error: $e');
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> register(String username, String email, String password, String roleUser) async {
    try {
        _isLoading = true;
        notifyListeners();

        final response = await http.post(
            Uri.parse('${ApiConstants.baseUrl}/api/auth/register'),
            headers: {'Content-Type': 'application/json'},
            body: json.encode({
                'username': username,
                'email': email,
                'password': password,
                'accountType': roleUser, // Add account type to request
            }),
        );

      final responseData = json.decode(response.body);
      
      if (response.statusCode == 200 && responseData['success'] == true) {
        final userData = responseData['data'];
        
        // Store user data
        _userId = userData['id'].toString();
        _username = userData['username'];
        _email = userData['email'];
        _roleUser = userData['roleUser'];
        _token = userData['token']; // Store token from response
        
        // Save to storage
        await _storage.write(key: 'user_id', value: _userId);
        await _storage.write(key: 'username', value: _username);
        await _storage.write(key: 'email', value: _email);
        await _storage.write(key: 'role_user', value: _roleUser);
        await _storage.write(key: 'auth_token', value: _token);
        
        _isInitialized = true;
        notifyListeners();
      } else {
        throw Exception(responseData['message'] ?? 'Registration failed');
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
      _username = null;
      _email = null;
      _roleUser = null;
      _token = null;
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

  Future<void> deleteAccount(String password) async {
    try {
      _isLoading = true;
      notifyListeners();

      final userId = await getCurrentUserId();
      if (userId == null) throw Exception('User ID not found');

      final response = await http.delete(
        Uri.parse('${ApiConstants.baseUrl}/users/$userId'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode({'password': password}),
      );

      if (response.statusCode == 200) {
        await logout(); // Clear local auth data
      } else {
        final error = json.decode(response.body);
        throw Exception(error['message'] ?? 'Failed to delete account');
      }
    } catch (e) {
      print('Delete account error: $e');
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
  try {
    final userId = await getCurrentUserId();
    final token = await getToken();
    
    if (userId == null || token == null) {
      throw Exception('User not authenticated');
    }
    
    final response = await http.put(
      Uri.parse('${ApiConstants.baseUrl}/api/users/$userId/profile'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: json.encode(profileData),
    );
    
    if (response.statusCode != 200) {
      final errorData = json.decode(response.body);
      throw Exception(errorData['message'] ?? 'Failed to update profile');
    }
    
    // Update local storage with new profile data
    final responseData = json.decode(response.body);
    if (responseData['success'] == true && responseData['data'] != null) {
      final userData = responseData['data'];
      if (userData['username'] != null) {
        await _storage.write(key: 'username', value: userData['username']);
        _username = userData['username'];
      }
      notifyListeners();
    }
  } catch (e) {
    print('Update profile error: $e');
    rethrow;
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

      final url = Uri.parse('${ApiConstants.baseUrl}/api/users/$currentUserId/profile');
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      print('Profile Response: ${response.body}');

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        
        if (responseData['success'] == true && responseData['data'] != null) {
          final userData = responseData['data'];
          
          // Update stored user data
          if (userData['email'] != null) {
            await _storage.write(key: 'email', value: userData['email']);
            _email = userData['email'];
          }
          if (userData['username'] != null) {
            await _storage.write(key: 'username', value: userData['username']);
            _username = userData['username'];
          }

          notifyListeners();
          return userData;
        } else {
          throw Exception(responseData['message'] ?? 'Failed to get profile data');
        }
      } else {
        final errorData = json.decode(response.body);
        throw Exception(errorData['message'] ?? 'Failed to get profile data');
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