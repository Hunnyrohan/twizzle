import 'dart:async';
import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:twizzle/features/auth/domain/presentation/providers/user_provider.dart';
import 'package:twizzle/core/utils/media_utils.dart';
import 'package:twizzle/widgets/custom_image.dart';
import 'package:twizzle/features/tweets/presentation/providers/tweet_provider.dart';
import 'package:twizzle/widgets/drawer_menu.dart';
import 'package:twizzle/widgets/tweet_card.dart';
import 'package:twizzle/features/tweets/presentation/widgets/tweet_composer.dart';

class HomeFeedScreen extends StatefulWidget {
  const HomeFeedScreen({Key? key}) : super(key: key);

  @override
  State<HomeFeedScreen> createState() => _HomeFeedScreenState();
}

class _HomeFeedScreenState extends State<HomeFeedScreen> {
  // ── Shake detection ────────────────────────────────────────────────────────
  StreamSubscription<AccelerometerEvent>? _accelerometerSub;
  DateTime _lastShakeTime = DateTime.now();
  static const double _shakeThreshold = 15.0; // m/s² — sensitivity

  @override
  void initState() {
    super.initState();
    Future.microtask(() => context.read<TweetProvider>().fetchFeed());
    _startShakeDetection();
  }

  void _startShakeDetection() {
    _accelerometerSub = accelerometerEventStream().listen((event) {
      final double acceleration =
          sqrt(event.x * event.x + event.y * event.y + event.z * event.z) - 9.8;
      if (acceleration > _shakeThreshold) {
        final now = DateTime.now();
        // Throttle: only trigger once every 2 seconds
        if (now.difference(_lastShakeTime).inSeconds > 2) {
          _lastShakeTime = now;
          _onShake();
        }
      }
    });
  }

  void _onShake() {
    if (!mounted) return;
    context.read<TweetProvider>().fetchFeed();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(
          children: [
            Icon(Icons.refresh, color: Colors.white),
            SizedBox(width: 8),
            Text('Feed refreshed! 🎉'),
          ],
        ),
        backgroundColor: const Color(0xff1DA1F2),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  void dispose() {
    _accelerometerSub?.cancel();
    super.dispose();
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
              backgroundColor: theme.scaffoldBackgroundColor.withOpacity(0.85),
              elevation: 0,
              scrolledUnderElevation: 0,
              bottom: PreferredSize(
                preferredSize: const Size.fromHeight(1.0),
                child: Container(
                  color: Colors.grey.withOpacity(0.15),
                  height: 1.0,
                ),
              ),
              title: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.25),
                      blurRadius: 12,
                      spreadRadius: 2,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ClipOval(
                  child: Image.asset(
                    'assets/images/app_logo.jpeg',
                    height: 42,
                    width: 42,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) =>
                        const Text('Twizzle', style: TextStyle(fontWeight: FontWeight.w900)),
                  ),
                ),
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
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.25),
                            blurRadius: 12,
                            spreadRadius: 2,
                            offset: const Offset(0, 4),
                          ),
                        ],
                        border: Border.all(color: Colors.white, width: 2.5),
                      ),
                      child: ClipOval(
                        child: user?.image != null
                            ? CustomImage(
                                imageUrl: MediaUtils.resolveImageUrl(user!.image!),
                                width: 36,
                                height: 36,
                              )
                            : const CircleAvatar(
                                radius: 18,
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
                  icon: const Icon(
                    Icons.auto_awesome,
                    size: 30,
                    color: Color(0xff1DA1F2),
                    shadows: [
                      Shadow(
                        color: Colors.black26,
                        blurRadius: 6,
                        offset: Offset(0, 2),
                      )
                    ],
                  ),
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
                  const Center(
                    child: Text(
                      "Welcome to Twizzle!\nStart following people or post your first tweet.",
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () => provider.fetchFeed(),
            color: const Color(0xff1DA1F2),
            child: ListView.builder(
              padding: EdgeInsets.only(
                  top: MediaQuery.of(context).padding.top + kToolbarHeight),
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
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const TweetComposer(),
    );
  }
}
