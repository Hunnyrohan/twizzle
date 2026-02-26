import 'package:dartz/dartz.dart';
import 'package:twizzle/core/error/failures.dart';
import '../entities/tweet.dart';
import '../repositories/tweet_repository.dart';

class GetFeed {
  final TweetRepository repository;

  GetFeed(this.repository);

  Future<Either<Failure, List<Tweet>>> call({String? userId}) async {
    return await repository.getFeed(userId: userId);
  }
}
