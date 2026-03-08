import 'package:flutter/material.dart';
import 'account_info_screen.dart';
import 'change_password_screen.dart';
import 'deactivate_account_screen.dart';

class SecurityScreen extends StatelessWidget {
  const SecurityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
        centerTitle: false,
        title: Text(
          'Security and account access',
          style: TextStyle(
            color: isDark ? Colors.white : const Color(0xFF1A1D21),
            fontSize: 20,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.5,
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: isDark ? Colors.white : const Color(0xFF1A1D21), size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: isDark ? Colors.white10 : Colors.black.withOpacity(0.05), height: 1),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF1DA1F2).withOpacity(0.05),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFF1DA1F2).withOpacity(0.1)),
            ),
            child: Row(
              children: [
                const Icon(Icons.info_outline, color: Color(0xFF1DA1F2), size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Manage your account\'s security and keep track of your account\'s usage.',
                    style: TextStyle(
                      color: (isDark ? Colors.white : const Color(0xFF1A1D21)).withOpacity(0.7),
                      fontSize: 13,
                      height: 1.4,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          _buildSecurityTile(
            context,
            Icons.person_outline_rounded,
            'Account information',
            'See your account information like your username and email address.',
            () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AccountInfoScreen())),
          ),
          _buildSecurityTile(
            context,
            Icons.lock_open_rounded,
            'Change your password',
            'Change your password at any time.',
            () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ChangePasswordScreen())),
          ),
          _buildSecurityTile(
            context,
            Icons.heart_broken_rounded,
            'Deactivate your account',
            'Find out how you can deactivate your account.',
            () => Navigator.push(context, MaterialPageRoute(builder: (_) => const DeactivateAccountScreen())),
            isLast: true,
          ),
        ],
      ),
    );
  }

  Widget _buildSecurityTile(
    BuildContext context, 
    IconData icon, 
    String title, 
    String subtitle, 
    VoidCallback onTap,
    {bool isLast = false}
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      children: [
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: isDark ? Colors.white.withOpacity(0.05) : Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: isDark ? [] : [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.03),
                          blurRadius: 10,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: Icon(icon, color: const Color(0xFF1DA1F2), size: 24),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: TextStyle(
                            color: isDark ? Colors.white : const Color(0xFF1A1D21),
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          subtitle,
                          style: TextStyle(
                            color: (isDark ? Colors.white : const Color(0xFF1A1D21)).withOpacity(0.5),
                            fontSize: 13,
                            height: 1.3,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.chevron_right_rounded,
                    color: (isDark ? Colors.white : const Color(0xFF1A1D21)).withOpacity(0.2),
                    size: 24,
                  ),
                ],
              ),
            ),
          ),
        ),
        if (!isLast)
          Padding(
            padding: const EdgeInsets.only(left: 64),
            child: Divider(color: isDark ? Colors.white10 : Colors.black.withOpacity(0.05), height: 1),
          ),
      ],
    );
  }
}
