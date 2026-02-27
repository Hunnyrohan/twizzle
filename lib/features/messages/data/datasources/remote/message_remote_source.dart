import 'package:dio/dio.dart';
import 'package:twizzle/core/api/dio_client.dart';

class MessageRemoteSource {
  final DioClient _client;

  MessageRemoteSource(this._client);

  Future<Map<String, dynamic>> getConversations() async {
    final res = await _client.get('/messages/conversations');
    return res.data;
  }

  Future<Map<String, dynamic>> getMessages(String conversationId) async {
    final res = await _client.get('/messages/conversations/$conversationId/messages');
    return res.data;
  }

  Future<Map<String, dynamic>> sendMessage(String conversationId, String content) async {
    final res = await _client.post(
      '/messages/conversations/$conversationId/messages',
      data: {'text': content},
    );
    return res.data;
  }

  Future<Map<String, dynamic>> sendImageMessage(String conversationId, String filePath) async {
    final formData = FormData.fromMap({
      'images': await MultipartFile.fromFile(filePath, filename: filePath.split('/').last),
      'type': 'image',
    });
    final res = await _client.post(
      '/messages/conversations/$conversationId/messages',
      data: formData,
    );
    return res.data;
  }

  Future<Map<String, dynamic>> getUnreadCount() async {
    final res = await _client.get('/messages/unread-count');
    return res.data;
  }

  Future<Map<String, dynamic>> markAsRead(String conversationId) async {
    final res = await _client.post('/messages/conversations/$conversationId/read');
    return res.data;
  }

  Future<Map<String, dynamic>> startConversation(String userId) async {
    final res = await _client.post(
      '/messages/conversations',
      data: {'userId': userId},
    );
    return res.data;
  }

  Future<Map<String, dynamic>> deleteMessage(String messageId, String type) async {
    final res = await _client.delete(
      '/messages/$messageId',
      data: {'type': type},
    );
    return res.data;
  }
}
