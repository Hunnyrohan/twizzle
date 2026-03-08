import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:twizzle/features/tweets/presentation/providers/tweet_provider.dart';
import 'package:twizzle/widgets/tweet_card.dart';

class BookmarksScreen extends StatefulWidget {
  const BookmarksScreen({Key? key}) : super(key: key);

  @override
  State<BookmarksScreen> createState() => _BookmarksScreenState();
}

class _BookmarksScreenState extends State<BookmarksScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(
      () => context.read<TweetProvider>().fetchBookmarks(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        title: const Text('Bookmarks', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: theme.colorScheme.surface,
        elevation: 0,
        centerTitle: true,
      ),
      body: Consumer<TweetProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading && provider.bookmarks.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.error != null && provider.bookmarks.isEmpty) {
            return RefreshIndicator(
              onRefresh: () => provider.fetchBookmarks(),
              child: ListView(
                children: [
                  SizedBox(height: MediaQuery.of(context).size.height * 0.3),
                  Center(child: Text(provider.error!)),
                ],
              ),
            );
          }

          if (provider.bookmarks.isEmpty) {
            return RefreshIndicator(
              onRefresh: () => provider.fetchBookmarks(),
              child: ListView(
                children: [
                   SizedBox(height: MediaQuery.of(context).size.height * 0.3),
                   const Padding(
                     padding: EdgeInsets.symmetric(horizontal: 40),
                     child: Column(
                       children: [
                         Text(
                           'Save Posts for later',
                           style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                           textAlign: TextAlign.center,
                         ),
                         SizedBox(height: 8),
                         Text(
                           'Don’t let the good ones fly away! Bookmark Posts to easily find them again in the future.',
                           style: TextStyle(color: Colors.grey),
                           textAlign: TextAlign.center,
                         ),
                       ],
                     ),
                   ),
                ],
              ),
            );
          }

          final bookmarkedTweets = provider.bookmarks;

          return RefreshIndicator(
            onRefresh: () => provider.fetchBookmarks(),
            child: ListView.builder(
              itemCount: bookmarkedTweets.length,
              itemBuilder: (context, index) {
                final tweet = bookmarkedTweets[index];
                // Use reactive version from cache
                final reactiveTweet = provider.cache[tweet.id] ?? tweet;
                
                // If the reactive version says it's NO LONGER bookmarked, 
                // we still show it in the list for now but it might disappear on refresh
                // or we could filter it out here if we wanted immediate removal.
                if (!reactiveTweet.isBookmarked) {
                  return const SizedBox.shrink();
                }

                return TweetCard(
                  tweet: reactiveTweet,
                  onAction: () => provider.fetchBookmarks(),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
