import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:twizzle/features/search/presentation/providers/search_provider.dart';
import 'package:twizzle/widgets/tweet_card.dart';
import 'package:twizzle/features/auth/domain/entities/user.dart';
import 'package:twizzle/features/tweets/domain/entities/tweet.dart';
import 'package:twizzle/features/search/presentation/widgets/user_search_card.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({Key? key}) : super(key: key);

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> with SingleTickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;
  late TabController _tabController;
  final List<String> _filters = ['top', 'latest', 'people', 'media'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _filters.length, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        final searchProvider = context.read<SearchProvider>();
        searchProvider.setFilter(_filters[_tabController.index]);
        if (_searchController.text.isNotEmpty) {
          searchProvider.performSearch(_searchController.text);
        }
      }
    });

    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    _debounce?.cancel();
    _tabController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    if (_debounce?.isActive ?? false) _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      if (mounted) {
        context.read<SearchProvider>().performSearch(_searchController.text);
      }
    });
    setState(() {}); // For clear button visibility
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final searchProvider = context.watch<SearchProvider>();

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(110),
        child: ClipRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: AppBar(
              backgroundColor: theme.scaffoldBackgroundColor.withOpacity(0.8),
              elevation: 0,
              scrolledUnderElevation: 0,
              title: Container(
                height: 42,
                decoration: BoxDecoration(
                  color: theme.dividerColor.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search Twizzle',
                    hintStyle: TextStyle(color: Colors.grey.shade500),
                    prefixIcon: Icon(Icons.search, color: Colors.grey.shade500, size: 20),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.cancel, size: 20),
                            onPressed: () {
                              _searchController.clear();
                              searchProvider.performSearch('');
                            },
                          )
                        : null,
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(vertical: 10),
                  ),
                  onSubmitted: (value) {
                    searchProvider.performSearch(value);
                  },
                ),
              ),
              bottom: TabBar(
                controller: _tabController,
                indicatorColor: const Color(0xff1DA1F2),
                indicatorWeight: 3,
                labelColor: theme.colorScheme.onSurface,
                unselectedLabelColor: Colors.grey,
                labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                tabs: _filters.map((f) => Tab(text: f.toUpperCase())).toList(),
              ),
            ),
          ),
        ),
      ),
      body: _buildBody(searchProvider),
    );
  }

  Widget _buildBody(SearchProvider provider) {
    if (provider.isLoading && provider.results.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (provider.error.isNotEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.redAccent),
              const SizedBox(height: 16),
              Text(provider.error, textAlign: TextAlign.center),
            ],
          ),
        ),
      );
    }

    if (_searchController.text.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
             Icon(Icons.search, size: 80, color: Colors.grey.withOpacity(0.2)),
             const SizedBox(height: 16),
             const Text(
              'Search for people, topics, or keywords',
              style: TextStyle(color: Colors.grey, fontSize: 16),
            ),
          ],
        ),
      );
    }

    if (provider.results.isEmpty && !provider.isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'No results found',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Try searching for something else',
              style: TextStyle(color: Colors.grey.shade600),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top + 110),
      itemCount: provider.results.length,
      itemBuilder: (context, index) {
        final item = provider.results[index];
        if (item is Tweet) {
          return TweetCard(
            tweet: item,
            onAction: () => provider.performSearch(_searchController.text),
          );
        } else if (item is User) {
          return UserSearchCard(
            user: item,
            isFollowing: item.isFollowing,
            isSelf: item.id == provider.currentUserId,
            onFollowToggle: () => provider.toggleFollow(item.id),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }
}
