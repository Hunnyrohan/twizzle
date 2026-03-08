import 'package:dartz/dartz.dart';
import 'package:twizzle/core/error/failures.dart';
import '../repositories/tweet_repository.dart';

class ToggleNotInterested {
  final TweetRepository repository;

  ToggleNotInterested(this.repository);

  Future<Either<Failure, Unit>> call(String tweetId) async {
    return await repository.toggleNotInterested(tweetId);
  }
}
