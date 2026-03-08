import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/tweet.dart';
import '../repositories/tweet_repository.dart';

class GetTweetComments {
  final TweetRepository repository;

  GetTweetComments(this.repository);

  Future<Either<Failure, List<Tweet>>> call(String id) async {
    return await repository.getTweetComments(id);
  }
}
