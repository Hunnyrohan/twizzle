import 'package:dartz/dartz.dart';
import 'package:twizzle/core/error/failures.dart';
import '../entities/tweet.dart';
import '../repositories/tweet_repository.dart';

class CommentTweet {
  final TweetRepository repository;
  CommentTweet(this.repository);

  Future<Either<Failure, Tweet>> call(String id, String content) async {
    return await repository.comment(id, content);
  }
}
