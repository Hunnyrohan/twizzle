import 'package:flutter/material.dart';
import 'package:twizzle/features/tweets/domain/entities/tweet.dart';
import 'package:twizzle/features/tweets/domain/usecases/bookmark_tweet.dart';
import 'package:twizzle/features/tweets/domain/usecases/comment_tweet.dart';
import 'package:twizzle/features/tweets/domain/usecases/get_feed.dart';
import 'package:twizzle/features/tweets/domain/usecases/create_tweet.dart';
import 'package:twizzle/features/tweets/domain/usecases/like_tweet.dart';
import 'package:twizzle/features/tweets/domain/usecases/unlike_tweet.dart';
import 'package:twizzle/features/tweets/domain/usecases/retweet.dart';
import 'package:twizzle/features/tweets/domain/usecases/delete_tweet.dart';
import 'package:twizzle/features/auth/domain/usecases/toggle_block.dart';
import 'package:twizzle/features/tweets/domain/usecases/get_tweet_details.dart';
import 'package:twizzle/features/tweets/domain/usecases/get_tweet_comments.dart';
import 'package:twizzle/features/tweets/domain/usecases/get_bookmarks.dart';
import 'package:twizzle/features/tweets/domain/usecases/toggle_not_interested.dart';
import 'package:twizzle/features/tweets/data/models/tweet_model.dart';
import 'package:dartz/dartz.dart';
import 'package:twizzle/core/error/failures.dart';

class TweetProvider with ChangeNotifier {
  final GetFeed getFeedUseCase;
  final CreateTweet createTweetUseCase;
  final LikeTweet likeTweetUseCase;
  final UnlikeTweet unlikeTweetUseCase;
  final Retweet retweetUseCase;
  final BookmarkTweet bookmarkTweetUseCase;
  final CommentTweet commentTweetUseCase;
  final DeleteTweet deleteTweetUseCase;
  final ToggleBlock toggleBlockUseCase;
  final GetTweetDetails getTweetDetailsUseCase;
  final GetTweetComments getTweetCommentsUseCase;
  final GetBookmarks getBookmarksUseCase;
  final ToggleNotInterested toggleNotInterestedUseCase;

  TweetProvider({
    required this.getFeedUseCase,
    required this.createTweetUseCase,
    required this.likeTweetUseCase,
    required this.unlikeTweetUseCase,
    required this.retweetUseCase,
    required this.bookmarkTweetUseCase,
    required this.commentTweetUseCase,
    required this.deleteTweetUseCase,
    required this.toggleBlockUseCase,
    required this.getTweetDetailsUseCase,
    required this.getTweetCommentsUseCase,
    required this.getBookmarksUseCase,
    required this.toggleNotInterestedUseCase,
  });

  List<Tweet> _tweets = [];
  List<Tweet> _bookmarks = [];
  Map<String, Tweet> _cache = {}; // Cache to keep all screens in sync
  bool _isLoading = false;
  String? _error;

  List<Tweet> get tweets => _tweets;
  List<Tweet> get bookmarks => _bookmarks;
  Map<String, Tweet> get cache => _cache;
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
        // Update cache with feed tweets
        for (var t in tweets) {
          _cache[t.id] = t;
        }
        _isLoading = false;
        notifyListeners();
      },
    );
  }

  Future<bool> postTweet(String content, {List<String> mediaPaths = const [], String? location}) async {
    _isLoading = true;
    notifyListeners();

    final result = await createTweetUseCase(content, mediaPaths: mediaPaths, location: location);
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
    final tweet = _cache[id] ?? (index != -1 ? _tweets[index] : null);
    
    if (tweet == null || tweet is! TweetModel) return;

    final originalTweet = tweet;
    final isLiking = !tweet.isLiked;

    // Optimistic Update
    final updatedTweet = tweet.copyWith(
      isLiked: isLiking,
      likesCount: isLiking ? tweet.likesCount + 1 : tweet.likesCount - 1,
    );
    
    if (index != -1) _tweets[index] = updatedTweet;
    _cache[id] = updatedTweet;
    notifyListeners();

    final result = isLiking 
        ? await likeTweetUseCase(id) 
        : await unlikeTweetUseCase(id);

    result.fold(
      (failure) {
        // Rollback
        if (index != -1) _tweets[index] = originalTweet;
        _cache[id] = originalTweet;
        _error = failure.message;
        notifyListeners();
      },
      (_) {
        // Success
      },
    );
  }

  void updateCache(List<Tweet> tweets) {
    for (var t in tweets) {
      _cache[t.id] = t;
    }
    notifyListeners();
  }

  Future<void> toggleBookmark(String id) async {
    final index = _tweets.indexWhere((t) => t.id == id);
    // Even if not in feed, it might be in cache (detail screen)
    final tweet = _cache[id];
    if (tweet == null || tweet is! TweetModel) return;

    final originalTweet = tweet;
    final isBookmarking = !tweet.isBookmarked;

    // Optimistic Update
    final updatedTweet = tweet.copyWith(isBookmarked: isBookmarking);
    if (index != -1) _tweets[index] = updatedTweet;
    _cache[id] = updatedTweet;
    notifyListeners();

    final result = await bookmarkTweetUseCase(id);
    result.fold(
      (failure) {
        // Rollback
        if (index != -1) _tweets[index] = originalTweet;
        _cache[id] = originalTweet;
        _error = failure.message;
        notifyListeners();
      },
      (_) {
        // Success
      },
    );
  }

  Future<void> toggleRetweet(String id) async {
    final index = _tweets.indexWhere((t) => t.id == id);
    final tweet = _cache[id];
    if (tweet == null || tweet is! TweetModel) return;

    final originalTweet = tweet;
    final isRetweeting = !tweet.isRetweeted;

    // Optimistic Update
    final updatedTweet = tweet.copyWith(
      isRetweeted: isRetweeting,
      retweetsCount: isRetweeting ? tweet.retweetsCount + 1 : tweet.retweetsCount - 1,
    );
    if (index != -1) _tweets[index] = updatedTweet;
    _cache[id] = updatedTweet;
    notifyListeners();

    final result = await retweetUseCase(id);
    result.fold(
      (failure) {
        // Rollback
        if (index != -1) _tweets[index] = originalTweet;
        _cache[id] = originalTweet;
        _error = failure.message;
        notifyListeners();
      },
      (_) {
        fetchFeed(); 
      },
    );
  }

  Future<bool> addComment(String id, String content) async {
    final tweet = _cache[id];
    Tweet? originalTweet;
    int index = _tweets.indexWhere((t) => t.id == id);

    if (tweet != null && tweet is TweetModel) {
      originalTweet = tweet;
      // Optimistic Update parent count
      final updated = tweet.copyWith(repliesCount: tweet.repliesCount + 1);
      if (index != -1) _tweets[index] = updated;
      _cache[id] = updated;
      notifyListeners();
    }

    final result = await commentTweetUseCase(id, content);
    return result.fold(
      (failure) {
        if (originalTweet != null) {
          // Rollback
          if (index != -1) _tweets[index] = originalTweet;
          _cache[id] = originalTweet;
          notifyListeners();
        }
        _error = failure.message;
        return false;
      },
      (comment) {
        // Add comment to cache
        _cache[comment.id] = comment;
        notifyListeners();
        return true;
      },
    );
  }

  Future<bool> deleteTweet(String id) async {
    final result = await deleteTweetUseCase(id);
    return result.fold(
      (failure) {
        _error = failure.message;
        notifyListeners();
        return false;
      },
      (_) {
        _tweets.removeWhere((t) => t.id == id);
        notifyListeners();
        return true;
      },
    );
  }

  Future<bool> toggleBlock(String userId) async {
    final result = await toggleBlockUseCase(userId);
    return result.fold(
      (failure) {
        _error = failure.message;
        notifyListeners();
        return false;
      },
      (_) {
        // Remove all tweets from this user after blocking
        _tweets.removeWhere((t) => t.authorId == userId || (t.retweetOf != null && t.retweetOf!.authorId == userId));
        notifyListeners();
        return true;
      },
    );
  }

  Future<void> toggleNotInterested(String tweetId) async {
    // Optimistic Update: Remove from list immediately
    final index = _tweets.indexWhere((t) => t.id == tweetId);
    Tweet? originalTweet;
    if (index != -1) {
       originalTweet = _tweets[index];
       _tweets.removeAt(index);
       notifyListeners();
    }

    final result = await toggleNotInterestedUseCase(tweetId);
    result.fold(
      (failure) {
        // Rollback if failed
        if (originalTweet != null) {
          _tweets.insert(index, originalTweet);
          notifyListeners();
        }
        _error = failure.message;
      },
      (_) {
        // Success: already removed from UI
      },
    );
  }

  Future<Either<Failure, Tweet>> getTweetDetails(String id) async {
    final result = await getTweetDetailsUseCase(id);
    result.fold((_) => null, (tweet) {
      _cache[id] = tweet;
      notifyListeners();
    });
    return result;
  }

  Future<Either<Failure, List<Tweet>>> fetchComments(String id) async {
    final result = await getTweetCommentsUseCase(id);
    result.fold((_) => null, (comments) {
      for (var c in comments) {
        _cache[c.id] = c;
      }
      notifyListeners();
    });
    return result;
  }

  Future<void> fetchBookmarks() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    final result = await getBookmarksUseCase();
    result.fold(
      (failure) {
        _error = failure.message;
        _isLoading = false;
        notifyListeners();
      },
      (tweets) {
        _bookmarks = tweets;
        // Update cache with bookmarks
        for (var t in tweets) {
          _cache[t.id] = t;
        }
        _isLoading = false;
        notifyListeners();
      },
    );
  }
}
