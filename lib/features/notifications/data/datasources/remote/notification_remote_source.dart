import 'package:twizzle/core/api/dio_client.dart';

class NotificationRemoteSource {
  final DioClient _client;

  NotificationRemoteSource(this._client);

  Future<Map<String, dynamic>> getNotifications() async {
    final res = await _client.get('notifications');
    return res.data;
  }

  Future<Map<String, dynamic>> getUnreadCount() async {
    final res = await _client.get('notifications/unread-count');
    return res.data;
  }

  Future<Map<String, dynamic>> markAsRead(String id) async {
    final res = await _client.post('notifications/$id/read');
    return res.data;
  }

  Future<Map<String, dynamic>> markAllAsRead() async {
    final res = await _client.post('notifications/read-all');
    return res.data;
  }
}
