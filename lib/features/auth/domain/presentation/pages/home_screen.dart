// lib/presentation/screens/home_feed_screen.dart
import 'package:flutter/material.dart';
import 'package:twizzle/features/auth/domain/entities/tweet.dart';
import 'package:twizzle/widgets/drawer_menu.dart';
import 'package:twizzle/widgets/tweet_card.dart';


class HomeFeedScreen extends StatefulWidget {
  const HomeFeedScreen({Key? key}) : super(key: key);

  @override
  State<HomeFeedScreen> createState() => _HomeFeedScreenState();
}

class _HomeFeedScreenState extends State<HomeFeedScreen> {
  final List<Tweet> _tweets = [];
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _loadTweets();
  }

  Future<void> _loadTweets() async {
    setState(() => _loading = true);
    await Future.delayed(const Duration(milliseconds: 800)); // simulate API
    if (!mounted) return;
    setState(() {
      _tweets.addAll(_dummyTweets());
      _loading = false;
    });
  }

  Future<void> _refresh() async {
    await Future.delayed(const Duration(milliseconds: 500));
    if (!mounted) return;
    setState(() => _tweets.insertAll(0, _dummyTweets()));
  }

  List<Tweet> _dummyTweets() => [
        Tweet(
          id: '1',
          name: 'Alice',
          handle: 'alice',
          time: '2m',
          text: 'Flutter + MongoDB = ❤️',
          avatar: 'https://i.pravatar.cc/150?img=1',
          likes: 12,
          retweets: 3,
          replies: 5,
        ),
        Tweet(
          id: '2',
          name: 'Bob',
          handle: 'bob',
          time: '15m',
          text: 'Just shipped my first app!',
          avatar: 'https://i.pravatar.cc/150?img=2',
          likes: 42,
          retweets: 9,
          replies: 6,
        ),
        Tweet(
          id: '3',
          name: 'Charlie',
          handle: 'charlie',
          time: '1h',
          text: 'Hot reload is magic ⚡',
          avatar: 'https://i.pravatar.cc/150?img=3',
          likes: 15,
          retweets: 4,
          replies: 2,
        ),
      ];

  @override
  Widget build(BuildContext context) {
    final tablet = MediaQuery.of(context).size.shortestSide >= 600;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        centerTitle: true,
        elevation: 0,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(colors: [Color(0xff1DA1F2), Color(0xff0D8BD9)]),
          ),
        ),
      ),
      drawer: const DrawerMenu(),
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: tablet
            ? GridView.builder(
                padding: const EdgeInsets.all(12),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, childAspectRatio: 1.5),
                itemCount: _tweets.length + (_loading ? 1 : 0),
                itemBuilder: (_, i) => i == _tweets.length
                    ? const Center(child: CircularProgressIndicator())
                    : TweetCard(tweet: _tweets[i], onAction: () => setState(() {})),
              )
            : ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                itemCount: _tweets.length + (_loading ? 1 : 0),
                itemBuilder: (_, i) => i == _tweets.length
                    ? const Center(child: CircularProgressIndicator())
                    : TweetCard(tweet: _tweets[i], onAction: () => setState(() {})),
              ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showCompose(context),
        backgroundColor: const Color(0xff1DA1F2),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  void _showCompose(BuildContext ctx) {
    final ctrl = TextEditingController();
    showModalBottomSheet(
      isScrollControlled: true,
      context: ctx,
      builder: (_) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
        child: Container(
          padding: const EdgeInsets.all(20),
          height: 220,
          child: Column(
            children: [
              TextField(
                controller: ctrl,
                maxLines: 4,
                decoration: const InputDecoration(hintText: "What's happening?", border: InputBorder.none),
              ),
              const Spacer(),
              Align(
                alignment: Alignment.centerRight,
                child: ElevatedButton(onPressed: () => Navigator.pop(ctx), child: const Text('Tweet')),
              ),
            ],
          ),
        ),
      ),
    );
  }
}