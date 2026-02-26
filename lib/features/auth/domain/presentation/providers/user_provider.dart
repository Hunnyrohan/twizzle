// lib/features/auth/presentation/providers/user_provider.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:twizzle/features/auth/domain/entities/user.dart';
import 'package:twizzle/features/auth/data/models/user_model.dart';
import 'package:twizzle/features/auth/domain/repositories/user_repository.dart';
import 'package:twizzle/features/auth/domain/usecases/login_user.dart';
import 'package:twizzle/features/auth/domain/usecases/register_user.dart';

class UserProvider with ChangeNotifier {
  final RegisterUser register;
  final LoginUser login;
  final UserRepository repo;

  final GoogleSignIn _googleSignIn = GoogleSignIn(
    serverClientId: '789369635164-tt45901f8almobm2l19l7d344u3mmnt5.apps.googleusercontent.com',
    scopes: ['email', 'profile'],
  );

  UserProvider({required this.register, required this.login, required this.repo});

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  User? _user;
  User? get user => _user;

  String _error = '';
  String get error => _error;

  Future<bool> registerUser(User u) async {
    _isLoading = true; notifyListeners();
    final res = await register(u);
    _isLoading = false; notifyListeners();
    return res.fold((fail) {
      _error = fail.message;
      return false;
    }, (_) => true);
  }

  Future<bool> loginUser(String email, String password) async {
    _isLoading = true; notifyListeners();
    final res = await login(email, password);
    _isLoading = false; notifyListeners();
    return res.fold((fail) {
      _error = fail.message;
      return false;
    }, (u) {
      _user = u;
      return true;
    });
  }

  Future<bool> loginWithGoogle() async {
    _isLoading = true;
    notifyListeners();

    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        _isLoading = false;
        notifyListeners();
        return false;
      }

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final String? idToken = googleAuth.idToken;

      if (idToken == null) {
        _error = 'Google authentication failed: Missing ID Token';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      final res = await repo.googleLogin(idToken);
      _isLoading = false;
      notifyListeners();

      return res.fold((fail) {
        _error = fail.message;
        return false;
      }, (u) {
        _user = u;
        return true;
      });
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    await repo.logout();
    await _googleSignIn.signOut();
    _user = null;
    notifyListeners();
  }

  Future<bool> checkLoggedIn() async {
    final res = await repo.getCurrentUser();
    return res.fold((_) => false, (u) {
      _user = u;
      notifyListeners();
      return u != null;
    });
  }

  Future<void> refreshUserStatus() async {
    final res = await repo.getCurrentUser();
    res.fold((_) => null, (u) {
      _user = u;
      notifyListeners();
    });
  }


  Future<String?> forgotPassword(String email) async {
    _isLoading = true; notifyListeners();
    final res = await repo.forgotPassword(email);
    _isLoading = false; notifyListeners();
    return res.fold((fail) {
      _error = fail.message;
      return null;
    }, (msg) => msg);
  }

  Future<bool> resetPassword(String code, String newPassword) async {
    _isLoading = true; notifyListeners();
    final res = await repo.resetPassword(code, newPassword);
    _isLoading = false; notifyListeners();
    return res.fold((fail) {
      _error = fail.message;
      return false;
    }, (_) => true);
  }

  Future<bool> updateProfile({String? name, String? bio, String? location, String? website}) async {
    _isLoading = true; notifyListeners();
    final res = await repo.updateProfile(name: name, bio: bio, location: location, website: website);
    _isLoading = false;
    return res.fold((fail) {
      _error = fail.message;
      notifyListeners();
      return false;
    }, (u) {
      _user = u;
      notifyListeners();
      return true;
    });
  }

  Future<bool> uploadAvatar(File image) async {
    _isLoading = true; notifyListeners();
    final res = await repo.uploadAvatar(image);
    _isLoading = false;
    return res.fold((fail) {
      _error = fail.message;
      notifyListeners();
      return false;
    }, (url) {
      if (_user != null) {
        _user = (_user as UserModel).copyWith(image: url);
      }
      notifyListeners();
      return true;
    });
  }

  Future<bool> uploadCover(File image) async {
    _isLoading = true; notifyListeners();
    final res = await repo.uploadCover(image);
    _isLoading = false;
    return res.fold((fail) {
      _error = fail.message;
      notifyListeners();
      return false;
    }, (url) {
      if (_user != null) {
        _user = (_user as UserModel).copyWith(coverImage: url);
      }
      notifyListeners();
      return true;
    });
  }
}