// lib/domain/repositories/user_repository.dart
import 'package:dartz/dartz.dart';
import 'package:twizzle/core/error/failures.dart';
import '../entities/user.dart';

abstract class UserRepository {
  Future<Either<Failure, void>> registerUser(User user);
  Future<Either<Failure, User?>> loginUser(String email, String password);
  Future<Either<Failure, User?>> getCurrentUser();
}
