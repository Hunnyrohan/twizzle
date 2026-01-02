// lib/domain/entities/user.dart
class User {
  final String name;
  final String email;
  final String password; // plain for demo; hash in prod
  User({required this.name, required this.email, required this.password});
}