import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:twizzle/core/error/failures.dart';
import 'package:twizzle/features/auth/data/datasources/local/hive_local_source.dart';
import '../../domain/entities/tweet.dart';
import '../../domain/repositories/tweet_repository.dart';
import '../datasources/tweet_remote_data_source.dart';

class TweetRepositoryImpl implements TweetRepository {
  final TweetRemoteDataSource remote;
  final HiveLocalSource localAuth;

  TweetRepositoryImpl(this.remote, this.localAuth);

  @override
  Future<Either<Failure, List<Tweet>>> getFeed({String? userId, String? filter}) async {
    try {
      final user = await localAuth.getUser();
      final tweets = await remote.getFeed(userId: userId, filter: filter, token: user?.token);
      return Right(tweets);
    } on DioException catch (e) {
      return Left(ServerFailure(e.response?.data['message'] ?? 'Server error'));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Tweet>>> getUserLikes(String username) async {
    try {
      final user = await localAuth.getUser();
      final tweets = await remote.getUserLikes(username, token: user?.token);
      return Right(tweets);
    } on DioException catch (e) {
      return Left(ServerFailure(e.response?.data['message'] ?? 'Server error'));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Tweet>> createTweet(String content, List<String> mediaPaths) async {
    try {
      final user = await localAuth.getUser();
      if (user == null) return Left(ServerFailure('User not logged in'));
      
      final tweet = await remote.createTweet(content, mediaPaths, user.token);
      return Right(tweet);
    } on DioException catch (e) {
      return Left(ServerFailure(e.response?.data['message'] ?? 'Server error'));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> likeTweet(String id) async {
    try {
      final user = await localAuth.getUser();
      if (user == null) return Left(ServerFailure('User not logged in'));
      
      await remote.likeTweet(id, user.token);
      return const Right(unit);
    } on DioException catch (e) {
      return Left(ServerFailure(e.response?.data['message'] ?? 'Server error'));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> unlikeTweet(String id) async {
    try {
      final user = await localAuth.getUser();
      if (user == null) return Left(ServerFailure('User not logged in'));
      
      await remote.unlikeTweet(id, user.token);
      return const Right(unit);
    } on DioException catch (e) {
      return Left(ServerFailure(e.response?.data['message'] ?? 'Server error'));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> retweet(String id) async {
    try {
      final user = await localAuth.getUser();
      if (user == null) return Left(ServerFailure('User not logged in'));
      
      await remote.retweet(id, user.token);
      return const Right(unit);
    } on DioException catch (e) {
      return Left(ServerFailure(e.response?.data['message'] ?? 'Server error'));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> bookmarkTweet(String id) async {
    try {
      final user = await localAuth.getUser();
      if (user == null) return Left(ServerFailure('User not logged in'));
      
      await remote.bookmarkTweet(id, user.token);
      return const Right(unit);
    } on DioException catch (e) {
      return Left(ServerFailure(e.response?.data['message'] ?? 'Server error'));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Tweet>> comment(String id, String content) async {
    try {
      final user = await localAuth.getUser();
      if (user == null) return Left(ServerFailure('User not logged in'));
      
      final tweet = await remote.commentTweet(id, content, user.token);
      return Right(tweet);
    } on DioException catch (e) {
      return Left(ServerFailure(e.response?.data['message'] ?? 'Server error'));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
