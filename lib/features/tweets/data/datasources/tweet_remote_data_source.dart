import 'package:dio/dio.dart';
import 'package:twizzle/core/api/dio_client.dart';
import '../models/tweet_model.dart';

class TweetRemoteDataSource {
  final DioClient _client;

  TweetRemoteDataSource(this._client);

  Future<List<TweetModel>> getFeed({String? userId, String? filter, String? token}) async {
    final response = await _client.get(
      '/tweets',
      queryParameters: {
        if (userId != null) 'author': userId,
        if (filter != null) 'filter': filter,
      },
      options: token != null ? Options(headers: {'Authorization': 'Bearer $token'}) : null,
    );
    
    if (response.data['success'] == true) {
      final List<dynamic> list = response.data['data'];
      return list.map((json) => TweetModel.fromJson(json)).toList();
    } else {
      throw Exception(response.data['message'] ?? 'Failed to get feed');
    }
  }

  Future<List<TweetModel>> getUserLikes(String username, {String? token}) async {
    final response = await _client.get(
      '/users/$username/likes',
      options: token != null ? Options(headers: {'Authorization': 'Bearer $token'}) : null,
    );

    if (response.data['success'] == true) {
      final List<dynamic> list = response.data['data'];
      return list.map((json) => TweetModel.fromJson(json)).toList();
    } else {
      throw Exception(response.data['message'] ?? 'Failed to get likes');
    }
  }

  Future<TweetModel> createTweet(String content, List<String> mediaPaths, String token) async {
    final formData = FormData.fromMap({
      'content': content,
      if (mediaPaths.isNotEmpty)
        'media': await Future.wait(mediaPaths.map((path) => MultipartFile.fromFile(path))),
    });

    final response = await _client.post(
      '/tweets',
      data: formData,
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );

    if (response.data['success'] == true) {
      return TweetModel.fromJson(response.data['data']);
    } else {
      throw Exception(response.data['message'] ?? 'Failed to create tweet');
    }
  }

  Future<void> likeTweet(String id, String token) async {
    await _client.post(
      '/tweets/$id/like',
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );
  }

  Future<void> unlikeTweet(String id, String token) async {
    await _client.delete(
      '/tweets/$id/like',
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );
  }

  Future<void> retweet(String id, String token) async {
    await _client.post(
      '/tweets/$id/retweet',
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );
  }

  Future<void> bookmarkTweet(String id, String token) async {
    await _client.post(
      '/tweets/$id/bookmark',
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );
  }

  Future<TweetModel> commentTweet(String id, String content, String token) async {
    final response = await _client.post(
      '/tweets/$id/comment',
      data: {'content': content},
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );

    if (response.data['success'] == true) {
      return TweetModel.fromJson(response.data['data']);
    } else {
      throw Exception(response.data['message'] ?? 'Failed to comment');
    }
  }
}
