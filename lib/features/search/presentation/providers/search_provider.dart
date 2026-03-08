import 'package:flutter/material.dart';
import 'package:twizzle/features/search/domain/repositories/search_repository.dart';
import 'package:twizzle/features/auth/domain/repositories/user_repository.dart';
import 'package:twizzle/features/auth/domain/entities/user.dart';
import 'package:twizzle/features/auth/data/models/user_model.dart';
import 'package:twizzle/features/tweets/domain/entities/tweet.dart';

class SearchProvider extends ChangeNotifier {
  final SearchRepository repository;
  final UserRepository userRepository;

  SearchProvider({required this.repository, required this.userRepository}) {
    _initCurrentUser();
  }

  List<dynamic> _results = [];
  bool _isLoading = false;
  String _error = '';
  String _currentFilter = 'top';
  String? _currentUserId;

  List<dynamic> get results => _results;
  bool get isLoading => _isLoading;
  String get error => _error;
  String get currentFilter => _currentFilter;
  String? get currentUserId => _currentUserId;

  Future<void> _initCurrentUser() async {
    final res = await userRepository.getCurrentUser();
    res.fold((_) => null, (u) {
      _currentUserId = u?.id;
      notifyListeners();
    });
  }

  void setFilter(String filter) {
    _currentFilter = filter;
    notifyListeners();
  }

  Future<void> performSearch(String query) async {
    if (query.isEmpty) {
      _results = [];
      notifyListeners();
      return;
    }

    _isLoading = true;
    _error = '';
    notifyListeners();

    final result = await repository.search(query: query, filter: _currentFilter);

    result.fold(
      (failure) {
        _error = failure.message;
        _isLoading = false;
        notifyListeners();
      },
      (items) {
        _results = items;
        _isLoading = false;
        notifyListeners();
      },
    );
  }

  Future<void> toggleFollow(String userId) async {
    // Find the user in results and update optimistically
    final index = _results.indexWhere((item) => item is User && item.id == userId);
    if (index == -1) return;

    final user = _results[index] as User;
    final isFollowing = user.isFollowing;
    
    // Optimistic update
    final updatedUser = (user as UserModel).copyWith(
      isFollowing: !isFollowing,
    );
    _results[index] = updatedUser;
    notifyListeners();

    final result = await userRepository.toggleFollow(userId);
    result.fold(
      (failure) {
        // Revert on failure
        _results[index] = user;
        _error = failure.message;
        notifyListeners();
      },
      (data) {
        // Successful toggle
      },
    );
  }
}
