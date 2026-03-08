import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:twizzle/features/auth/data/datasources/remote/api_remote_source.dart';
import 'package:twizzle/features/tweets/data/datasources/tweet_remote_data_source.dart';

import 'mocks.dart';

class MockResponse extends Mock implements Response {}

void main() {
  late MockDioClient mockDio;
  late ApiRemoteSource authSource;
  late TweetRemoteDataSource tweetSource;

  setUpAll(() {
    setupMocks();
    registerFallbackValue(RequestOptions(path: ''));
  });

  setUp(() {
    mockDio = MockDioClient();
    authSource = ApiRemoteSource(mockDio);
    tweetSource = TweetRemoteDataSource(mockDio);
  });

  group('ApiRemoteSource', () {
    test('should call login endpoint with correct body', () async {
      final response = MockResponse();
      when(() => response.data).thenReturn({'success': true, 'token': 't'});
      when(() => mockDio.post(any(), data: any(named: 'data')))
          .thenAnswer((_) async => response);

      final result = await authSource.login('user', 'pass');

      expect(result['token'], 't');
      verify(() => mockDio.post('auth/login', data: {
        'identifier': 'user',
        'password': 'pass',
        'confirmReactivate': false,
      })).called(1);
    });

    test('should call reset-password endpoint', () async {
      final response = MockResponse();
      when(() => response.data).thenReturn({'message': 'Success'});
      when(() => mockDio.post(any(), data: any(named: 'data')))
          .thenAnswer((_) async => response);

      final result = await authSource.resetPassword('123', 'newPass');

      expect(result['message'], 'Success');
    });
  });

  group('TweetRemoteDataSource', () {
    test('should return list of TweetModels on success', () async {
      final response = MockResponse();
      when(() => response.data).thenReturn({
        'success': true,
        'data': [
          {
            '_id': '1',
            'content': 'Test',
            'author': {'_id': 'u1', 'name': 'N', 'username': 'U'},
            'media': [],
            'createdAt': '2023-01-01T00:00:00.000Z',
          }
        ]
      });
      when(() => mockDio.get(any(), queryParameters: any(named: 'queryParameters'), options: any(named: 'options')))
          .thenAnswer((_) async => response);

      final result = await tweetSource.getFeed();

      expect(result.length, 1);
      expect(result[0].content, 'Test');
    });

    test('should throw exception when success is false', () async {
      final response = MockResponse();
      when(() => response.data).thenReturn({'success': false, 'message': 'Failed'});
      when(() => mockDio.get(any(), queryParameters: any(named: 'queryParameters'), options: any(named: 'options')))
          .thenAnswer((_) async => response);

      expect(() => tweetSource.getFeed(), throwsException);
    });

    test('should call retweet endpoint', () async {
      final response = MockResponse();
      when(() => response.data).thenReturn({'success': true});
      when(() => mockDio.post(any(), options: any(named: 'options')))
          .thenAnswer((_) async => response);

      await tweetSource.retweet('1');
      verify(() => mockDio.post('tweets/1/retweet')).called(1);
    });

    test('should call bookmark endpoint', () async {
      final response = MockResponse();
      when(() => response.data).thenReturn({'success': true});
      when(() => mockDio.post(any(), options: any(named: 'options')))
          .thenAnswer((_) async => response);

      await tweetSource.bookmarkTweet('1');
      verify(() => mockDio.post('tweets/1/bookmark')).called(1);
    });

    test('should return list of tweets for getUserTweets', () async {
      final response = MockResponse();
      when(() => response.data).thenReturn({
        'success': true,
        'data': []
      });
      when(() => mockDio.get(any(), queryParameters: any(named: 'queryParameters'), options: any(named: 'options')))
          .thenAnswer((_) async => response);

      final result = await tweetSource.getUserTweets('username');
      expect(result, isEmpty);
    });

    test('should call createTweet with FormData', () async {
      final response = MockResponse();
      when(() => response.data).thenReturn({
        'success': true,
        'data': {
          '_id': '1',
          'content': 'New',
          'author': {'_id': 'u1', 'name': 'N', 'username': 'U'},
          'media': [],
          'createdAt': '2023-01-01T00:00:00.000Z',
        }
      });
      when(() => mockDio.post(any(), data: any(named: 'data'), options: any(named: 'options')))
          .thenAnswer((_) async => response);

      final result = await tweetSource.createTweet('New', []);
      expect(result.content, 'New');
      verify(() => mockDio.post('tweets', data: any(named: 'data'))).called(1);
    });
  });

  group('AuthSource More', () {
    test('should call getUserProfile endpoint', () async {
      final response = MockResponse();
      when(() => response.data).thenReturn({'success': true, 'id': '1'});
      when(() => mockDio.get(any())).thenAnswer((_) async => response);

      final result = await authSource.getUserProfile('username');
      expect(result['id'], '1');
      verify(() => mockDio.get('users/username')).called(1);
    });

    test('should call toggleFollow endpoint', () async {
      final response = MockResponse();
      when(() => response.data).thenReturn({'success': true});
      when(() => mockDio.post(any())).thenAnswer((_) async => response);

      await authSource.toggleFollow('userId');
      verify(() => mockDio.post('users/userId/follow')).called(1);
    });
    test('should call updateProfile endpoint', () async {
      final response = MockResponse();
      when(() => response.data).thenReturn({'success': true});
      when(() => mockDio.put(any(), data: any(named: 'data')))
          .thenAnswer((_) async => response);

      await authSource.updateProfile(name: 'New Name');
      verify(() => mockDio.put('users/profile', data: {'name': 'New Name'})).called(1);
    });

    test('should call logout-all endpoint', () async {
      final response = MockResponse();
      when(() => response.data).thenReturn({'success': true});
      when(() => mockDio.post(any()))
          .thenAnswer((_) async => response);

      await authSource.logoutAllSessions();
      verify(() => mockDio.post('auth/logout-all')).called(1);
    });
  });
}
