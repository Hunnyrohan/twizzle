// lib/data/models/user_model.dart
import '../../domain/entities/user.dart';

class UserModel extends User {
  UserModel({required super.name, required super.email, required super.password});

  factory UserModel.fromJson(Map<String, dynamic> json) =>
      UserModel(name: json['name'], email: json['email'], password: json['password']);

  Map<String, dynamic> toJson() => {'name': name, 'email': email, 'password': password};
}