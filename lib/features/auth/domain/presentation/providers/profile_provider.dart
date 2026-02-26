import 'package:flutter/material.dart';
import 'package:twizzle/features/auth/domain/entities/user.dart';
import 'package:twizzle/features/auth/domain/repositories/user_repository.dart';
import 'package:twizzle/features/tweets/domain/repositories/tweet_repository.dart';
import 'package:twizzle/features/tweets/domain/entities/tweet.dart';

class ProfileProvider with ChangeNotifier {
  final UserRepository userRepository;
  final TweetRepository tweetRepository;

  ProfileProvider({
    required this.userRepository,
    required this.tweetRepository,
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

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String _error = '';
  String get error => _error;

  int _activeTab = 0; // 0: Posts, 1: Replies, 2: Media, 3: Likes
  int get activeTab => _activeTab;

  void setActiveTab(int index) {
    _activeTab = index;
    if (_profileUser != null) {
      if (index == 1 && _userReplies.isEmpty) fetchUserReplies(_profileUser!.id);
      if (index == 2 && _userMedia.isEmpty) fetchUserMedia(_profileUser!.id);
      if (index == 3 && _likedTweets.isEmpty) fetchLikedTweets(_profileUser!.username);
    }
    notifyListeners();
  }

  Future<void> loadProfile(String username) async {
    _isLoading = true;
    _error = '';
    notifyListeners();

    final result = await userRepository.getUserProfile(username);
    
    result.fold(
      (failure) {
        _error = failure.message;
        _isLoading = false;
        notifyListeners();
      },
      (user) async {
        _profileUser = user;
        // Reset lists for new profile
        _userTweets = [];
        _userReplies = [];
        _userMedia = [];
        _likedTweets = [];
        _activeTab = 0;
        
        // Load initial posts
        await fetchUserTweets(user.id);
        _isLoading = false;
        notifyListeners();
      },
    );
  }

  Future<void> fetchUserTweets(String userId) async {
    _isLoading = true;
    notifyListeners();

    final result = await tweetRepository.getFeed(userId: userId);
    result.fold(
      (failure) {
        _error = failure.message;
        _isLoading = false;
        notifyListeners();
      },
      (tweets) {
        _userTweets = tweets;
        _isLoading = false;
        notifyListeners();
      },
    );
  }

  Future<void> fetchUserReplies(String userId) async {
    _isLoading = true;
    notifyListeners();

    final result = await tweetRepository.getFeed(userId: userId, filter: 'replies');
    result.fold(
      (failure) {
        _error = failure.message;
        _isLoading = false;
        notifyListeners();
      },
      (tweets) {
        _userReplies = tweets;
        _isLoading = false;
        notifyListeners();
      },
    );
  }

  Future<void> fetchUserMedia(String userId) async {
    _isLoading = true;
    notifyListeners();

    final result = await tweetRepository.getFeed(userId: userId, filter: 'media');
    result.fold(
      (failure) {
        _error = failure.message;
        _isLoading = false;
        notifyListeners();
      },
      (tweets) {
        _userMedia = tweets;
        _isLoading = false;
        notifyListeners();
      },
    );
  }

  Future<void> fetchLikedTweets(String username) async {
    _isLoading = true;
    notifyListeners();

    final result = await tweetRepository.getUserLikes(username);
    result.fold(
      (failure) {
        _error = failure.message;
        _isLoading = false;
        notifyListeners();
      },
      (tweets) {
        _likedTweets = tweets;
        _isLoading = false;
        notifyListeners();
      },
    );
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
    
    final userId = _profileUser!.id;
    final result = await userRepository.toggleFollow(userId);
    
    result.fold(
      (failure) {
        _error = failure.message;
        notifyListeners();
      },
      (data) {
        loadProfile(_profileUser!.username);
      },
    );
  }
}
