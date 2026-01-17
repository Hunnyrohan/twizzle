// lib/core/api/dio_client.dart
import 'package:dio/dio.dart';

class DioClient {
  // ANDROID EMULATOR → LOCAL BACKEND
  // lib/core/api/dio_client.dart
static const String _baseUrl = 'http://10.0.2.2:5000/api/auth';

  static final Dio _dio = Dio()
    ..options.baseUrl = _baseUrl
    ..options.connectTimeout = const Duration(seconds: 10)
    ..options.receiveTimeout = const Duration(seconds: 10)
    ..interceptors.add(LogInterceptor(requestBody: true, responseBody: true));

  // REGISTER
  Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String password,
  }) async {
    final res = await _dio.post('/register', data: {
      'name': name,
      'email': email,
      'password': password,
    });
    return res.data;
  }

  // LOGIN
  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    final res = await _dio.post('/login', data: {
      'email': email,
      'password': password,
    });
    return res.data;
  }
}
