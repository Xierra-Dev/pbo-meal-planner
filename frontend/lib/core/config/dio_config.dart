import 'package:dio/dio.dart';

Dio createDio() {
  final dio = Dio();
  const bool allowCredentials = false; // Add this line
  
  dio.options.baseUrl = 'http://localhost:8080';
  dio.options.headers = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };
  
  if (allowCredentials) {  // Remove '== true' since it's redundant
    dio.options.validateStatus = (status) {
      return status! < 500;
    };
  }
  
  return dio;
}