import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:twizzle/core/error/failures.dart';
import 'package:twizzle/features/auth/data/datasources/local/hive_local_source.dart';
import '../../domain/entities/tweet.dart';
import '../../domain/repositories/tweet_repository.dart';
import '../datasources/tweet_remote_data_source.dart';
import '../datasources/tweet_local_data_source.dart';

class TweetRepositoryImpl implements TweetRepository {
  final TweetRemoteDataSource remote;
  final HiveLocalSource localAuth;
  final TweetLocalDataSource localTweets;

  TweetRepositoryImpl(this.remote, this.localAuth, this.localTweets);

  @override
  Future<Either<Failure, List<Tweet>>> getFeed({String? userId, String? filter}) async {
    try {
      final user = await localAuth.getUser();
      final tweets = await remote.getFeed(userId: userId, filter: filter);
      
      // Cache the feed on success
      await localTweets.cacheFeed(tweets);
      
      return Right(tweets);
    } on DioException catch (e) {
      // Offline fallback
      final cachedTweets = await localTweets.getCachedFeed();
      if (cachedTweets.isNotEmpty) {
        return Right(cachedTweets);
      }
      return Left(ServerFailure(_getErrorMessage(e)));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Tweet>>> getUserTweets(String username, {String? filter}) async {
    try {
      final user = await localAuth.getUser();
      final tweets = await remote.getUserTweets(username, filter: filter);
      return Right(tweets);
    } on DioException catch (e) {
      return Left(ServerFailure(_getErrorMessage(e)));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Tweet>>> getUserLikes(String username) async {
    try {
      final user = await localAuth.getUser();
      final tweets = await remote.getUserLikes(username);
      return Right(tweets);
    } on DioException catch (e) {
      return Left(ServerFailure(_getErrorMessage(e)));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Tweet>> createTweet(String content, List<String> mediaPaths, {String? location}) async {
    try {
      final user = await localAuth.getUser();
      if (user == null) return Left(ServerFailure('User not logged in'));
      
      final tweet = await remote.createTweet(content, mediaPaths, location: location);
      return Right(tweet);
    } on DioException catch (e) {
      return Left(ServerFailure(_getErrorMessage(e)));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> likeTweet(String id) async {
    try {
      final user = await localAuth.getUser();
      if (user == null) return Left(ServerFailure('User not logged in'));
      
      await remote.likeTweet(id);
      return const Right(unit);
    } on DioException catch (e) {
      return Left(ServerFailure(_getErrorMessage(e)));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> unlikeTweet(String id) async {
    try {
      final user = await localAuth.getUser();
      if (user == null) return Left(ServerFailure('User not logged in'));
      
      await remote.unlikeTweet(id);
      return const Right(unit);
    } on DioException catch (e) {
      return Left(ServerFailure(_getErrorMessage(e)));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> retweet(String id) async {
    try {
      final user = await localAuth.getUser();
      if (user == null) return Left(ServerFailure('User not logged in'));
      
      await remote.retweet(id);
      return const Right(unit);
    } on DioException catch (e) {
      return Left(ServerFailure(_getErrorMessage(e)));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> bookmarkTweet(String id) async {
    try {
      final user = await localAuth.getUser();
      if (user == null) return Left(ServerFailure('User not logged in'));
      
      await remote.bookmarkTweet(id);
      return const Right(unit);
    } on DioException catch (e) {
      return Left(ServerFailure(_getErrorMessage(e)));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Tweet>>> getBookmarks() async {
    try {
      final user = await localAuth.getUser();
      if (user == null) return Left(ServerFailure('User not logged in'));
      
      final tweets = await remote.getBookmarks();
      return Right(tweets);
    } on DioException catch (e) {
      return Left(ServerFailure(_getErrorMessage(e)));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Tweet>> comment(String id, String content) async {
    try {
      final user = await localAuth.getUser();
      if (user == null) return Left(ServerFailure('User not logged in'));
      
      final tweet = await remote.commentTweet(id, content);
      return Right(tweet);
    } on DioException catch (e) {
      return Left(ServerFailure(_getErrorMessage(e)));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> deleteTweet(String id) async {
    try {
      final user = await localAuth.getUser();
      if (user == null) return Left(ServerFailure('User not logged in'));
      
      await remote.deleteTweet(id);
      return const Right(unit);
    } on DioException catch (e) {
      return Left(ServerFailure(_getErrorMessage(e)));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Tweet>> getTweetDetails(String id) async {
    try {
      final tweet = await remote.getTweetDetails(id);
      return Right(tweet);
    } on DioException catch (e) {
      return Left(ServerFailure(_getErrorMessage(e)));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Tweet>>> getTweetComments(String id) async {
    try {
      final comments = await remote.getTweetComments(id);
      return Right(comments);
    } on DioException catch (e) {
      return Left(ServerFailure(_getErrorMessage(e)));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> toggleNotInterested(String tweetId) async {
    try {
      final user = await localAuth.getUser();
      if (user == null) return Left(ServerFailure('User not logged in'));
      
      await remote.toggleNotInterested(tweetId);
      return const Right(unit);
    } on DioException catch (e) {
      return Left(ServerFailure(_getErrorMessage(e)));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  String _getErrorMessage(DioException e) {
    final data = e.response?.data;
    if (data is Map) {
      return data['message'] ?? data['error'] ?? 'Server error';
    }
    if (data is String && data.isNotEmpty) {
      if (data.contains('ERR_NGROK_3200') || data.contains('offline')) {
        return 'Backend is offline. Please check your ngrok/server.';
      }
      return data.length > 100 ? data.substring(0, 100) : data;
    }
    if (e.type == DioExceptionType.connectionError || e.type == DioExceptionType.connectionTimeout) {
      return 'Cannot connect to server. Check your internet or server IP.';
    }
    return e.message ?? 'Network error';
  }
}
