import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../features/auth/domain/presentation/providers/user_provider.dart';
import '../core/utils/media_utils.dart';
import 'package:twizzle/widgets/custom_image.dart';
import 'verified_badge.dart';

class DrawerMenu extends StatefulWidget {
  const DrawerMenu({Key? key}) : super(key: key);

  @override
  State<DrawerMenu> createState() => _DrawerMenuState();
}

class _DrawerMenuState extends State<DrawerMenu> {
  @override
  void initState() {
    super.initState();
    // Refresh user status to get latest follower/following counts
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<UserProvider>().refreshUserStatus();
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<UserProvider>().user;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Drawer(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(16, 60, 16, 20),
            width: double.infinity,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.pushNamed(context, '/profile', arguments: user?.username);
                  },
                  child: ClipOval(
                    child: user?.image != null
                        ? CustomImage(
                            imageUrl: MediaUtils.resolveImageUrl(user!.image!),
                            width: 60,
                            height: 60,
                          )
                        : Container(
                            width: 60,
                            height: 60,
                            color: isDark ? Colors.white10 : Colors.grey.shade200,
                            child: Icon(Icons.person, size: 35, color: isDark ? Colors.white70 : Colors.grey),
                          ),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Text(
                      user?.name ?? 'Guest User',
                      style: const TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 18,
                        letterSpacing: -0.5,
                      ),
                    ),
                    if (user?.isVerified ?? false) ...[
                      const SizedBox(width: 4),
                      const VerifiedBadge(size: 18),
                    ],
                  ],
                ),
                Text(
                  '@${user?.username ?? 'guest'}',
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    _countText('${user?.followingCount ?? 0}', 'Following'),
                    const SizedBox(width: 16),
                    _countText('${user?.followersCount ?? 0}', 'Followers'),
                  ],
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                _drawerTile(Icons.person_outline, 'Profile', () {
                  Navigator.pop(context);
                  Navigator.pushNamed(context, '/profile', arguments: user?.username);
                }),
                _drawerTile(Icons.list_alt_outlined, 'Lists', () {
                  Navigator.pop(context);
                  Navigator.pushNamed(context, '/lists');
                }),
                _drawerTile(Icons.bookmark_border, 'Bookmarks', () {
                  Navigator.pop(context);
                  Navigator.pushNamed(context, '/bookmarks');
                }),
                _drawerTile(Icons.bolt_outlined, 'Moments', () {
                  Navigator.pop(context);
                  Navigator.pushNamed(context, '/moments');
                }),
                const Divider(),
                _drawerTile(Icons.settings_outlined, 'Settings and privacy', () {
                  Navigator.pop(context);
                  Navigator.pushNamed(context, '/settings');
                }),
                _drawerTile(Icons.help_outline, 'Help Center', () {}),
              ],
            ),
          ),
          const Divider(height: 1),
          _drawerTile(Icons.logout, 'Log out', () {
            Navigator.pop(context);
            context.read<UserProvider>().logout();
            Navigator.pushReplacementNamed(context, '/login');
          }),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _countText(String count, String label) {
    return Row(
      children: [
        Text(
          count, 
          style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14)
        ),
        const SizedBox(width: 4),
        Text(
          label, 
          style: TextStyle(color: Colors.grey.shade600, fontSize: 14)
        ),
      ],
    );
  }

  Widget _drawerTile(IconData? icon, String title, VoidCallback onTap) {
    return ListTile(
      leading: icon != null ? Icon(icon, color: Theme.of(context).iconTheme.color, size: 26) : null,
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w500,
        ),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      onTap: onTap,
    );
  }
}