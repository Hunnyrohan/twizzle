import '../../domain/entities/user.dart';

class UserModel extends User {
  UserModel({
    required String id,
    required String name,
    required String email,
    required String password,
    required String token,
  }) : super(
         id: id,
         name: name,
         email: email,
         password: password,
         token: token,
       );

  /// ✅ CORRECT JSON PARSING
  factory UserModel.fromJson(Map<String, dynamic> json, String password) {
    return UserModel(
      id: json['id'] as String, // ✅ FIXED
      name: json['name'] as String, // ✅ FIXED
      email: json['email'] as String, // ✅ FIXED
      password: password,
      token: '', // token is cookie-based
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name, 'email': email, 'token': token};
  }
}
