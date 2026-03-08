// lib/features/auth/presentation/providers/user_provider.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:twizzle/features/auth/domain/entities/user.dart';
import 'package:twizzle/features/auth/data/models/user_model.dart';
import 'package:twizzle/features/auth/domain/repositories/user_repository.dart';
import 'package:twizzle/features/auth/domain/usecases/login_user.dart';
import 'package:twizzle/features/auth/domain/usecases/register_user.dart';
import 'package:twizzle/features/auth/domain/usecases/get_blocks.dart';
import 'package:twizzle/core/error/failures.dart';
import 'package:dartz/dartz.dart';

class UserProvider with ChangeNotifier {
  final RegisterUser register;
  final LoginUser login;
  final GetBlocks getBlocksUseCase;
  final UserRepository repo;
  final GoogleSignIn _googleSignIn;

  UserProvider({
    required this.register,
    required this.login,
    required this.getBlocksUseCase,
    required this.repo,
    GoogleSignIn? googleSignIn,
  }) : _googleSignIn = googleSignIn ?? GoogleSignIn(
    // Android Client ID from new Project (96306786076)
    clientId: '96306786076-l0qqnj576hqrbi0nh95oo2nj5q6v1qm5.apps.googleusercontent.com', 
    // Web Client ID (Web SDK) from new Project
    serverClientId: '96306786076-4oq11o1ea1r4vsitbl509h1mc1912i43.apps.googleusercontent.com',
    scopes: ['email', 'profile'],
  );

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  User? _user;
  User? get user => _user;

  bool _needsReactivation = false;
  bool get needsReactivation => _needsReactivation;

  String _error = '';
  String get error => _error;

  List<User> _blockedUsers = [];
  List<User> get blockedUsers => _blockedUsers;

  Future<bool> registerUser(User u) async {
    _isLoading = true; notifyListeners();
    final res = await register(u);
    _isLoading = false; notifyListeners();
    return res.fold((fail) {
      _error = fail.message;
      return false;
    }, (_) => true);
  }

  Future<bool> loginUser(String email, String password, {bool confirmReactivate = false}) async {
    _isLoading = true; 
    _needsReactivation = false;
    notifyListeners();
    
    final res = await login(email, password, confirmReactivate: confirmReactivate);
    _isLoading = false; 
    
    return res.fold((fail) {
      _error = fail.message;
      if (fail is DeactivatedAccountFailure) {
        _needsReactivation = true;
      }
      notifyListeners();
      return false;
    }, (u) {
      _user = u;
      notifyListeners();
      return true;
    });
  }

  Future<bool> reactivateAccount() async {
    _isLoading = true; notifyListeners();
    final res = await repo.loginUser('', '', confirmReactivate: true); 
    _isLoading = false;
    return res.fold((fail) {
      _error = fail.message;
      notifyListeners();
      return false;
    }, (_) {
      _needsReactivation = false;
      notifyListeners();
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
    return res.fold((fail) {
      _error = fail.message;
      notifyListeners();
      return false;
    }, (u) {
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

  Future<void> getBlockedUsers() async {
    _isLoading = true;
    notifyListeners();
    final res = await getBlocksUseCase();
    _isLoading = false;
    res.fold(
      (fail) => _error = fail.message,
      (users) => _blockedUsers = users,
    );
    notifyListeners();
  }

  Future<bool> toggleBlock(String userId) async {
    final res = await repo.toggleBlock(userId);
    return res.fold(
      (fail) {
        _error = fail.message;
        notifyListeners();
        return false;
      },
      (_) {
        // Refresh local block list if we're in the BlockedAccountsScreen context
        _blockedUsers.removeWhere((u) => u.id == userId);
        notifyListeners();
        return true;
      },
    );
  }

  Future<bool> changePassword(String currentPassword, String newPassword) async {
    _isLoading = true; notifyListeners();
    final res = await repo.changePassword(currentPassword, newPassword);
    _isLoading = false;
    return res.fold((fail) {
      _error = fail.message;
      notifyListeners();
      return false;
    }, (_) {
      notifyListeners();
      return true;
    });
  }

  Future<bool> deactivateAccount() async {
    _isLoading = true; notifyListeners();
    final res = await repo.deactivateAccount();
    _isLoading = false;
    return res.fold((fail) {
      _error = fail.message;
      notifyListeners();
      return false;
    }, (_) {
      _user = null;
      notifyListeners();
      return true;
    });
  }

  Future<bool> logoutAllSessions() async {
    _isLoading = true; notifyListeners();
    final res = await repo.logoutAllSessions();
    _isLoading = false;
    return res.fold((fail) {
      _error = fail.message;
      notifyListeners();
      return false;
    }, (_) {
      _user = null;
      notifyListeners();
      return true;
    });
  }
}