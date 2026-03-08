import 'package:hive_flutter/hive_flutter.dart';
import '../../data/models/tweet_model.dart';
import '../../domain/entities/tweet.dart';

class TweetLocalDataSource {
  static const String _tweetBoxName = 'tweetsBox';

  Future<void> cacheFeed(List<Tweet> tweets) async {
    final box = await Hive.openBox(_tweetBoxName);
    final tweetMaps = tweets.map((t) => (t as TweetModel).toJson()).toList();
    await box.put('feed', tweetMaps);
  }

  Future<List<Tweet>> getCachedFeed() async {
    final box = await Hive.openBox(_tweetBoxName);
    final List? cachedData = box.get('feed') as List?;
    if (cachedData != null) {
      return cachedData.map((json) => TweetModel.fromJson(Map<String, dynamic>.from(json))).toList();
    }
    return [];
  }
}
