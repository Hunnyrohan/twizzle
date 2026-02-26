import 'package:flutter/material.dart';
import 'package:twizzle/features/notifications/domain/entities/notification.dart';
import 'package:twizzle/features/notifications/domain/repositories/notification_repository.dart';

class NotificationProvider extends ChangeNotifier {
  final NotificationRepository repository;

  NotificationProvider({required this.repository});

  List<UserNotification> _notifications = [];
  int _unreadCount = 0;
  bool _isLoading = false;
  String _error = '';

  List<UserNotification> get notifications => _notifications;
  int get unreadCount => _unreadCount;
  bool get isLoading => _isLoading;
  String get error => _error;

  Future<void> loadNotifications() async {
    _isLoading = true;
    _error = '';
    notifyListeners();

    final result = await repository.getNotifications();
    result.fold(
      (failure) {
        _error = failure.message;
        _isLoading = false;
        notifyListeners();
      },
      (list) {
        _notifications = list;
        _isLoading = false;
        notifyListeners();
        getUnreadCount();
      },
    );
  }

  Future<void> getUnreadCount() async {
    final result = await repository.getUnreadCount();
    result.fold(
      (failure) => null,
      (count) {
        _unreadCount = count;
        notifyListeners();
      },
    );
  }

  Future<void> markAsRead(String id) async {
    final result = await repository.markAsRead(id);
    result.fold(
      (failure) => null,
      (_) {
        loadNotifications();
      },
    );
  }

  Future<void> markAllAsRead() async {
    final result = await repository.markAllAsRead();
    result.fold(
      (failure) => null,
      (_) => loadNotifications(),
    );
  }
}
