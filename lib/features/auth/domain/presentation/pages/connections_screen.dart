import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:twizzle/features/auth/domain/presentation/providers/profile_provider.dart';
import 'package:twizzle/features/auth/domain/entities/user.dart';
import 'package:twizzle/widgets/verified_badge.dart';
import 'package:twizzle/widgets/custom_image.dart';
import 'package:twizzle/core/utils/media_utils.dart';

class ConnectionsScreen extends StatefulWidget {
  final String username;
  final int initialTabIndex; // 0 for Followers, 1 for Following

  const ConnectionsScreen({
    Key? key,
    required this.username,
    this.initialTabIndex = 0,
  }) : super(key: key);

  @override
  State<ConnectionsScreen> createState() => _ConnectionsScreenState();
}

class _ConnectionsScreenState extends State<ConnectionsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this, initialIndex: widget.initialTabIndex);
    
    // Load data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final prov = context.read<ProfileProvider>();
      prov.loadFollowers(widget.username);
      prov.loadFollowing(widget.username);
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
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              profileProv.profileUser?.name ?? widget.username,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Text(
              '@${widget.username}',
              style: TextStyle(fontSize: 13, color: Colors.grey.shade600, fontWeight: FontWeight.normal),
            ),
          ],
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: const Color(0xff1DA1F2),
          indicatorWeight: 3,
          labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
          unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500, fontSize: 15),
          tabs: const [
            Tab(text: 'Followers'),
            Tab(text: 'Following'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildUserList(profileProv.followers, profileProv.isLoading),
          _buildUserList(profileProv.following, profileProv.isLoading),
        ],
      ),
    );
  }

  Widget _buildUserList(List<User> users, bool isLoading) {
    if (isLoading && users.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }
    final filteredUsers = users.where((u) => !u.isSelf).toList();

    if (filteredUsers.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(40),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "No users found",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey.shade700),
              ),
              const SizedBox(height: 8),
              const Text(
                "When someone follows this account, they'll show up here.",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey),
              ),
            ],
          ),
        ),
      );
    }
    return ListView.builder(
      itemCount: filteredUsers.length,
      itemBuilder: (context, index) {
        final user = filteredUsers[index];
        return ListTile(
          leading: ClipOval(
            child: user.image != null
                ? CustomImage(
                    imageUrl: MediaUtils.resolveImageUrl(user.image!),
                    width: 40,
                    height: 40,
                  )
                : Container(
                    width: 40,
                    height: 40,
                    color: Colors.grey.shade300,
                    child: const Icon(Icons.person),
                  ),
          ),
          title: Row(
            children: [
              Flexible(
                child: Text(
                  user.name,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              if (user.isVerified) ...[
                const SizedBox(width: 4),
                const VerifiedBadge(size: 16),
              ],
            ],
          ),
          subtitle: Text('@${user.username}'),
          trailing: user.isSelf 
              ? null 
              : OutlinedButton(
                  onPressed: () {
                    // Navigate to their profile or toggle follow
                  },
                  style: OutlinedButton.styleFrom(
                    shape: const StadiumBorder(),
                    side: BorderSide(color: Colors.grey.withOpacity(0.3)),
                  ),
                  child: Text(
                    user.isFollowing ? 'Following' : 'Follow',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
          onTap: () {
            Navigator.pushNamed(context, '/profile', arguments: user.username);
          },
        );
      },
    );
  }
}
