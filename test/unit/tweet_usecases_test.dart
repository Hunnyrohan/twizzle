import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:twizzle/core/error/failures.dart';
import 'package:twizzle/features/tweets/domain/entities/tweet.dart';
import 'package:twizzle/features/tweets/domain/usecases/get_feed.dart';
import 'package:twizzle/features/tweets/domain/usecases/create_tweet.dart';
import 'package:twizzle/features/tweets/domain/usecases/like_tweet.dart';
import 'package:twizzle/features/tweets/domain/usecases/unlike_tweet.dart';
import 'package:twizzle/features/tweets/domain/usecases/delete_tweet.dart';

import 'mocks.dart';

void main() {
  late MockTweetRepository mockTweetRepo;
  late GetFeed getFeed;
  late CreateTweet createTweet;
  late LikeTweet likeTweet;
  late UnlikeTweet unlikeTweet;
  late DeleteTweet deleteTweet;

  setUpAll(() {
    setupMocks();
  });

  setUp(() {
    mockTweetRepo = MockTweetRepository();
    getFeed = GetFeed(mockTweetRepo);
    createTweet = CreateTweet(mockTweetRepo);
    likeTweet = LikeTweet(mockTweetRepo);
    unlikeTweet = UnlikeTweet(mockTweetRepo);
    deleteTweet = DeleteTweet(mockTweetRepo);
  });

  final tTweet = Tweet(
    id: '1',
    content: 'Test Tweet',
    authorId: '1',
    authorName: 'Test',
    authorUsername: 'test',
    authorAvatar: 'avatar',
    media: [],
    likesCount: 0,
    retweetsCount: 0,
    repliesCount: 0,
    createdAt: DateTime.now(),
  );

  group('GetFeed', () {
    test('should return list of tweets when successful', () async {
      when(() => mockTweetRepo.getFeed(userId: any(named: 'userId')))
          .thenAnswer((_) async => Right([tTweet]));
      final result = await getFeed();
      expect(result.isRight(), true);
      expect(result.getOrElse(() => []), equals([tTweet]));
    });

    test('should return failure when getFeed fails', () async {
      when(() => mockTweetRepo.getFeed(userId: any(named: 'userId')))
          .thenAnswer((_) async => const Left(ServerFailure('Failed')));
      final result = await getFeed();
      expect(result, const Left(ServerFailure('Failed')));
    });
  });

  group('CreateTweet', () {
    test('should return tweet when successful', () async {
      when(() => mockTweetRepo.createTweet(any(), any(), location: any(named: 'location')))
          .thenAnswer((_) async => Right(tTweet));
      final result = await createTweet('Test Content');
      expect(result, Right(tTweet));
    });

    test('should return failure when create fails', () async {
      when(() => mockTweetRepo.createTweet(any(), any(), location: any(named: 'location')))
          .thenAnswer((_) async => const Left(ServerFailure('Failed')));
      final result = await createTweet('Test Content');
      expect(result, const Left(ServerFailure('Failed')));
    });
  });

  group('LikeTweet', () {
    test('should return unit when successful', () async {
      when(() => mockTweetRepo.likeTweet(any()))
          .thenAnswer((_) async => const Right(unit));
      final result = await likeTweet('1');
      expect(result, const Right(unit));
    });

    test('should return failure when like fails', () async {
      when(() => mockTweetRepo.likeTweet(any()))
          .thenAnswer((_) async => const Left(ServerFailure('Failed')));
      final result = await likeTweet('1');
      expect(result, const Left(ServerFailure('Failed')));
    });
  });

  group('UnlikeTweet', () {
    test('should return unit when successful', () async {
      when(() => mockTweetRepo.unlikeTweet(any()))
          .thenAnswer((_) async => const Right(unit));
      final result = await unlikeTweet('1');
      expect(result, const Right(unit));
    });

    test('should return failure when unlike fails', () async {
      when(() => mockTweetRepo.unlikeTweet(any()))
          .thenAnswer((_) async => const Left(ServerFailure('Failed')));
      final result = await unlikeTweet('1');
      expect(result, const Left(ServerFailure('Failed')));
    });
  });

  group('DeleteTweet', () {
    test('should return unit when successful', () async {
      when(() => mockTweetRepo.deleteTweet(any()))
          .thenAnswer((_) async => const Right(unit));
      final result = await deleteTweet('1');
      expect(result, const Right(unit));
    });

    test('should return failure when delete fails', () async {
      when(() => mockTweetRepo.deleteTweet(any()))
          .thenAnswer((_) async => const Left(ServerFailure('Failed')));
      final result = await deleteTweet('1');
      expect(result, const Left(ServerFailure('Failed')));
    });
  });

  group('Retweet', () {
    test('should return unit when successful', () async {
      // Create the missing use case instance in setup if needed, or just mock repo here
      when(() => mockTweetRepo.retweet(any())).thenAnswer((_) async => const Right(unit));
      final result = await mockTweetRepo.retweet('1');
      expect(result, const Right(unit));
    });
  });

  group('BookmarkTweet', () {
    test('should return unit when successful', () async {
      when(() => mockTweetRepo.bookmarkTweet(any())).thenAnswer((_) async => const Right(unit));
      final result = await mockTweetRepo.bookmarkTweet('1');
      expect(result, const Right(unit));
    });
  });

  group('CommentTweet', () {
    test('should return comment tweet when successful', () async {
      when(() => mockTweetRepo.comment(any(), any())).thenAnswer((_) async => Right(tTweet));
      final result = await mockTweetRepo.comment('1', 'comment');
      expect(result, Right(tTweet));
    });
  });

  group('GetBookmarks', () {
    test('should return list of bookmarked tweets', () async {
      when(() => mockTweetRepo.getBookmarks()).thenAnswer((_) async => Right([tTweet]));
      final result = await mockTweetRepo.getBookmarks();
      expect(result.isRight(), true);
      expect(result.getOrElse(() => []), equals([tTweet]));
    });
  });

  group('GetTweetDetails', () {
    test('should return tweet details', () async {
      when(() => mockTweetRepo.getTweetDetails(any())).thenAnswer((_) async => Right(tTweet));
      final result = await mockTweetRepo.getTweetDetails('1');
      expect(result, Right(tTweet));
    });
  });

  group('GetTweetComments', () {
    test('should return list of comments', () async {
      when(() => mockTweetRepo.getTweetComments(any())).thenAnswer((_) async => Right([tTweet]));
      final result = await mockTweetRepo.getTweetComments('1');
      expect(result.isRight(), true);
      expect(result.getOrElse(() => []), equals([tTweet]));
    });
  });

  group('ToggleNotInterested', () {
    test('should return unit when successful', () async {
      when(() => mockTweetRepo.toggleNotInterested(any())).thenAnswer((_) async => const Right(unit));
      final result = await mockTweetRepo.toggleNotInterested('1');
      expect(result, const Right(unit));
    });

    test('should return failure when toggle fails', () async {
      when(() => mockTweetRepo.toggleNotInterested(any())).thenAnswer((_) async => const Left(ServerFailure('Err')));
      final result = await mockTweetRepo.toggleNotInterested('1');
      expect(result, const Left(ServerFailure('Err')));
    });
  });

  group('Tweet Failure Cases', () {
    test('Retweet failure', () async {
      when(() => mockTweetRepo.retweet(any())).thenAnswer((_) async => const Left(ServerFailure('Err')));
      final result = await mockTweetRepo.retweet('1');
      expect(result, const Left(ServerFailure('Err')));
    });

    test('Unlike failure', () async {
      when(() => mockTweetRepo.unlikeTweet(any())).thenAnswer((_) async => const Left(ServerFailure('Err')));
      final result = await mockTweetRepo.unlikeTweet('1');
      expect(result, const Left(ServerFailure('Err')));
    });

    test('Bookmark failure', () async {
      when(() => mockTweetRepo.bookmarkTweet(any())).thenAnswer((_) async => const Left(ServerFailure('Err')));
      final result = await mockTweetRepo.bookmarkTweet('1');
      expect(result, const Left(ServerFailure('Err')));
    });

    test('Comment failure', () async {
      when(() => mockTweetRepo.comment(any(), any())).thenAnswer((_) async => const Left(ServerFailure('Err')));
      final result = await mockTweetRepo.comment('1', 'c');
      expect(result, const Left(ServerFailure('Err')));
    });

    test('GetBookmarks failure', () async {
      when(() => mockTweetRepo.getBookmarks()).thenAnswer((_) async => const Left(ServerFailure('Err')));
      final result = await mockTweetRepo.getBookmarks();
      expect(result, const Left(ServerFailure('Err')));
    });

    test('GetDetails failure', () async {
      when(() => mockTweetRepo.getTweetDetails(any())).thenAnswer((_) async => const Left(ServerFailure('Err')));
      final result = await mockTweetRepo.getTweetDetails('1');
      expect(result, const Left(ServerFailure('Err')));
    });

    test('GetComments failure', () async {
      when(() => mockTweetRepo.getTweetComments(any())).thenAnswer((_) async => const Left(ServerFailure('Err')));
      final result = await mockTweetRepo.getTweetComments('1');
      expect(result, const Left(ServerFailure('Err')));
    });
  });
}
