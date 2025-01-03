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
  String? _email;
  String? _firstName;
  String? _lastName;
  String? _userType;
  bool _isInitialized = false;
  bool _isLoading = false;

  bool get isLoading => _isLoading;

  Future<bool> get isInitialized async {
    if (!_isInitialized) {
      await initializeAuth();
    }
    return _isInitialized;
  }

  bool isPremiumUser() {
    return _userType == 'PREMIUM';
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
      _firstName = await _storage.read(key: 'first_name');
      _lastName = await _storage.read(key: 'last_name');
      _userType = await _storage.read(key: 'user_type');
      
      print('Auth initialized - userId: $_userId, username: $_username, userType: $_userType');
      
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

  Future<String?> getFirstName() async {
    await isInitialized;
    return _firstName;
  }

  Future<String?> getLastName() async {
    await isInitialized;
    return _lastName;
  }

  Future<String?> getUserType() async {
    await isInitialized;
    return _userType;
  }

  Future<void> register({
    required String username,
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    required String userType,
  }) async {
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
          'firstName': firstName,
          'lastName': lastName,
          'userType': userType,
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
          _firstName = data['data']['firstName'];
          _lastName = data['data']['lastName'];
          _userType = data['data']['userType'];
          
          // Save user data
          await _storage.write(key: 'user_id', value: _userId);
          await _storage.write(key: 'auth_token', value: _token);
          await _storage.write(key: 'username', value: _username);
          await _storage.write(key: 'email', value: _email);
          await _storage.write(key: 'first_name', value: _firstName);
          await _storage.write(key: 'last_name', value: _lastName);
          await _storage.write(key: 'user_type', value: _userType);
          
          print('Login successful - userId: $_userId, username: $_username, userType: $_userType');

          _isInitialized = true;
          await initializeAuth(); // Reinitialize auth state
          
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

  Future<void> logout() async {
    try {
      _isLoading = true;
      notifyListeners();

      await _storage.deleteAll();
      
      _userId = null;
      _token = null;
      _username = null;
      _email = null;
      _firstName = null;
      _lastName = null;
      _userType = null;
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

  Future<bool> isPasswordValid(String password) async {
    bool hasMinLength = password.length >= 8;
    bool hasUppercase = password.contains(RegExp(r'[A-Z]'));
    bool hasLowercase = password.contains(RegExp(r'[a-z]'));
    bool hasNumber = password.contains(RegExp(r'[0-9]'));
    bool hasSpecialChar = password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'));

    return hasMinLength && hasUppercase && hasLowercase && hasNumber && hasSpecialChar;
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
          'Authorization': 'Bearer $_token',
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

  Future<void> changePassword(String currentPassword, String newPassword) async {
    try {
      final userId = await getCurrentUserId();
      if (userId == null) throw Exception('User not logged in');

      final response = await http.put(
        Uri.parse('${ApiConstants.baseUrl}/users/$userId/password'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'currentPassword': currentPassword,
          'newPassword': newPassword,
        }),
      );

      if (response.statusCode != 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        throw Exception(data['message'] ?? 'Failed to change password');
      }
    } catch (e) {
      throw Exception('Failed to change password: $e');
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

      final currentUserId = userId ?? await getCurrentUserId();
      if (currentUserId == null) {
        throw Exception('No user logged in');
      }

      final token = await getToken();
      if (token == null) {
        throw Exception('No auth token found');
      }

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
        if (data['firstName'] != null) {
          await _storage.write(key: 'first_name', value: data['firstName']);
          _firstName = data['firstName'];
        }
        if (data['lastName'] != null) {
          await _storage.write(key: 'last_name', value: data['lastName']);
          _lastName = data['lastName'];
        }
        if (data['userType'] != null) {
          await _storage.write(key: 'user_type', value: data['userType']);
          _userType = data['userType'];
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

  Future<void> updateUserType(String newUserType) async {
    try {
      final userId = await getCurrentUserId();
      if (userId == null) throw Exception('User not logged in');

      final response = await http.put(
        Uri.parse('${ApiConstants.baseUrl}/users/$userId/type'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'userType': newUserType}),
      );

      if (response.statusCode == 200) {
        // Update local storage
        await _storage.write(key: 'user_type', value: newUserType);
        _userType = newUserType;
        notifyListeners();
      } else {
        throw Exception('Failed to update user type: ${response.body}');
      }
    } catch (e) {
      print('Error updating user type: $e');
      rethrow;
    }
  }
}