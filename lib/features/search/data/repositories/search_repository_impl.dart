import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
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
          // Check if it's a user (has username, no content) or a tweet
          if (item['username'] != null && item['content'] == null) {
            return UserModel.fromJson(item);
          }
          return TweetModel.fromJson(item);
        }
      }).toList();

      return Right(items);
    } on DioException catch (e) {
      return Left(ServerFailure(_getErrorMessage(e)));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  String _getErrorMessage(DioException e) {
    final data = e.response?.data;
    if (data is Map) {
      return data['message'] ?? data['error'] ?? 'Search failed';
    }
    if (data is String && data.isNotEmpty) {
      if (data.contains('ERR_NGROK_3200') || data.contains('offline')) {
        return 'Backend is offline. Please check your ngrok/server.';
      }
      return data.length > 100 ? data.substring(0, 100) : data;
    }
    return e.message ?? 'Search failed';
  }
}
