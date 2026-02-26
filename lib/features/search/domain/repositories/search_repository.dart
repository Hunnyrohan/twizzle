import 'package:dartz/dartz.dart';
import 'package:twizzle/core/error/failures.dart';
import 'package:twizzle/features/auth/domain/entities/user.dart';
import 'package:twizzle/features/tweets/domain/entities/tweet.dart';

abstract class SearchRepository {
  Future<Either<Failure, List<dynamic>>> search({
    required String query,
    required String filter,
    String? cursor,
  });
}
