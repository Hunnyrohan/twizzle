// lib/injection_container.dart
import 'package:get_it/get_it.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:twizzle/core/api/dio_client.dart';
import 'package:twizzle/core/services/socket_service.dart';
import 'package:twizzle/core/services/call_service.dart';

// auth
import 'package:twizzle/features/auth/domain/presentation/providers/user_provider.dart';
import 'package:twizzle/features/auth/domain/presentation/providers/profile_provider.dart';
import 'package:twizzle/features/auth/data/datasources/local/hive_local_source.dart';
import 'package:twizzle/features/auth/data/datasources/remote/api_remote_source.dart';
import 'package:twizzle/features/auth/data/repositories/user_repository_impl.dart';
import 'package:twizzle/features/auth/domain/repositories/user_repository.dart';
import 'package:twizzle/features/auth/domain/usecases/register_user.dart';
import 'package:twizzle/features/auth/domain/usecases/login_user.dart';
import 'package:twizzle/features/auth/domain/usecases/toggle_block.dart';
import 'package:twizzle/features/auth/domain/usecases/get_blocks.dart';
import 'package:twizzle/theme/theme_provider.dart';

// tweets
import 'package:twizzle/features/tweets/data/datasources/tweet_remote_data_source.dart';
import 'package:twizzle/features/tweets/data/datasources/tweet_local_data_source.dart';
import 'package:twizzle/features/tweets/data/repositories/tweet_repository_impl.dart';
import 'package:twizzle/features/tweets/domain/repositories/tweet_repository.dart';
import 'package:twizzle/features/tweets/domain/usecases/get_feed.dart';
import 'package:twizzle/features/tweets/domain/usecases/create_tweet.dart';
import 'package:twizzle/features/tweets/domain/usecases/like_tweet.dart';
import 'package:twizzle/features/tweets/domain/usecases/unlike_tweet.dart';
import 'package:twizzle/features/tweets/domain/usecases/retweet.dart';
import 'package:twizzle/features/tweets/domain/usecases/comment_tweet.dart';
import 'package:twizzle/features/tweets/domain/usecases/bookmark_tweet.dart';
import 'package:twizzle/features/tweets/domain/usecases/get_bookmarks.dart';
import 'package:twizzle/features/tweets/domain/usecases/delete_tweet.dart';
import 'package:twizzle/features/tweets/domain/usecases/get_tweet_details.dart';
import 'package:twizzle/features/tweets/domain/usecases/get_tweet_comments.dart';
import 'package:twizzle/features/tweets/domain/usecases/toggle_not_interested.dart';
import 'package:twizzle/features/tweets/presentation/providers/tweet_provider.dart';

// search
import 'package:twizzle/features/search/data/datasources/remote/search_remote_source.dart';
import 'package:twizzle/features/search/data/repositories/search_repository_impl.dart';
import 'package:twizzle/features/search/domain/repositories/search_repository.dart';
import 'package:twizzle/features/search/presentation/providers/search_provider.dart';

// notifications
import 'package:twizzle/features/notifications/data/datasources/remote/notification_remote_source.dart';
import 'package:twizzle/features/notifications/data/repositories/notification_repository_impl.dart';
import 'package:twizzle/features/notifications/domain/repositories/notification_repository.dart';
import 'package:twizzle/features/notifications/presentation/providers/notification_provider.dart';

// messages
import 'package:twizzle/features/messages/data/datasources/remote/message_remote_source.dart';
import 'package:twizzle/features/messages/data/repositories/message_repository_impl.dart';
import 'package:twizzle/features/messages/domain/repositories/message_repository.dart';
import 'package:twizzle/features/messages/presentation/providers/message_provider.dart';
import 'package:twizzle/features/verification/data/services/payment_service.dart';

final sl = GetIt.instance;

Future<void> init() async {
  await Hive.initFlutter();
  final settingsBox = await Hive.openBox('settings');
  final userBox = await Hive.openBox('userBox');

  // Register boxes
  sl.registerLazySingleton<Box>(() => userBox);
  sl.registerLazySingleton<Box>(() => settingsBox, instanceName: 'settings');

  // core
  sl.registerLazySingleton<DioClient>(() => DioClient());
  sl.registerLazySingleton<SocketService>(() => SocketService());
  sl.registerLazySingleton<CallService>(() => CallService(socketService: sl()));

  // datasources
  sl.registerLazySingleton<ApiRemoteSource>(() => ApiRemoteSource(sl()));
  sl.registerLazySingleton<HiveLocalSource>(() => HiveLocalSource());
  sl.registerLazySingleton<TweetRemoteDataSource>(() => TweetRemoteDataSource(sl()));
  sl.registerLazySingleton<TweetLocalDataSource>(() => TweetLocalDataSource());
  sl.registerLazySingleton<SearchRemoteSource>(() => SearchRemoteSource(sl()));
  sl.registerLazySingleton<NotificationRemoteSource>(() => NotificationRemoteSource(sl()));
  sl.registerLazySingleton<MessageRemoteSource>(() => MessageRemoteSource(sl()));
  sl.registerLazySingleton<PaymentService>(() => PaymentService(sl()));

  // repository
  sl.registerLazySingleton<UserRepository>(
      () => UserRepositoryImpl(sl(), sl()));
  sl.registerLazySingleton<TweetRepository>(
      () => TweetRepositoryImpl(sl(), sl(), sl()));
  sl.registerLazySingleton<SearchRepository>(
      () => SearchRepositoryImpl(sl()));
  sl.registerLazySingleton<NotificationRepository>(
      () => NotificationRepositoryImpl(sl()));
  
  // For MessageRepository, we need currentUserId. 
  sl.registerLazySingleton<MessageRepository>(
      () => MessageRepositoryImpl(sl(), sl<UserProvider>()));

  // use cases
  sl.registerLazySingleton(() => RegisterUser(sl()));
  sl.registerLazySingleton(() => LoginUser(sl()));
  sl.registerLazySingleton(() => GetFeed(sl()));
  sl.registerLazySingleton(() => CreateTweet(sl()));
  sl.registerLazySingleton(() => LikeTweet(sl()));
  sl.registerLazySingleton(() => UnlikeTweet(sl()));
  sl.registerLazySingleton(() => Retweet(sl()));
  sl.registerLazySingleton(() => BookmarkTweet(sl()));
  sl.registerLazySingleton(() => GetBookmarks(sl()));
  sl.registerLazySingleton(() => CommentTweet(sl()));
  sl.registerLazySingleton(() => DeleteTweet(sl()));
  sl.registerLazySingleton(() => ToggleBlock(sl()));
  sl.registerLazySingleton(() => GetBlocks(sl()));
  sl.registerLazySingleton(() => GetTweetDetails(sl()));
  sl.registerLazySingleton(() => GetTweetComments(sl()));
  sl.registerLazySingleton(() => ToggleNotInterested(sl()));

  // provider
  sl.registerLazySingleton(() => UserProvider(register: sl(), login: sl(), getBlocksUseCase: sl(), repo: sl()));
  sl.registerLazySingleton(() => TweetProvider(
        getFeedUseCase: sl(),
        createTweetUseCase: sl(),
        likeTweetUseCase: sl(),
        unlikeTweetUseCase: sl(),
        retweetUseCase: sl(),
        bookmarkTweetUseCase: sl(),
        commentTweetUseCase: sl(),
        deleteTweetUseCase: sl(),
        toggleBlockUseCase: sl(),
        getTweetDetailsUseCase: sl(),
        getTweetCommentsUseCase: sl(),
        getBookmarksUseCase: sl(),
        toggleNotInterestedUseCase: sl(),
      ));
  sl.registerLazySingleton(() => SearchProvider(repository: sl(), userRepository: sl()));
  sl.registerLazySingleton(() => NotificationProvider(repository: sl()));
  sl.registerLazySingleton(
      () => MessageProvider(repository: sl(), socketService: sl()));
  sl.registerLazySingleton(() => ProfileProvider(
        userRepository: sl(),
        tweetRepository: sl(),
        tweetProvider: sl(),
        userProvider: sl(),
      ));
  sl.registerLazySingleton(() => ThemeProvider(sl<Box>(instanceName: 'settings')));
}