// lib/domain/entities/user.dart
class User {
  final String id;        // ← was int
  final String name;
  final String email;
  final String password;
  final String token;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.password,
    required this.token,
  });
}