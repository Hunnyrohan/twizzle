import 'package:dartz/dartz.dart';
import 'package:twizzle/core/error/failures.dart';
import 'package:twizzle/features/auth/data/models/user_model.dart';
import 'package:twizzle/features/tweets/data/models/tweet_model.dart';
import 'package:twizzle/features/search/domain/repositories/search_repository.dart';
import 'package:twizzle/features/search/data/datasources/remote/search_remote_source.dart';

class SearchRepositoryImpl implements SearchRepository {
  final SearchRemoteSource remoteDataSource;

  SearchRepositoryImpl(this.remoteDataSource);

  @override
  Future<Either<Failure, List<dynamic>>> search({
    required String query,
    required String filter,
    String? cursor,
  }) async {
    try {
      final response = await remoteDataSource.search(
        query: query,
        filter: filter,
        cursor: cursor,
      );

      final List<dynamic> itemsRaw = response['data']['items'] as List<dynamic>;
      
      final List<dynamic> items = itemsRaw.map((item) {
        if (filter == 'people') {
          return UserModel.fromJson(item);
        } else {
          return TweetModel.fromJson(item);
        }
      }).toList();

      return Right(items);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
