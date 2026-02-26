import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:twizzle/features/auth/domain/presentation/providers/user_provider.dart';
import 'package:twizzle/core/utils/media_utils.dart';
import 'package:twizzle/widgets/custom_image.dart';
import 'package:twizzle/features/tweets/presentation/providers/tweet_provider.dart';
import 'package:twizzle/widgets/drawer_menu.dart';
import 'package:twizzle/widgets/tweet_card.dart';

class HomeFeedScreen extends StatefulWidget {
  const HomeFeedScreen({Key? key}) : super(key: key);

  @override
  State<HomeFeedScreen> createState() => _HomeFeedScreenState();
}

class _HomeFeedScreenState extends State<HomeFeedScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(
      () => context.read<TweetProvider>().fetchFeed(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: ClipRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: AppBar(
              backgroundColor: theme.scaffoldBackgroundColor.withOpacity(0.7),
              elevation: 0,
              scrolledUnderElevation: 0,
              title: Image.asset(
                'assets/images/applogo.png', 
                height: 26, 
                errorBuilder: (_, __, ___) => const Text('Twizzle', style: TextStyle(fontWeight: FontWeight.w900)),
              ),
              centerTitle: true,
              leading: Builder(
                builder: (context) {
                  final user = context.watch<UserProvider>().user;
                  return IconButton(
                    padding: const EdgeInsets.only(left: 12),
                    icon: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.grey.withOpacity(0.2), width: 1),
                      ),
                      child: ClipOval(
                        child: user?.image != null
                            ? CustomImage(
                                imageUrl: MediaUtils.resolveImageUrl(user!.image!),
                                width: 34,
                                height: 34,
                              )
                            : const CircleAvatar(
                                radius: 17,
                                backgroundColor: Color(0xff1DA1F2),
                                child: Icon(Icons.person, size: 20, color: Colors.white),
                              ),
                      ),
                    ),
                    onPressed: () => Scaffold.of(context).openDrawer(),
                  );
                },
              ),
              actions: [
                IconButton(
                  padding: const EdgeInsets.only(right: 12),
                  icon: const Icon(Icons.auto_awesome_outlined, size: 24),
                  onPressed: () {},
                ),
              ],
            ),
          ),
        ),
      ),
      drawer: const DrawerMenu(),
      body: Consumer<TweetProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading && provider.tweets.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.error != null && provider.tweets.isEmpty) {
            return RefreshIndicator(
              onRefresh: () => provider.fetchFeed(),
              child: ListView(
                children: [
                   SizedBox(height: MediaQuery.of(context).size.height * 0.4),
                   Center(child: Text(provider.error!, textAlign: TextAlign.center)),
                ],
              ),
            );
          }

          if (provider.tweets.isEmpty) {
            return RefreshIndicator(
               onRefresh: () => provider.fetchFeed(),
               child: ListView(
                 children: [
                    SizedBox(height: MediaQuery.of(context).size.height * 0.4),
                    const Center(child: Text("Welcome to Twizzle!\nStart following people or post your first tweet.", textAlign: TextAlign.center)),
                 ],
               ),
            );
          }

          return RefreshIndicator(
            onRefresh: () => provider.fetchFeed(),
            color: const Color(0xff1DA1F2),
            child: ListView.builder(
              padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top + kToolbarHeight),
              itemCount: provider.tweets.length,
              itemBuilder: (context, index) {
                final tweet = provider.tweets[index];
                return TweetCard(
                  tweet: tweet,
                  onAction: () => provider.fetchFeed(),
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xff4db5f5), Color(0xff1DA1F2)],
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xff1DA1F2).withOpacity(0.3),
              blurRadius: 15,
              spreadRadius: 2,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: FloatingActionButton(
          onPressed: () => _showCompose(context),
          backgroundColor: Colors.transparent,
          elevation: 0,
          highlightElevation: 0,
          shape: const CircleBorder(),
          child: const Icon(Icons.add, color: Colors.white, size: 30),
        ),
      ),
    );
  }

  void _showCompose(BuildContext context) {
    final controller = TextEditingController();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text('Cancel', style: TextStyle(color: Theme.of(context).colorScheme.onSurface)),
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      if (controller.text.isNotEmpty) {
                        final success = await context.read<TweetProvider>().postTweet(controller.text);
                        if (success) {
                          Navigator.pop(context);
                        }
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xff1DA1F2),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: const Text('Tweet', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipOval(
                    child: context.read<UserProvider>().user?.image != null
                        ? CustomImage(
                            imageUrl: MediaUtils.resolveImageUrl(context.read<UserProvider>().user!.image!),
                            width: 40,
                            height: 40,
                          )
                        : const CircleAvatar(radius: 20, child: Icon(Icons.person)),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: controller,
                      maxLines: null,
                      autofocus: true,
                      decoration: const InputDecoration(
                        hintText: "What's happening?",
                        border: InputBorder.none,
                      ),
                      style: const TextStyle(fontSize: 18),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
