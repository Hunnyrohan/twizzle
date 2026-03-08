// lib/features/auth/domain/repositories/user_repository.dart
import 'dart:io';
import 'package:dartz/dartz.dart';
import 'package:twizzle/core/error/failures.dart';
import '../entities/user.dart';

abstract class UserRepository {
  Future<Either<Failure, User>> registerUser(User user);
  Future<Either<Failure, User>> loginUser(String identifier, String password, {bool confirmReactivate = false});
  Future<Either<Failure, User?>> getCurrentUser();
  Future<Either<Failure, String>> forgotPassword(String email);
  Future<Either<Failure, String>> resetPassword(String code, String newPassword);
  Future<Either<Failure, User>> googleLogin(String idToken, {bool confirmReactivate = false});
  Future<Either<Failure, User>> getUserProfile(String username);
  Future<Either<Failure, Map<String, dynamic>>> toggleFollow(String userId);
  Future<Either<Failure, List<User>>> getFollowers(String username);
  Future<Either<Failure, List<User>>> getFollowing(String username);
  Future<Either<Failure, User>> updateProfile({String? name, String? bio, String? location, String? website});
  Future<Either<Failure, String>> uploadAvatar(File image);
  Future<Either<Failure, String>> uploadCover(File image);
  Future<Either<Failure, Unit>> toggleBlock(String userId);
  Future<Either<Failure, List<User>>> getBlocks();
  Future<Either<Failure, Unit>> changePassword(String currentPassword, String newPassword);
  Future<Either<Failure, Unit>> deactivateAccount();
  Future<Either<Failure, Unit>> logoutAllSessions();
  Future<void> logout();
}
