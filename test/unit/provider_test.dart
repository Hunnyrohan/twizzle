import 'dart:io';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:twizzle/core/error/failures.dart';
import 'package:twizzle/features/auth/domain/entities/user.dart';
import 'package:twizzle/features/tweets/domain/entities/tweet.dart';
import 'package:twizzle/features/auth/domain/presentation/providers/user_provider.dart';
import 'package:twizzle/features/tweets/presentation/providers/tweet_provider.dart';
import 'package:twizzle/features/tweets/data/models/tweet_model.dart';

import 'mocks.dart';

void main() {
  late MockUserRepository mockUserRepo;
  late MockLoginUser mockLoginUser;
  late MockRegisterUser mockRegisterUser;
  late MockGetBlocks mockGetBlocks;
  late MockGoogleSignIn mockGoogleSignIn;
  late UserProvider userProvider;

  late MockGetFeed mockGetFeed;
  late MockCreateTweet mockCreateTweet;
  late MockLikeTweet mockLikeTweet;
  late MockUnlikeTweet mockUnlikeTweet;
  late MockRetweet mockRetweet;
  late MockBookmarkTweet mockBookmarkTweet;
  late MockCommentTweet mockCommentTweet;
  late MockDeleteTweet mockDeleteTweet;
  late MockToggleBlock mockToggleBlock;
  late MockGetTweetDetails mockGetTweetDetails;
  late MockGetTweetComments mockGetTweetComments;
  late MockGetBookmarks mockGetBookmarks;
  late MockToggleNotInterested mockToggleNotInterested;
  late TweetProvider tweetProvider;

  setUpAll(() {
    setupMocks();
  });

  setUp(() {
    // Auth SetUp
    mockUserRepo = MockUserRepository();
    mockLoginUser = MockLoginUser();
    mockRegisterUser = MockRegisterUser();
    mockGetBlocks = MockGetBlocks();
    mockGoogleSignIn = MockGoogleSignIn();
    userProvider = UserProvider(
      repo: mockUserRepo,
      login: mockLoginUser,
      register: mockRegisterUser,
      getBlocksUseCase: mockGetBlocks,
      googleSignIn: mockGoogleSignIn,
    );

    // Tweets SetUp
    mockGetFeed = MockGetFeed();
    mockCreateTweet = MockCreateTweet();
    mockLikeTweet = MockLikeTweet();
    mockUnlikeTweet = MockUnlikeTweet();
    mockRetweet = MockRetweet();
    mockBookmarkTweet = MockBookmarkTweet();
    mockCommentTweet = MockCommentTweet();
    mockDeleteTweet = MockDeleteTweet();
    mockToggleBlock = MockToggleBlock();
    mockGetTweetDetails = MockGetTweetDetails();
    mockGetTweetComments = MockGetTweetComments();
    mockGetBookmarks = MockGetBookmarks();
    mockToggleNotInterested = MockToggleNotInterested();

    tweetProvider = TweetProvider(
      getFeedUseCase: mockGetFeed,
      createTweetUseCase: mockCreateTweet,
      likeTweetUseCase: mockLikeTweet,
      unlikeTweetUseCase: mockUnlikeTweet,
      retweetUseCase: mockRetweet,
      bookmarkTweetUseCase: mockBookmarkTweet,
      commentTweetUseCase: mockCommentTweet,
      deleteTweetUseCase: mockDeleteTweet,
      toggleBlockUseCase: mockToggleBlock,
      getTweetDetailsUseCase: mockGetTweetDetails,
      getTweetCommentsUseCase: mockGetTweetComments,
      getBookmarksUseCase: mockGetBookmarks,
      toggleNotInterestedUseCase: mockToggleNotInterested,
    );
  });

  final tUser = User(id: '1', name: 'Test', username: 'test', email: 'test@test.com', password: 'p', token: 't');
  
  final tTweetModel = TweetModel(
    id: '1',
    content: 'Test',
    authorId: '1',
    authorName: 'Test',
    authorUsername: 'test',
    authorAvatar: 'a',
    media: [],
    likesCount: 0,
    retweetsCount: 0,
    repliesCount: 0,
    createdAt: DateTime.now(),
  );

  group('UserProvider', () {
    test('should set user and loading false when login is successful', () async {
      when(() => mockLoginUser(any(), any(), confirmReactivate: any(named: 'confirmReactivate')))
          .thenAnswer((_) async => Right(tUser));
      
      final result = await userProvider.loginUser('email', 'password');
      
      expect(result, true);
      expect(userProvider.user, tUser);
      expect(userProvider.isLoading, false);
    });

    test('should set error and loading false when login fails', () async {
      when(() => mockLoginUser(any(), any(), confirmReactivate: any(named: 'confirmReactivate')))
          .thenAnswer((_) async => const Left(ServerFailure('Error')));
      
      final result = await userProvider.loginUser('email', 'password');
      
      expect(result, false);
      expect(userProvider.error, 'Error');
      expect(userProvider.isLoading, false);
    });

    test('should return true and set loading false when registration is successful', () async {
      when(() => mockRegisterUser(any())).thenAnswer((_) async => Right(tUser));
      final result = await userProvider.registerUser(tUser);
      expect(result, true);
      expect(userProvider.isLoading, false);
    });

    test('should return false and set error when registration fails', () async {
      when(() => mockRegisterUser(any())).thenAnswer((_) async => const Left(ServerFailure('Reg Fail')));
      final result = await userProvider.registerUser(tUser);
      expect(result, false);
      expect(userProvider.error, 'Reg Fail');
    });

    test('should return true when uploadAvatar is successful', () async {
      when(() => mockUserRepo.uploadAvatar(any())).thenAnswer((_) async => const Right('url'));
      final result = await userProvider.uploadAvatar(File('path'));
      expect(result, true);
    });

    test('should return true when changePassword is successful', () async {
      when(() => mockUserRepo.changePassword(any(), any())).thenAnswer((_) async => const Right(unit));
      final result = await userProvider.changePassword('old', 'new');
      expect(result, true);
    });
  });

  group('TweetProvider', () {
    test('should update tweets list when fetchFeed is successful', () async {
      when(() => mockGetFeed()).thenAnswer((_) async => Right([tTweetModel]));
      
      await tweetProvider.fetchFeed();
      
      expect(tweetProvider.tweets, [tTweetModel]);
      expect(tweetProvider.isLoading, false);
    });

    test('should update state to error when fetchFeed fails', () async {
      when(() => mockGetFeed()).thenAnswer((_) async => const Left(ServerFailure('Feed Error')));
      
      await tweetProvider.fetchFeed();
      
      expect(tweetProvider.error, 'Feed Error');
      expect(tweetProvider.isLoading, false);
    });

    test('should perform optimistic update when toggleLike is called', () async {
      tweetProvider.cache['1'] = tTweetModel;
      when(() => mockLikeTweet(any())).thenAnswer((_) async => const Right(unit));
      
      final future = tweetProvider.toggleLike('1');
      
      // Should be liked immediately (optimistic)
      expect(tweetProvider.cache['1']?.isLiked, true);
      expect(tweetProvider.cache['1']?.likesCount, 1);
      
      await future;
      
      // Still liked after success
      expect(tweetProvider.cache['1']?.isLiked, true);
    });

    test('should add tweet to bookmarks when toggleBookmark is successful', () async {
      tweetProvider.cache['1'] = tTweetModel;
      when(() => mockBookmarkTweet(any())).thenAnswer((_) async => const Right(unit));
      
      await tweetProvider.toggleBookmark('1');
      
      expect(tweetProvider.cache['1']?.isBookmarked, true);
    });

    test('should add comment to cache when addComment is successful', () async {
      tweetProvider.cache['1'] = tTweetModel;
      when(() => mockCommentTweet(any(), any())).thenAnswer((_) async => Right(tTweetModel.copyWith(id: '2')));
      
      final result = await tweetProvider.addComment('1', 'new comment');
      
      expect(result, true);
      expect(tweetProvider.cache['2']?.id, '2');
      expect(tweetProvider.cache['1']?.repliesCount, 1);
    });

    test('should remove tweet from list when deleteTweet is successful', () async {
      tweetProvider.tweets.add(tTweetModel);
      when(() => mockDeleteTweet(any())).thenAnswer((_) async => const Right(unit));
      
      final result = await tweetProvider.deleteTweet('1');
      
      expect(result, true);
      expect(tweetProvider.tweets.isEmpty, true);
    });

    test('should return true and insert tweet when postTweet is successful', () async {
      when(() => mockCreateTweet(any(), mediaPaths: any(named: 'mediaPaths'), location: any(named: 'location')))
          .thenAnswer((_) async => Right(tTweetModel));
      final result = await tweetProvider.postTweet('content');
      expect(result, true);
      expect(tweetProvider.tweets.contains(tTweetModel), true);
    });

    test('should update cache when toggleRetweet is successful', () async {
      tweetProvider.cache['1'] = tTweetModel;
      when(() => mockRetweet(any())).thenAnswer((_) async => const Right(unit));
      when(() => mockGetFeed()).thenAnswer((_) async => Right([tTweetModel]));
      await tweetProvider.toggleRetweet('1');
      expect(tweetProvider.cache['1']?.isRetweeted, true);
    });

    test('should remove tweet from list when toggleNotInterested is successful', () async {
      tweetProvider.tweets.add(tTweetModel);
      when(() => mockToggleNotInterested(any())).thenAnswer((_) async => const Right(unit));
      await tweetProvider.toggleNotInterested('1');
      expect(tweetProvider.tweets.isEmpty, true);
    });
  });

  group('UserProvider Profile', () {
    test('should update user and loading false when updateProfile is successful', () async {
      when(() => mockUserRepo.updateProfile(name: any(named: 'name')))
          .thenAnswer((_) async => Right(tUser));
      
      final result = await userProvider.updateProfile(name: 'New Name');
      
      expect(result, true);
      expect(userProvider.user, tUser);
    });

    test('should clear user when logout is called', () async {
      when(() => mockUserRepo.logout()).thenAnswer((_) async => {});
      when(() => mockGoogleSignIn.signOut()).thenAnswer((_) async => null);
      
      await userProvider.logout();
      
      expect(userProvider.user, null);
      verify(() => mockGoogleSignIn.signOut()).called(1);
    });
  });
}
