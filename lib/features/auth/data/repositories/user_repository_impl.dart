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
      return Left(
        ServerFailure(e.response?.data['message'] ?? 'Registration failed'),
      );
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, User>> loginUser(String identifier, String password) async {
    try {
      final res = await remote.login(identifier, password);

      if (res['success'] == true && res['data'] != null) {
        final data = res['data'] as Map<String, dynamic>;

        final user = UserModel.fromJson(data, password);

        await local.saveUser(user);
        return Right(user);
      } else {
        return Left(ServerFailure(res['message'] ?? 'Login failed'));
      }
    } on DioException catch (e) {
      return Left(ServerFailure(e.response?.data['message'] ?? 'Login failed'));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, User?>> getCurrentUser() async {
    try {
      return Right(await local.getUser());
    } catch (e) {
      return Left(CacheFailure());
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
  Future<Either<Failure, User>> googleLogin(String idToken) async {
    try {
      final res = await remote.googleLogin(idToken);

      if (res['success'] == true && res['data'] != null) {
        final data = res['data'] as Map<String, dynamic>;
        final user = UserModel.fromJson(data, ''); // Password is empty for Oauth

        await local.saveUser(user);
        return Right(user);
      } else {
        return Left(ServerFailure(res['message'] ?? 'Google login failed'));
      }
    } on DioException catch (e) {
      return Left(ServerFailure(e.response?.data['message'] ?? 'Google login failed'));
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
      return Left(ServerFailure(e.response?.data['message'] ?? 'User not found'));
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
      return Left(ServerFailure(e.response?.data['message'] ?? 'Follow action failed'));
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
      return Left(ServerFailure(e.response?.data['message'] ?? 'Update failed'));
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
}
