import 'package:flutter/material.dart';
import 'package:twizzle/features/auth/domain/entities/user.dart';
import 'package:twizzle/features/auth/data/models/user_model.dart';
import 'package:twizzle/features/auth/domain/repositories/user_repository.dart';
import 'package:twizzle/features/tweets/domain/repositories/tweet_repository.dart';
import 'package:twizzle/features/tweets/domain/entities/tweet.dart';
import 'package:twizzle/features/tweets/presentation/providers/tweet_provider.dart';
import 'package:twizzle/features/auth/domain/presentation/providers/user_provider.dart';

class ProfileProvider with ChangeNotifier {
  final UserRepository userRepository;
  final TweetRepository tweetRepository;
  final TweetProvider? tweetProvider;
  final UserProvider userProvider;

  ProfileProvider({
    required this.userRepository,
    required this.tweetRepository,
    required this.userProvider,
    this.tweetProvider,
  });

  User? _profileUser;
  User? get profileUser => _profileUser;

  List<Tweet> _userTweets = [];
  List<Tweet> get userTweets => _userTweets;

  List<Tweet> _userReplies = [];
  List<Tweet> get userReplies => _userReplies;

  List<Tweet> _userMedia = [];
  List<Tweet> get userMedia => _userMedia;

  List<Tweet> _likedTweets = [];
  List<Tweet> get likedTweets => _likedTweets;

  List<User> _followers = [];
  List<User> get followers => _followers;

  List<User> _following = [];
  List<User> get following => _following;

  int _activeTab = 0;
  int get activeTab => _activeTab;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String _error = '';
  String get error => _error;

  Future<void> loadProfile(String username) async {
    _isLoading = true;
    notifyListeners();

    final result = await userRepository.getUserProfile(username);
    result.fold(
      (failure) {
        _error = failure.message;
        _isLoading = false;
        notifyListeners();
      },
      (user) {
        _profileUser = user;
        _isLoading = false;
        notifyListeners();
        // Automatically load initial tweets
        loadUserTweets(username);
      },
    );
  }

  Future<void> loadUserTweets(String username) async {
    final result = await tweetRepository.getUserTweets(username);
    result.fold((_) => null, (tweets) {
      _userTweets = tweets;
      notifyListeners();
    });
  }

  void setActiveTab(int index) {
    if (_activeTab == index) return;
    _activeTab = index;
    notifyListeners();
    
    if (_profileUser != null) {
      final username = _profileUser!.username;
      switch (index) {
        case 0: if (_userTweets.isEmpty) loadUserTweets(username); break;
        case 1: if (_userReplies.isEmpty) loadUserReplies(username); break;
        case 2: if (_userMedia.isEmpty) loadUserMedia(username); break;
        case 3: if (_likedTweets.isEmpty) loadUserLikes(username); break;
      }
    }
  }

  Future<void> loadUserReplies(String username) async {
    final result = await tweetRepository.getUserTweets(username, filter: 'replies');
    result.fold((_) => null, (tweets) {
      _userReplies = tweets;
      notifyListeners();
    });
  }

  Future<void> loadUserMedia(String username) async {
    final result = await tweetRepository.getUserTweets(username, filter: 'media');
    result.fold((_) => null, (tweets) {
      _userMedia = tweets;
      notifyListeners();
    });
  }

  Future<void> loadUserLikes(String username) async {
    final result = await tweetRepository.getUserLikes(username);
    result.fold((_) => null, (tweets) {
      _likedTweets = tweets;
      notifyListeners();
    });
  }

  Future<void> loadFollowers(String username) async {
    _isLoading = true;
    notifyListeners();
    final result = await userRepository.getFollowers(username);
    result.fold(
      (failure) {
        _error = failure.message;
        _isLoading = false;
        notifyListeners();
      },
      (users) {
        _followers = users;
        _isLoading = false;
        notifyListeners();
      },
    );
  }

  Future<void> loadFollowing(String username) async {
    _isLoading = true;
    notifyListeners();
    final result = await userRepository.getFollowing(username);
    result.fold(
      (failure) {
        _error = failure.message;
        _isLoading = false;
        notifyListeners();
      },
      (users) {
        _following = users;
        _isLoading = false;
        notifyListeners();
      },
    );
  }

  Future<void> toggleFollow() async {
    if (_profileUser == null) return;
    
    // Optimistic Update
    final originalUser = _profileUser!;
    final bool willBeFollowing = !originalUser.isFollowing;
    
    _profileUser = (originalUser as UserModel).copyWith(
      isFollowing: willBeFollowing,
      followersCount: originalUser.followersCount + (willBeFollowing ? 1 : -1),
    );
    notifyListeners();

    final result = await userRepository.toggleFollow(originalUser.id);
    
    result.fold(
      (failure) {
        // Rollback on failure
        _profileUser = originalUser;
        _error = failure.message;
        notifyListeners();
      },
      (data) {
        // Success: refresh counts for global user (drawer)
        userProvider.refreshUserStatus();
      },
    );
  }

  Future<void> toggleFollowUser(User user) async {
    // Optimistic Update in lists
    final bool willBeFollowing = !user.isFollowing;
    
    // Update in followers list
    final followerIndex = _followers.indexWhere((u) => u.id == user.id);
    if (followerIndex != -1) {
      _followers[followerIndex] = (user as UserModel).copyWith(isFollowing: willBeFollowing);
    }

    // Update in following list
    final followingIndex = _following.indexWhere((u) => u.id == user.id);
    if (followingIndex != -1) {
      _following[followingIndex] = (user as UserModel).copyWith(isFollowing: willBeFollowing);
    }
    
    // Also update profile user if it's the same person
    if (_profileUser?.id == user.id) {
       _profileUser = (user as UserModel).copyWith(
        isFollowing: willBeFollowing,
        followersCount: user.followersCount + (willBeFollowing ? 1 : -1),
      );
    }

    notifyListeners();

    final result = await userRepository.toggleFollow(user.id);
    
    result.fold(
      (failure) {
        // Rollback (simplest is to just reload lists or revert manually)
        _error = failure.message;
        notifyListeners();
      },
      (data) {
        // Success: refresh counts for global user (drawer)
        userProvider.refreshUserStatus();
      },
    );
  }
}
