import 'package:dartz/dartz.dart';
import 'package:twizzle/core/error/failures.dart';
import '../repositories/tweet_repository.dart';

class BookmarkTweet {
  final TweetRepository repository;

  BookmarkTweet(this.repository);

  Future<Either<Failure, Unit>> call(String id) async {
    return await repository.bookmarkTweet(id);
  }
}
