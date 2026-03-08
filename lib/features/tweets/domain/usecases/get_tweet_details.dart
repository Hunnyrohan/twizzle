import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/tweet.dart';
import '../repositories/tweet_repository.dart';

class GetTweetDetails {
  final TweetRepository repository;

  GetTweetDetails(this.repository);

  Future<Either<Failure, Tweet>> call(String id) async {
    return await repository.getTweetDetails(id);
  }
}
