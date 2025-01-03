import 'package:dio/dio.dart';

Dio createDio() {
  final dio = Dio();
  
  dio.options.baseUrl = 'http://localhost:8080';
  dio.options.headers = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };
  
  return dio;
}