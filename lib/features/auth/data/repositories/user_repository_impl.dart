// lib/data/repositories/user_repository_impl.dart
import 'package:dartz/dartz.dart';
import 'package:twizzle/core/error/failures.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/user_repository.dart';
import '../datasources/local/hive_local_source.dart';
import '../models/user_model.dart';

class UserRepositoryImpl implements UserRepository {
  final HiveLocalSource local;

  UserRepositoryImpl(this.local);

  @override
  Future<Either<Failure, void>> registerUser(User user) async {
    try {
      await local.saveUser(UserModel(name: user.name, email: user.email, password: user.password));
      return const Right(null);
    } catch (_) {
      return Left(CacheFailure());
    }
  }

  @override
  Future<Either<Failure, User?>> loginUser(String email, String password) async {
    try {
      final user = await local.getUser();
      if (user == null) return const Right(null);
      return user.email == email && user.password == password ? Right(user) : const Right(null);
    } catch (_) {
      return Left(CacheFailure());
    }
  }

  @override
  Future<Either<Failure, User?>> getCurrentUser() async {
    try {
      return Right(await local.getUser());
    } catch (_) {
      return Left(CacheFailure());
    }
  }
}