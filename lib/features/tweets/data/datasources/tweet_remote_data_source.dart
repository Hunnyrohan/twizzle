import 'package:dio/dio.dart';
import 'package:twizzle/core/api/dio_client.dart';
import '../models/tweet_model.dart';

class TweetRemoteDataSource {
  final DioClient _client;

  TweetRemoteDataSource(this._client);

  Future<List<TweetModel>> getFeed({String? userId, String? filter}) async {
    final response = await _client.get(
      'tweets',
      queryParameters: {
        if (userId != null) 'author': userId,
        if (filter != null) 'filter': filter,
      },
    );
    
    if (response.data['success'] == true) {
      final List<dynamic> list = response.data['data'];
      return list.map((json) => TweetModel.fromJson(json)).toList();
    } else {
      throw Exception(response.data['message'] ?? 'Failed to get feed');
    }
  }

  Future<List<TweetModel>> getUserTweets(String username, {String? filter}) async {
    final response = await _client.get(
      'users/$username/tweets',
       queryParameters: {
        if (filter != null) 'filter': filter,
      },
    );

    if (response.data['success'] == true) {
      final List<dynamic> list = response.data['data'];
      return list.map((json) => TweetModel.fromJson(json)).toList();
    } else {
      throw Exception(response.data['message'] ?? 'Failed to get user tweets');
    }
  }

  Future<List<TweetModel>> getUserLikes(String username) async {
    final response = await _client.get(
      'users/$username/likes',
    );

    if (response.data['success'] == true) {
      final List<dynamic> list = response.data['data'];
      return list.map((json) => TweetModel.fromJson(json)).toList();
    } else {
      throw Exception(response.data['message'] ?? 'Failed to get likes');
    }
  }

  Future<TweetModel> createTweet(String content, List<String> mediaPaths, {String? location}) async {
    final formData = FormData.fromMap({
      'content': content,
      if (location != null) 'location': location,
      if (mediaPaths.isNotEmpty)
        'media': await Future.wait(mediaPaths.map((path) => MultipartFile.fromFile(path))),
    });

    final response = await _client.post(
      'tweets',
      data: formData,
    );

    if (response.data['success'] == true) {
      return TweetModel.fromJson(response.data['data']);
    } else {
      throw Exception(response.data['message'] ?? 'Failed to create tweet');
    }
  }

  Future<void> likeTweet(String id) async {
    await _client.post(
      'tweets/$id/like',
    );
  }

  Future<void> unlikeTweet(String id) async {
    await _client.delete(
      'tweets/$id/like',
    );
  }

  Future<void> retweet(String id) async {
    await _client.post(
      'tweets/$id/retweet',
    );
  }

  Future<void> bookmarkTweet(String id) async {
    await _client.post(
      'tweets/$id/bookmark',
    );
  }

  Future<List<TweetModel>> getBookmarks() async {
    final response = await _client.get(
      'bookmarks',
    );

    if (response.data['success'] == true) {
      // Backend returns { items: [], nextCursor: ... }
      final List<dynamic> list = response.data['data']['items'] ?? [];
      return list.map((json) => TweetModel.fromJson(json)).toList();
    } else {
      throw Exception(response.data['message'] ?? 'Failed to get bookmarks');
    }
  }

  Future<TweetModel> commentTweet(String id, String content) async {
    final response = await _client.post(
      'tweets/$id/comments',
      data: {'content': content},
    );

    if (response.data['success'] == true) {
      return TweetModel.fromJson(response.data['data']);
    } else {
      throw Exception(response.data['message'] ?? 'Failed to comment');
    }
  }

  Future<void> deleteTweet(String id) async {
    await _client.delete(
      'tweets/$id',
    );
  }

  Future<TweetModel> getTweetDetails(String id) async {
    final response = await _client.get('tweets/$id');
    if (response.data['success'] == true) {
      return TweetModel.fromJson(response.data['data']);
    } else {
      throw Exception(response.data['message'] ?? 'Failed to get tweet details');
    }
  }

  Future<List<TweetModel>> getTweetComments(String id) async {
    final response = await _client.get('tweets/$id/comments');
    if (response.data['success'] == true) {
      // Backend returns { items: [], nextCursor: ... }
      final List<dynamic> list = response.data['data']['items'] ?? [];
      return list.map((json) => TweetModel.fromJson(json)).toList();
    } else {
      throw Exception(response.data['message'] ?? 'Failed to get tweet comments');
    }
  }

  Future<void> toggleNotInterested(String tweetId) async {
    final response = await _client.post(
      'not-interested/$tweetId',
    );
    
    if (response.data['success'] != true) {
      throw Exception(response.data['message'] ?? 'Failed to toggle not interested');
    }
  }
}
