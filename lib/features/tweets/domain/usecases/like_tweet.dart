import 'package:dartz/dartz.dart';
import 'package:twizzle/core/error/failures.dart';
import '../repositories/tweet_repository.dart';

class LikeTweet {
  final TweetRepository repository;

  LikeTweet(this.repository);

  Future<Either<Failure, Unit>> call(String id) async {
    return await repository.likeTweet(id);
  }
}
