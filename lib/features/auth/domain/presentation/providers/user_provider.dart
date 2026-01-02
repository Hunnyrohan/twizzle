// lib/presentation/providers/user_provider.dart
import 'package:flutter/material.dart';
import 'package:dartz/dartz.dart';
import 'package:twizzle/features/auth/domain/entities/user.dart';
import 'package:twizzle/features/auth/domain/repositories/user_repository.dart';
import 'package:twizzle/features/auth/domain/usecases/login_user.dart';
import 'package:twizzle/features/auth/domain/usecases/register_user.dart';


class UserProvider with ChangeNotifier {
  final RegisterUser register;
  final LoginUser login;
  final UserRepository repo;

  UserProvider({required this.register, required this.login, required this.repo});

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  User? _user;
  User? get user => _user;

  String _error = '';
  String get error => _error;

  Future<bool> registerUser(User u) async {
    _isLoading = true;
    notifyListeners();
    final res = await register(u);
    _isLoading = false;
    notifyListeners();
    return res.fold((fail) {
      _error = 'Registration failed';
      return false;
    }, (_) => true);
  }

  Future<bool> loginUser(String email, String pass) async {
    _isLoading = true;
    notifyListeners();
    final res = await login(email, pass);
    _isLoading = false;
    notifyListeners();
    return res.fold((fail) {
      _error = 'Login failed';
      return false;
    }, (u) {
      _user = u;
      return u != null;
    });
  }

  Future<bool> checkLoggedIn() async {
    final res = await repo.getCurrentUser();
    return res.fold((_) => false, (u) {
      _user = u;
      return u != null;
    });
  }
}