import 'package:dio/dio.dart';

Dio createDio() {
  final dio = Dio();
  const bool allowCredentials = false; // Add this line
  
  dio.options.baseUrl = 'http://localhost:8080';
  dio.options.headers = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };
  return dio;
}