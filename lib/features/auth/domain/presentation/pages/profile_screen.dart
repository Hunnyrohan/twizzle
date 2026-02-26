import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:twizzle/features/auth/domain/presentation/providers/user_provider.dart';
import 'package:twizzle/features/auth/domain/presentation/providers/profile_provider.dart';
import 'package:twizzle/features/tweets/presentation/providers/tweet_provider.dart';
import 'package:twizzle/widgets/verified_badge.dart';
import 'package:twizzle/widgets/tweet_card.dart';
import 'package:twizzle/features/tweets/domain/entities/tweet.dart';
import 'package:twizzle/features/messages/presentation/providers/message_provider.dart';
import 'package:twizzle/core/utils/media_utils.dart';
import 'package:twizzle/widgets/custom_image.dart';
import 'package:intl/intl.dart';

class ProfileScreen extends StatefulWidget {
  final String? username;
  const ProfileScreen({Key? key, this.username}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    // 4 tabs: Posts, Replies, Media, Likes
    _tabController = TabController(length: 4, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        context.read<ProfileProvider>().setActiveTab(_tabController.index);
      }
    });
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final targetUsername = widget.username ?? context.read<UserProvider>().user?.username;
      if (targetUsername != null) {
        context.read<ProfileProvider>().loadProfile(targetUsername);
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final profileProv = context.watch<ProfileProvider>();
    final user = profileProv.profileUser;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (profileProv.isLoading && user == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (profileProv.error.isNotEmpty && user == null) {
      return Scaffold(body: Center(child: Text(profileProv.error)));
    }

    if (user == null) {
      return const Scaffold(body: Center(child: Text("User not found")));
    }

    final currentUser = context.watch<UserProvider>().user;
    final isPageSelf = user.id == currentUser?.id || user.isSelf == true;

    return Scaffold(
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            SliverAppBar(
              pinned: true,
              backgroundColor: isDark ? const Color(0xff15202b) : Colors.white,
              elevation: 0,
              leading: IconButton(
                icon: const CircleAvatar(
                  backgroundColor: Colors.black38,
                  child: Icon(Icons.arrow_back, color: Colors.white, size: 20),
                ),
                onPressed: () => Navigator.pop(context),
              ),
              title: innerBoxIsScrolled 
                ? Text(user.name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold))
                : null,
            ),
            SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Stack(
                    clipBehavior: Clip.none,
                    children: [
                      // Cover Image
                      user.coverImage != null
                          ? CustomImage(
                              imageUrl: MediaUtils.resolveImageUrl(user.coverImage!),
                              height: 160,
                              width: double.infinity,
                              fit: BoxFit.cover,
                            )
                          : Container(height: 160, color: const Color(0xff1DA1F2)),
                      
                      // Avatar and Action Button Row
                      Positioned(
                        bottom: -45,
                        left: 0,
                        right: 0,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              // Avatar
                              Container(
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  color: isDark ? const Color(0xff15202b) : Colors.white,
                                  shape: BoxShape.circle,
                                ),
                                child: ClipOval(
                                  child: user.image != null
                                      ? CustomImage(
                                          imageUrl: MediaUtils.resolveImageUrl(user.image!),
                                          width: 90,
                                          height: 90,
                                        )
                                      : Container(
                                          width: 90,
                                          height: 90,
                                          color: Colors.grey.shade300,
                                          child: const Icon(Icons.person, size: 45),
                                        ),
                                ),
                              ),
                              
                              // Action Buttons
                              Padding(
                                padding: const EdgeInsets.only(bottom: 8),
                                child: Row(
                                  children: [
                                    if (!isPageSelf) ...[
                                      _actionIcon(
                                        Icons.mail_outline, 
                                        onTap: () async {
                                          final conversation = await context.read<MessageProvider>().getOrCreateConversation(user.id);
                                          if (conversation != null && mounted) {
                                            Navigator.pushNamed(context, '/chat', arguments: conversation);
                                          }
                                        }
                                      ),
                                      const SizedBox(width: 12),
                                    ],
                                    ElevatedButton(
                                      onPressed: () {
                                        if (isPageSelf) {
                                          Navigator.pushNamed(context, '/edit-profile');
                                        } else {
                                          profileProv.toggleFollow();
                                        }
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: isPageSelf 
                                            ? Colors.transparent 
                                            : (user.isFollowing ? Colors.transparent : (isDark ? Colors.white : Colors.black)),
                                        foregroundColor: isPageSelf 
                                            ? (isDark ? Colors.white : Colors.black) 
                                            : (user.isFollowing ? (isDark ? Colors.white : Colors.black) : (isDark ? Colors.black : Colors.white)),
                                        elevation: 0,
                                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                                        side: BorderSide(color: Colors.grey.withOpacity(0.3)),
                                        shape: const StadiumBorder(),
                                      ),
                                      child: Text(
                                        isPageSelf 
                                            ? 'Edit profile' 
                                            : (user.isFollowing ? 'Following' : 'Follow'),
                                        style: const TextStyle(fontWeight: FontWeight.w800),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 55), // Space for the overlapping avatar
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              user.name,
                              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900, letterSpacing: -0.5),
                            ),
                            if (user.isVerified) ...[
                              const SizedBox(width: 4),
                              const VerifiedBadge(size: 22),
                            ],
                          ],
                        ),
                        Text(
                          '@${user.username}',
                          style: TextStyle(color: Colors.grey.shade600, fontSize: 16, fontWeight: FontWeight.w400),
                        ),
                        if (user.bio != null && user.bio!.isNotEmpty) ...[
                          const SizedBox(height: 12),
                          Text(user.bio!, style: const TextStyle(fontSize: 16)),
                        ],
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 16,
                          runSpacing: 8,
                          children: [
                            if (user.location != null && user.location!.isNotEmpty)
                              _infoIcon(Icons.location_on_outlined, user.location!),
                            if (user.website != null && user.website!.isNotEmpty)
                              _infoIcon(Icons.link, user.website!, color: const Color(0xff1DA1F2)),
                            if (user.joinedAt != null)
                              _infoIcon(Icons.calendar_month_outlined, 'Joined ${DateFormat('MMMM yyyy').format(user.joinedAt!)}'),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            _countText(
                              '${user.followingCount}', 
                              'Following', 
                              onTap: () => Navigator.pushNamed(context, '/connections', arguments: {'username': user.username, 'initialTabIndex': 1}),
                            ),
                            const SizedBox(width: 20),
                            _countText(
                              '${user.followersCount}', 
                              'Followers',
                              onTap: () => Navigator.pushNamed(context, '/connections', arguments: {'username': user.username, 'initialTabIndex': 0}),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
                  TabBar(
                    controller: _tabController,
                    isScrollable: true,
                    tabAlignment: TabAlignment.start,
                    indicatorColor: const Color(0xff1DA1F2),
                    indicatorWeight: 3,
                    indicatorPadding: const EdgeInsets.symmetric(horizontal: 4),
                    labelStyle: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15),
                    unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500, fontSize: 15),
                    labelColor: isDark ? Colors.white : Colors.black,
                    unselectedLabelColor: Colors.grey,
                    tabs: const [
                      Tab(text: 'Posts'),
                      Tab(text: 'Replies'),
                      Tab(text: 'Media'),
                      Tab(text: 'Likes'),
                    ],
                  ),
                ],
              ),
            ),
          ];
        },
        body: TabBarView(
          controller: _tabController,
          children: [
            _buildTweetList(profileProv.userTweets, profileProv.isLoading),
            _buildTweetList(profileProv.userReplies, profileProv.isLoading),
            _buildTweetList(profileProv.userMedia, profileProv.isLoading),
            _buildTweetList(profileProv.likedTweets, profileProv.isLoading),
          ],
        ),
      ),
    );
  }

  Widget _buildTweetList(List<Tweet> tweets, bool isLoading) {
    if (isLoading && tweets.isEmpty) {
      return const Center(child: Padding(padding: EdgeInsets.all(20), child: CircularProgressIndicator()));
    }
    if (tweets.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(40),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "Nothing to see here.",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey.shade700),
              ),
              const SizedBox(height: 8),
              const Text(
                "When there are posts, they'll show up here.",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey),
              ),
            ],
          ),
        ),
      );
    }
    return ListView.builder(
      padding: EdgeInsets.zero,
      itemCount: tweets.length,
      itemBuilder: (context, index) {
        return TweetCard(
          tweet: tweets[index],
          onAction: () {},
        );
      },
    );
  }

  Widget _actionIcon(IconData icon, {required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: Colors.grey.withOpacity(0.3)),
        ),
        child: Icon(icon, size: 20),
      ),
    );
  }

  Widget _infoIcon(IconData icon, String text, {Color? color}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: Colors.grey),
        const SizedBox(width: 4),
        Text(text, style: TextStyle(color: color ?? Colors.grey, fontSize: 14)),
      ],
    );
  }

  Widget _countText(String count, String label, {required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(count, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
          const SizedBox(width: 4),
          Text(label, style: const TextStyle(color: Colors.grey, fontSize: 14)),
        ],
      ),
    );
  }
}
