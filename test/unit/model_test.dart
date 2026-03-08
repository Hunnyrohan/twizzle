import 'package:flutter_test/flutter_test.dart';
import 'package:twizzle/features/auth/data/models/user_model.dart';
import 'package:twizzle/features/tweets/data/models/tweet_model.dart';

void main() {
  group('UserModel', () {
    final tUserJson = {
      '_id': '1',
      'name': 'Test User',
      'username': 'testuser',
      'email': 'test@example.com',
      'token': 'test-token',
      'image': 'avatar-url',
      'bio': 'User bio',
      'location': 'User location',
      'website': 'user.com',
      'followersCount': 10,
      'followingCount': 20,
      'isVerified': true,
      'createdAt': '2023-01-01T00:00:00.000Z',
    };

    test('should return a valid model from JSON', () {
      final result = UserModel.fromJson(tUserJson);
      expect(result.id, '1');
      expect(result.name, 'Test User');
      expect(result.email, 'test@example.com');
      expect(result.token, 'test-token');
    });

    test('should return a JSON map containing proper data', () {
      final model = UserModel.fromJson(tUserJson);
      final result = model.toJson();
      expect(result['id'], '1');
      expect(result['name'], 'Test User');
      expect(result['username'], 'testuser');
    });
  });

  group('TweetModel', () {
    final tTweetJson = {
      '_id': '101',
      'content': 'Hello Twizzle!',
      'author': {
        '_id': '1',
        'name': 'Test User',
        'username': 'testuser',
        'image': 'avatar-url',
        'isVerified': true,
      },
      'media': ['image1.jpg'],
      'likesCount': 5,
      'retweetsCount': 2,
      'repliesCount': 1,
      'createdAt': '2023-01-01T00:00:10.000Z',
      'isLiked': true,
      'location': '27.67, 85.35',
    };

    test('should return a valid model from JSON', () {
      final result = TweetModel.fromJson(tTweetJson);
      expect(result.id, '101');
      expect(result.content, 'Hello Twizzle!');
      expect(result.authorId, '1');
      expect(result.authorName, 'Test User');
      expect(result.likesCount, 5);
      expect(result.location, '27.67, 85.35');
    });

    test('should return a JSON map containing proper data', () {
      final model = TweetModel.fromJson(tTweetJson);
      final result = model.toJson();
      expect(result['id'], '101');
      expect(result['content'], 'Hello Twizzle!');
      expect(result['author']['id'], '1');
      expect(result['location'], '27.67, 85.35');
    });
  });
}
