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
      final res = await remote.register(user.name, user.email, user.password);

      // ✅ FIX: read from res['data']
      if (res['success'] == true && res['data'] != null) {
        final data = res['data'] as Map<String, dynamic>;

        final newUser = UserModel.fromJson(
          data, // ✅ CORRECT
          user.password,
        );

        await local.saveUser(newUser);
        return Right(newUser);
      } else {
        return Left(ServerFailure(res['message'] ?? 'Registration failed'));
      }
    } on DioError catch (e) {
      return Left(
        ServerFailure(e.response?.data['message'] ?? 'Registration failed'),
      );
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, User>> loginUser(String email, String password) async {
    try {
      final res = await remote.login(email, password);

      // ✅ FIX: read from res['data']
      if (res['success'] == true && res['data'] != null) {
        final data = res['data'] as Map<String, dynamic>;

        final user = UserModel.fromJson(
          data, // ✅ CORRECT
          password,
        );

        await local.saveUser(user);
        return Right(user);
      } else {
        return Left(ServerFailure(res['message'] ?? 'Login failed'));
      }
    } on DioError catch (e) {
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
}
