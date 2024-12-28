import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../constants/api_constants.dart';
import 'package:dio/dio.dart';

class ApiService {
  final storage = const FlutterSecureStorage();
  final _dio = Dio();  // Add this line
  final _baseUrl = ApiConstants.baseUrl;

  Future<String?> getToken() async {
    return await storage.read(key: 'auth_token');
  }

  Future<Map<String, String>> getHeaders() async {
    final token = await getToken();
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  Future<dynamic> get(String endpoint) async {
    final headers = await getHeaders();
    final response = await http.get(
      Uri.parse('${ApiConstants.baseUrl}/$endpoint'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load data');
    }
  }

  Future<dynamic> post(String endpoint, dynamic data) async {
    final headers = await getHeaders();
    final response = await http.post(
      Uri.parse('${ApiConstants.baseUrl}/$endpoint'),
      headers: headers,
      body: json.encode(data),
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to post data');
    }
  }

  Future<Map<String, dynamic>?> patch(String endpoint, Map<String, dynamic> data) async {
    try {
      final response = await _dio.patch('$_baseUrl/$endpoint', data: data);
      return response.data;
    } catch (e) {
      print('PATCH request error: $e');
      return null;
    }
  }

  Future<dynamic> delete(String endpoint) async {
    final headers = await getHeaders();
    final response = await http.delete(
      Uri.parse('${ApiConstants.baseUrl}/$endpoint'),
      headers: headers,
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to delete data');
    }
  }
}