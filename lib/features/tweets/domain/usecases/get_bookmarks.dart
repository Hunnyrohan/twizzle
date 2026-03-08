import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/tweet.dart';
import '../repositories/tweet_repository.dart';

class GetBookmarks {
  final TweetRepository repository;

  GetBookmarks(this.repository);

  Future<Either<Failure, List<Tweet>>> call() async {
    return await repository.getBookmarks();
  }
}
