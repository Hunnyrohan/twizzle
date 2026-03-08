import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:twizzle/features/auth/domain/presentation/providers/user_provider.dart';
import 'package:twizzle/theme/theme_provider.dart';

class BlockedAccountsScreen extends StatefulWidget {
  const BlockedAccountsScreen({super.key});

  @override
  State<BlockedAccountsScreen> createState() => _BlockedAccountsScreenState();
}

class _BlockedAccountsScreenState extends State<BlockedAccountsScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => context.read<UserProvider>().getBlockedUsers());
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    final isDark = themeProvider.isDarkMode;
    final theme = Theme.of(context);
    
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
        centerTitle: false,
        title: Text(
          'Blocked accounts',
          style: TextStyle(
            color: isDark ? Colors.white : const Color(0xFF1A1D21),
            fontSize: 20,
            fontWeight: FontWeight.w900,
            letterSpacing: -0.5,
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: isDark ? Colors.white : const Color(0xFF1A1D21), size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: isDark ? Colors.white10 : Colors.black.withOpacity(0.05), height: 1),
        ),
      ),
      body: Consumer<UserProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading && provider.blockedUsers.isEmpty) {
            return const Center(child: CircularProgressIndicator(color: Color(0xFF1DA1F2)));
          }

          if (provider.blockedUsers.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(40.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: (isDark ? Colors.white : Colors.black).withOpacity(0.03),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.block_rounded,
                        size: 64,
                        color: (isDark ? Colors.white : Colors.black).withOpacity(0.2),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'No blocked accounts',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                        color: isDark ? Colors.white : const Color(0xFF1A1D21),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'When you block someone, you won\'t see their content and they won\'t see yours.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 15,
                        color: (isDark ? Colors.white : const Color(0xFF1A1D21)).withOpacity(0.5),
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: provider.blockedUsers.length,
            separatorBuilder: (context, index) => Divider(
              color: isDark ? Colors.white10 : Colors.black.withOpacity(0.05),
              indent: 80,
            ),
            itemBuilder: (context, index) {
              final user = provider.blockedUsers[index];
              return ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                leading: CircleAvatar(
                  radius: 24,
                  backgroundImage: (user.image != null && user.image!.startsWith('http'))
                      ? NetworkImage(user.image!)
                      : (user.image != null
                          ? NetworkImage('http://192.168.1.84:5000/${user.image}')
                          : null),
                  child: user.image == null ? const Icon(Icons.person) : null,
                  backgroundColor: Colors.grey.shade200,
                ),
                title: Text(
                  user.name,
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 16,
                    color: isDark ? Colors.white : const Color(0xFF1A1D21),
                  ),
                ),
                subtitle: Text(
                  '@${user.username}',
                  style: TextStyle(
                    color: (isDark ? Colors.white : const Color(0xFF1A1D21)).withOpacity(0.5),
                  ),
                ),
                trailing: OutlinedButton(
                  onPressed: () => _showUnblockDialog(context, provider, user.id, user.username),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red,
                    side: BorderSide(color: Colors.red.withOpacity(0.5)),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                  ),
                  child: const Text('Unblock', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _showUnblockDialog(BuildContext context, UserProvider provider, String userId, String username) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Unblock @$username?'),
        content: const Text('They will be able to see your posts and follow you again.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              final success = await provider.toggleBlock(userId);
              if (success && mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Unblocked @$username')),
                );
              }
            },
            child: const Text('Unblock', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}
