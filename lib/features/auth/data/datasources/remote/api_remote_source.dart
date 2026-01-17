// lib/data/datasources/remote/api_remote_source.dart
import 'package:twizzle/core/api/dio_client.dart';

class ApiRemoteSource {
  final DioClient _client = DioClient();

  Future<Map<String, dynamic>> register(
      String name, String email, String password) =>
      _client.register(name: name, email: email, password: password);

  Future<Map<String, dynamic>> login(String email, String password) =>
      _client.login(email: email, password: password);
}