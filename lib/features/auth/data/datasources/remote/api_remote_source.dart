import 'package:twizzle/core/api/dio_client.dart';

class ApiRemoteSource {
  final DioClient _client = DioClient();

  // ✅ REGISTER (MATCHES BACKEND)
  Future<Map<String, dynamic>> register(
    String name, // ✅ renamed
    String email,
    String password,
  ) {
    return _client.register(
      name: name, // ✅ MUST be name
      email: email,
      password: password,
    );
  }

  // ✅ LOGIN (ALREADY CORRECT)
  Future<Map<String, dynamic>> login(String email, String password) {
    return _client.login(email: email, password: password);
  }
}
