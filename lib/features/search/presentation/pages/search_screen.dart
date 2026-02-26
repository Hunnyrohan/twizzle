import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:twizzle/features/search/presentation/providers/search_provider.dart';
import 'package:twizzle/widgets/tweet_card.dart';
import 'package:twizzle/features/auth/domain/entities/user.dart';
import 'package:twizzle/features/tweets/domain/entities/tweet.dart';
import 'package:twizzle/core/utils/media_utils.dart';
import 'package:twizzle/widgets/verified_badge.dart';


class SearchScreen extends StatefulWidget {
  const SearchScreen({Key? key}) : super(key: key);

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final searchProvider = context.watch<SearchProvider>();

    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _searchController,
          decoration: const InputDecoration(
            hintText: 'Search Twizzle',
            border: InputBorder.none,
          ),
          onSubmitted: (value) {
            searchProvider.performSearch(value);
          },
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: Column(
            children: [
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: ['top', 'latest', 'people', 'media'].map((filter) {
                    final isSelected = searchProvider.currentFilter == filter;
                    return GestureDetector(
                      onTap: () {
                        searchProvider.setFilter(filter);
                        if (_searchController.text.isNotEmpty) {
                          searchProvider.performSearch(_searchController.text);
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          border: Border(
                            bottom: BorderSide(
                              color: isSelected ? Colors.blue : Colors.transparent,
                              width: 2,
                            ),
                          ),
                        ),
                        child: Text(
                          filter.toUpperCase(),
                          style: TextStyle(
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                            color: isSelected ? Colors.blue : Colors.grey,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
              const Divider(height: 1),
            ],
          ),
        ),
      ),
      body: searchProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : searchProvider.error.isNotEmpty
              ? Center(child: Text(searchProvider.error))
              : searchProvider.results.isEmpty
                  ? const Center(child: Text('Search for people, topics, or keywords'))
                  : ListView.builder(
                      itemCount: searchProvider.results.length,
                      itemBuilder: (context, index) {
                        final item = searchProvider.results[index];
                        if (item is Tweet) {
                          return TweetCard(
                            tweet: item,
                            onAction: () => searchProvider.performSearch(_searchController.text),
                          );
                        } else if (item is User) {
                          return ListTile(
                            leading: CircleAvatar(
                              backgroundImage: (item.image != null && item.image!.isNotEmpty)
                                  ? NetworkImage(MediaUtils.resolveImageUrl(item.image))
                                  : null,
                              child: (item.image == null || item.image!.isEmpty)
                                  ? Text(item.name.isNotEmpty ? item.name[0] : '?')
                                  : null,
                            ),
                            title: Row(
                              children: [
                                Text(item.name),
                                if (item.isVerified) ...[
                                  const SizedBox(width: 4),
                                  const VerifiedBadge(size: 14),
                                ],
                              ],
                            ),
                            subtitle: Text('@${item.username}'),

                          );
                        }
                        return const SizedBox.shrink();
                      },
                    ),
    );
  }
}
