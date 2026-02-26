import 'package:flutter/material.dart';
import 'package:twizzle/features/tweets/domain/entities/tweet.dart';
import 'package:twizzle/features/tweets/domain/usecases/get_feed.dart';
import 'package:twizzle/features/tweets/domain/usecases/create_tweet.dart';
import 'package:twizzle/features/tweets/domain/usecases/like_tweet.dart';
import 'package:twizzle/features/tweets/domain/usecases/unlike_tweet.dart';
import 'package:twizzle/features/tweets/domain/usecases/retweet.dart';
import 'package:twizzle/features/tweets/domain/usecases/bookmark_tweet.dart';
import 'package:twizzle/features/tweets/domain/usecases/comment_tweet.dart';

class TweetProvider with ChangeNotifier {
  final GetFeed getFeedUseCase;
  final CreateTweet createTweetUseCase;
  final LikeTweet likeTweetUseCase;
  final UnlikeTweet unlikeTweetUseCase;
  final Retweet retweetUseCase;
  final BookmarkTweet bookmarkTweetUseCase;
  final CommentTweet commentTweetUseCase;

  TweetProvider({
    required this.getFeedUseCase,
    required this.createTweetUseCase,
    required this.likeTweetUseCase,
    required this.unlikeTweetUseCase,
    required this.retweetUseCase,
    required this.bookmarkTweetUseCase,
    required this.commentTweetUseCase,
  });

  List<Tweet> _tweets = [];
  bool _isLoading = false;
  String? _error;

  List<Tweet> get tweets => _tweets;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchFeed() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    final result = await getFeedUseCase();
    result.fold(
      (failure) {
        _error = failure.message;
        _isLoading = false;
        notifyListeners();
      },
      (tweets) {
        _tweets = tweets;
        _isLoading = false;
        notifyListeners();
      },
    );
  }

  Future<bool> postTweet(String content, {List<String> mediaPaths = const []}) async {
    _isLoading = true;
    notifyListeners();

    final result = await createTweetUseCase(content, mediaPaths: mediaPaths);
    return result.fold(
      (failure) {
        _error = failure.message;
        _isLoading = false;
        notifyListeners();
        return false;
      },
      (tweet) {
        _tweets.insert(0, tweet);
        _isLoading = false;
        notifyListeners();
        return true;
      },
    );
  }

  Future<void> toggleLike(String id) async {
    final index = _tweets.indexWhere((t) => t.id == id);
    if (index == -1) return;

    final tweet = _tweets[index];
    final originalIsLiked = tweet.isLiked;

    // TODO: Optimistic UI
    
    final result = originalIsLiked 
        ? await unlikeTweetUseCase(id) 
        : await likeTweetUseCase(id);

    result.fold(
      (failure) {
        _error = failure.message;
        notifyListeners();
      },
      (_) {
        fetchFeed(); // Refresh to get updated counts
      },
    );
  }

  Future<void> toggleBookmark(String id) async {
    final result = await bookmarkTweetUseCase(id);
    result.fold(
      (failure) {
        _error = failure.message;
        notifyListeners();
      },
      (_) {
        fetchFeed(); // Refresh to get updated bookmark state
      },
    );
  }

  Future<void> toggleRetweet(String id) async {
    final result = await retweetUseCase(id);
    result.fold(
      (failure) {
        _error = failure.message;
        notifyListeners();
      },
      (_) {
        fetchFeed();
      },
    );
  }

  Future<bool> addComment(String id, String content) async {
    final result = await commentTweetUseCase(id, content);
    return result.fold(
      (failure) {
        _error = failure.message;
        notifyListeners();
        return false;
      },
      (comment) {
        fetchFeed(); // In a real app, maybe just add to list if viewing details
        return true;
      },
    );
  }
}
