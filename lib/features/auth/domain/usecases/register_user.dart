// lib/domain/usecases/register_user.dart
import 'package:dartz/dartz.dart';
import 'package:twizzle/core/error/failures.dart';
import '../entities/user.dart';
import '../repositories/user_repository.dart';

class RegisterUser {
  final UserRepository repo;
  RegisterUser(this.repo);
  Future<Either<Failure, void>> call(User user) => repo.registerUser(user);
}