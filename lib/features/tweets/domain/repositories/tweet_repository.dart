import 'package:dartz/dartz.dart';
import 'package:twizzle/core/error/failures.dart';
import '../../domain/entities/tweet.dart';

abstract class TweetRepository {
  Future<Either<Failure, List<Tweet>>> getFeed({String? userId, String? filter});
  Future<Either<Failure, List<Tweet>>> getUserTweets(String username, {String? filter});
  Future<Either<Failure, List<Tweet>>> getUserLikes(String username);
  Future<Either<Failure, Tweet>> createTweet(String content, List<String> mediaPaths, {String? location});
  Future<Either<Failure, Unit>> likeTweet(String id);
  Future<Either<Failure, Unit>> unlikeTweet(String id);
  Future<Either<Failure, Unit>> retweet(String id);
  Future<Either<Failure, Unit>> bookmarkTweet(String id);
  Future<Either<Failure, List<Tweet>>> getBookmarks();
  Future<Either<Failure, Tweet>> comment(String id, String content);
  Future<Either<Failure, Unit>> deleteTweet(String id);
  Future<Either<Failure, Tweet>> getTweetDetails(String id);
  Future<Either<Failure, List<Tweet>>> getTweetComments(String id);
  Future<Either<Failure, Unit>> toggleNotInterested(String tweetId);
}
