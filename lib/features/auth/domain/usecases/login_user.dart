// lib/domain/usecases/login_user.dart
import 'package:dartz/dartz.dart';
import 'package:twizzle/core/error/failures.dart';
import '../entities/user.dart';
import '../repositories/user_repository.dart';


class LoginUser {
  final UserRepository repo;
  LoginUser(this.repo);
  Future<Either<Failure, User?>> call(String email, String password) =>
      repo.loginUser(email, password);
}