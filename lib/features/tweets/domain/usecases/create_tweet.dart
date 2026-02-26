import 'package:dartz/dartz.dart';
import 'package:twizzle/core/error/failures.dart';
import '../entities/tweet.dart';
import '../repositories/tweet_repository.dart';

class CreateTweet {
  final TweetRepository repository;

  CreateTweet(this.repository);

  Future<Either<Failure, Tweet>> call(String content, {List<String> mediaPaths = const []}) async {
    return await repository.createTweet(content, mediaPaths);
  }
}
