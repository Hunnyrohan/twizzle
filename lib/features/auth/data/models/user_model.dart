// lib/data/models/user_model.dart
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

  factory UserModel.fromJson(Map<String, dynamic> json, String password) =>
      UserModel(
        id: json['user']['id']?.toString() ?? '', // string from server
        name: json['user']['name'] ?? '',
        email: json['user']['email'] ?? '',
        password: password,
        token: json['token'] ?? '',
      );

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'email': email,
    'password': password,
    'token': token,
  };
}
