import 'package:dartz/dartz.dart';
import 'package:twizzle/core/error/failures.dart';
import 'package:twizzle/features/notifications/data/models/notification_model.dart';
import 'package:twizzle/features/notifications/domain/entities/notification.dart';
import 'package:twizzle/features/notifications/domain/repositories/notification_repository.dart';
import 'package:twizzle/features/notifications/data/datasources/remote/notification_remote_source.dart';

class NotificationRepositoryImpl implements NotificationRepository {
  final NotificationRemoteSource remoteDataSource;

  NotificationRepositoryImpl(this.remoteDataSource);

  @override
  Future<Either<Failure, List<UserNotification>>> getNotifications() async {
    try {
      final response = await remoteDataSource.getNotifications();
      final List<dynamic> data = response['data']['items'] as List<dynamic>;
      final notifications = data.map((json) => NotificationModel.fromJson(json)).toList();
      return Right(notifications);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, int>> getUnreadCount() async {
    try {
      final response = await remoteDataSource.getUnreadCount();
      return Right(response['data']['count'] as int);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> markAllAsRead() async {
    try {
      await remoteDataSource.markAllAsRead();
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> markAsRead(String id) async {
    try {
      await remoteDataSource.markAsRead(id);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
