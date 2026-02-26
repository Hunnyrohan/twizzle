import 'package:flutter/material.dart';
import 'package:twizzle/features/search/domain/repositories/search_repository.dart';

class SearchProvider extends ChangeNotifier {
  final SearchRepository repository;

  SearchProvider({required this.repository});

  List<dynamic> _results = [];
  bool _isLoading = false;
  String _error = '';
  String _currentFilter = 'top';

  List<dynamic> get results => _results;
  bool get isLoading => _isLoading;
  String get error => _error;
  String get currentFilter => _currentFilter;

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
}
