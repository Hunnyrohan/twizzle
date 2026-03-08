import 'dart:io';
import 'package:mocktail/mocktail.dart';
import 'package:dio/dio.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:twizzle/core/api/dio_client.dart';
import 'package:twizzle/features/auth/domain/repositories/user_repository.dart';
import 'package:twizzle/features/tweets/domain/repositories/tweet_repository.dart';
import 'package:twizzle/features/auth/domain/entities/user.dart';
import 'package:twizzle/features/tweets/domain/entities/tweet.dart';

// Use Cases
import 'package:twizzle/features/auth/domain/usecases/login_user.dart';
import 'package:twizzle/features/auth/domain/usecases/register_user.dart';
import 'package:twizzle/features/auth/domain/usecases/get_blocks.dart';
import 'package:twizzle/features/auth/domain/usecases/toggle_block.dart';
import 'package:twizzle/features/tweets/domain/usecases/get_feed.dart';
import 'package:twizzle/features/tweets/domain/usecases/create_tweet.dart';
import 'package:twizzle/features/tweets/domain/usecases/like_tweet.dart';
import 'package:twizzle/features/tweets/domain/usecases/unlike_tweet.dart';
import 'package:twizzle/features/tweets/domain/usecases/retweet.dart';
import 'package:twizzle/features/tweets/domain/usecases/bookmark_tweet.dart';
import 'package:twizzle/features/tweets/domain/usecases/comment_tweet.dart';
import 'package:twizzle/features/tweets/domain/usecases/delete_tweet.dart';
import 'package:twizzle/features/tweets/domain/usecases/get_tweet_details.dart';
import 'package:twizzle/features/tweets/domain/usecases/get_tweet_comments.dart';
import 'package:twizzle/features/tweets/domain/usecases/get_bookmarks.dart';
import 'package:twizzle/features/tweets/domain/usecases/toggle_not_interested.dart';

class MockUserRepository extends Mock implements UserRepository {}
class MockTweetRepository extends Mock implements TweetRepository {}
class MockDioClient extends Mock implements DioClient {}
class MockGoogleSignIn extends Mock implements GoogleSignIn {}

class MockLoginUser extends Mock implements LoginUser {}
class MockRegisterUser extends Mock implements RegisterUser {}
class MockGetBlocks extends Mock implements GetBlocks {}
class MockToggleBlock extends Mock implements ToggleBlock {}

class MockGetFeed extends Mock implements GetFeed {}
class MockCreateTweet extends Mock implements CreateTweet {}
class MockLikeTweet extends Mock implements LikeTweet {}
class MockUnlikeTweet extends Mock implements UnlikeTweet {}
class MockRetweet extends Mock implements Retweet {}
class MockBookmarkTweet extends Mock implements BookmarkTweet {}
class MockCommentTweet extends Mock implements CommentTweet {}
class MockDeleteTweet extends Mock implements DeleteTweet {}
class MockGetTweetDetails extends Mock implements GetTweetDetails {}
class MockGetTweetComments extends Mock implements GetTweetComments {}
class MockGetBookmarks extends Mock implements GetBookmarks {}
class MockToggleNotInterested extends Mock implements ToggleNotInterested {}

class FakeUser extends Fake implements User {}
class FakeTweet extends Fake implements Tweet {}
class FakeOptions extends Fake implements Options {}
class FakeFile extends Fake implements File {}

void setupMocks() {
  registerFallbackValue(FakeUser());
  registerFallbackValue(FakeTweet());
  registerFallbackValue(FakeOptions());
  registerFallbackValue(FakeFile());
}
