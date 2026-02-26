import 'package:dartz/dartz.dart';
import 'package:twizzle/core/error/failures.dart';
import 'package:twizzle/features/notifications/domain/entities/notification.dart';

abstract class NotificationRepository {
  Future<Either<Failure, List<UserNotification>>> getNotifications();
  Future<Either<Failure, int>> getUnreadCount();
  Future<Either<Failure, void>> markAsRead(String id);
  Future<Either<Failure, void>> markAllAsRead();
}
