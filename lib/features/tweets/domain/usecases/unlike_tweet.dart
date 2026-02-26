import 'package:dartz/dartz.dart';
import 'package:twizzle/core/error/failures.dart';
import '../repositories/tweet_repository.dart';

class UnlikeTweet {
  final TweetRepository repository;
  UnlikeTweet(this.repository);

  Future<Either<Failure, Unit>> call(String id) async {
    return await repository.unlikeTweet(id);
  }
}
