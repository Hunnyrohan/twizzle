import 'dart:io';
import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:twizzle/core/error/failures.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/user_repository.dart';
import '../datasources/local/hive_local_source.dart';
import '../datasources/remote/api_remote_source.dart';
import '../models/user_model.dart';

class UserRepositoryImpl implements UserRepository {
  final ApiRemoteSource remote;
  final HiveLocalSource local;

  UserRepositoryImpl(this.remote, this.local);

  @override
  Future<Either<Failure, User>> registerUser(User user) async {
    try {
      final res = await remote.register(user.name, user.email, user.password, user.username);

      if (res['success'] == true && res['data'] != null) {
        final data = res['data'] as Map<String, dynamic>;

        final newUser = UserModel.fromJson(data, user.password);

        await local.saveUser(newUser);
        return Right(newUser);
      } else {
        return Left(ServerFailure(res['message'] ?? 'Registration failed'));
      }
    } on DioException catch (e) {
      return Left(ServerFailure(_getErrorMessage(e, defaultMessage: 'Registration failed')));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, User>> loginUser(String identifier, String password, {bool confirmReactivate = false}) async {
    try {
      final res = await remote.login(identifier, password, confirmReactivate: confirmReactivate);

      if (res['needsReactivation'] == true) {
        return Left(DeactivatedAccountFailure(res['message'] ?? 'Account deactivated'));
      }

      if (res['success'] == true && res['data'] != null) {
        final data = res['data'] as Map<String, dynamic>;

        final user = UserModel.fromJson(data, password);

        await local.saveUser(user);
        return Right(user);
      } else {
        return Left(ServerFailure(res['message'] ?? 'Login failed'));
      }
    } on DioException catch (e) {
      final data = e.response?.data;
      if (data is Map && data['needsReactivation'] == true) {
        return Left(DeactivatedAccountFailure(data['message'] ?? 'Account deactivated'));
      }
      return Left(ServerFailure(_getErrorMessage(e, defaultMessage: 'Login failed')));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, User?>> getCurrentUser() async {
    try {
      final localUser = await local.getUser();
      
      final res = await remote.getMe();
      if (res['success'] == true && res['data'] != null) {
        final data = res['data'] as Map<String, dynamic>;
        
        if (localUser is UserModel) {
          final updatedUser = UserModel.fromJson(data, localUser.password).copyWith(
            token: localUser.token,
          );
          await local.saveUser(updatedUser);
          return Right(updatedUser);
        } else {
          final user = UserModel.fromJson(data);
          await local.saveUser(user);
          return Right(user);
        }
      }
      
      return Right(localUser);
    } on DioException catch (e) {
      // ONLY fallback to local user if it's a network/connection issue.
      // If it's a 401 or 404, it means the token/user is NOT valid on THIS server.
      if (e.type == DioExceptionType.connectionError || 
          e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.sendTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        final localUser = await local.getUser();
        return Right(localUser);
      }
      
      // For 401/404/etc., don't fallback to a potentially stale local user.
      // Clear the local user to force a fresh login if the session is invalid on THIS server.
      await local.clearUser();
      return Left(ServerFailure(_getErrorMessage(e, defaultMessage: 'Session expired')));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, String>> forgotPassword(String email) async {
    try {
      final res = await remote.forgotPassword(email);
      if (res['success'] == true) {
        return Right(res['data']['message'] ?? 'Code sent');
      } else {
        return Left(ServerFailure(res['error'] ?? 'Failed to send code'));
      }
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, String>> resetPassword(String code, String newPassword) async {
    try {
      final res = await remote.resetPassword(code, newPassword);
      if (res['success'] == true) {
        return Right(res['data']['message'] ?? 'Password reset');
      } else {
        return Left(ServerFailure(res['error'] ?? 'Failed to reset password'));
      }
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, User>> googleLogin(String idToken, {bool confirmReactivate = false}) async {
    try {
      final res = await remote.googleLogin(idToken, confirmReactivate: confirmReactivate);

      if (res['needsReactivation'] == true) {
        return Left(DeactivatedAccountFailure(res['message'] ?? 'Account deactivated'));
      }

      if (res['success'] == true && res['data'] != null) {
        final data = res['data'] as Map<String, dynamic>;
        final user = UserModel.fromJson(data, ''); // Password is empty for Oauth

        await local.saveUser(user);
        return Right(user);
      } else {
        return Left(ServerFailure(res['message'] ?? 'Google login failed'));
      }
    } on DioException catch (e) {
      final data = e.response?.data;
      if (data is Map && data['needsReactivation'] == true) {
        return Left(DeactivatedAccountFailure(data['message'] ?? 'Account deactivated'));
      }
      return Left(ServerFailure(_getErrorMessage(e, defaultMessage: 'Google login failed')));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, User>> getUserProfile(String username) async {
    try {
      final res = await remote.getUserProfile(username);
      if (res['success'] == true && res['data'] != null) {
        return Right(UserModel.fromJson(res['data']));
      } else {
        return Left(ServerFailure(res['message'] ?? 'User not found'));
      }
    } on DioException catch (e) {
      return Left(ServerFailure(_getErrorMessage(e, defaultMessage: 'User not found')));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> toggleFollow(String userId) async {
    try {
      final res = await remote.toggleFollow(userId);
      if (res['success'] == true) {
        return Right(res['data'] as Map<String, dynamic>);
      } else {
        return Left(ServerFailure(res['message'] ?? 'Follow action failed'));
      }
    } on DioException catch (e) {
      return Left(ServerFailure(_getErrorMessage(e, defaultMessage: 'Follow action failed')));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<User>>> getFollowers(String username) async {
    try {
      final res = await remote.getFollowers(username);
      if (res['success'] == true && res['data'] != null) {
        final List data = res['data'] as List;
        return Right(data.map((u) => UserModel.fromJson(u)).toList());
      }
      return Left(ServerFailure(res['message'] ?? 'Failed to get followers'));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<User>>> getFollowing(String username) async {
    try {
      final res = await remote.getFollowing(username);
      if (res['success'] == true && res['data'] != null) {
        final List data = res['data'] as List;
        return Right(data.map((u) => UserModel.fromJson(u)).toList());
      }
      return Left(ServerFailure(res['message'] ?? 'Failed to get following'));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<void> logout() async {
    await local.clearUser();
  }

  @override
  Future<Either<Failure, User>> updateProfile({String? name, String? bio, String? location, String? website}) async {
    try {
      final res = await remote.updateProfile(name: name, bio: bio, location: location, website: website);
      if (res['success'] == true && res['data'] != null) {
        final currentUser = await local.getUser();
        final updatedUser = UserModel.fromJson(res['data'], currentUser?.password ?? '').copyWith(
          token: currentUser?.token,
        );
        await local.saveUser(updatedUser);
        return Right(updatedUser);
      } else {
        return Left(ServerFailure(res['message'] ?? 'Update failed'));
      }
    } on DioException catch (e) {
      return Left(ServerFailure(_getErrorMessage(e, defaultMessage: 'Update failed')));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, String>> uploadAvatar(File image) async {
    try {
      final res = await remote.uploadAvatar(image);
      if (res['success'] == true && res['data'] != null) {
        final imageUrl = res['data']['image'] as String;
        final currentUser = await local.getUser();
        if (currentUser != null) {
          final updatedUser = (currentUser as UserModel).copyWith(image: imageUrl);
          await local.saveUser(updatedUser);
        }
        return Right(imageUrl);
      } else {
        return Left(ServerFailure(res['message'] ?? 'Upload failed'));
      }
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, String>> uploadCover(File image) async {
    try {
      final res = await remote.uploadCover(image);
      if (res['success'] == true && res['data'] != null) {
        final imageUrl = res['data']['image'] as String;
        final currentUser = await local.getUser();
        if (currentUser != null) {
          final updatedUser = (currentUser as UserModel).copyWith(coverImage: imageUrl);
          await local.saveUser(updatedUser);
        }
        return Right(imageUrl);
      } else {
        return Left(ServerFailure(res['message'] ?? 'Upload failed'));
      }
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> toggleBlock(String userId) async {
    try {
      final res = await remote.toggleBlock(userId);
      if (res['success'] == true) {
        return const Right(unit);
      } else {
        return Left(ServerFailure(res['message'] ?? 'Block action failed'));
      }
    } on DioException catch (e) {
      return Left(ServerFailure(_getErrorMessage(e, defaultMessage: 'Block action failed')));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<User>>> getBlocks() async {
    try {
      final res = await remote.getBlocks();
      if (res['success'] == true && res['data'] != null) {
        final List data = res['data'] as List;
        return Right(data.map((u) => UserModel.fromJson(u)).toList());
      } else {
        return Left(ServerFailure(res['message'] ?? 'Failed to get blocked users'));
      }
    } on DioException catch (e) {
      return Left(ServerFailure(_getErrorMessage(e, defaultMessage: 'Failed to get blocked users')));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> changePassword(String currentPassword, String newPassword) async {
    try {
      final res = await remote.changePassword(currentPassword, newPassword);
      if (res['success'] == true) {
        return const Right(unit);
      } else {
        return Left(ServerFailure(res['message'] ?? 'Failed to change password'));
      }
    } on DioException catch (e) {
      return Left(ServerFailure(_getErrorMessage(e, defaultMessage: 'Failed to change password')));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> deactivateAccount() async {
    try {
      final res = await remote.deactivateAccount();
      if (res['success'] == true) {
        await local.clearUser();
        return const Right(unit);
      } else {
        return Left(ServerFailure(res['message'] ?? 'Failed to deactivate account'));
      }
    } on DioException catch (e) {
      return Left(ServerFailure(_getErrorMessage(e, defaultMessage: 'Failed to deactivate account')));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> logoutAllSessions() async {
    try {
      final res = await remote.logoutAllSessions();
      if (res['success'] == true) {
        await local.clearUser();
        return const Right(unit);
      } else {
        return Left(ServerFailure(res['message'] ?? 'Failed to logout from all sessions'));
      }
    } on DioException catch (e) {
      return Left(ServerFailure(_getErrorMessage(e, defaultMessage: 'Failed to logout from all sessions')));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  String _getErrorMessage(DioException e, {required String defaultMessage}) {
    final data = e.response?.data;
    if (data is Map) {
      return data['message'] ?? data['error'] ?? defaultMessage;
    }
    if (data is String && data.isNotEmpty) {
      if (data.contains('ERR_NGROK_3200') || data.contains('offline')) {
        return 'Backend is offline. Please check your ngrok/server.';
      }
      return data.length > 100 ? data.substring(0, 100) : data;
    }
    if (e.type == DioExceptionType.connectionError || e.type == DioExceptionType.connectionTimeout) {
      return 'Cannot connect to server. Check your internet or server IP.';
    }
    return e.message ?? defaultMessage;
  }
}
