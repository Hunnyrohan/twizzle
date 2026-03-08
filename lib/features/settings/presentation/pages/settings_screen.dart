import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:provider/provider.dart';
import 'package:local_auth/local_auth.dart';
import 'package:twizzle/core/services/biometric_service.dart';
import 'package:twizzle/features/verification/presentation/pages/verification_screen.dart';
import 'package:twizzle/theme/theme_provider.dart';
import 'security_screen.dart';
import 'blocked_accounts_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

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
          'Settings',
          style: TextStyle(
            color: isDark ? Colors.white : const Color(0xFF1A1D21),
            fontSize: 22,
            fontWeight: FontWeight.w900,
            letterSpacing: -0.8,
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
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 12),
        children: [
          _sectionHeader(context, 'Account'),
          _settingsTile(
            context,
            Icons.verified_rounded,
            'Twizzle Verified',
            'Get your blue badge today',
            const Color(0xFF1DA1F2),
            () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const VerificationScreen()),
              );
            },
          ),
          _settingsTile(
            context,
            Icons.security_rounded,
            'Security and account access',
            'Manage your account security',
            isDark ? Colors.white70 : const Color(0xFF536471),
            () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SecurityScreen()),
              );
            },
          ),
          _settingsTile(
            context,
            Icons.block_rounded,
            'Blocked accounts',
            'Manage the accounts that you\'ve blocked',
            isDark ? Colors.white70 : const Color(0xFF536471),
            () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const BlockedAccountsScreen()),
              );
            },
          ),
          
          _biometricLockTile(context),
          
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            child: Divider(color: isDark ? Colors.white12 : Colors.black12),
          ),
          
          _sectionHeader(context, 'Display & Appearance'),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            decoration: BoxDecoration(
              color: isDark ? Colors.white.withOpacity(0.05) : Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: isDark ? [] : [
                BoxShadow(
                  color: Colors.black.withOpacity(0.02),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: (isDark ? Colors.purpleAccent : Colors.purple).withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isDark ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
                  color: isDark ? Colors.purpleAccent : Colors.purple,
                  size: 20,
                ),
              ),
              title: Text(
                'Dark Mode',
                style: TextStyle(
                  color: isDark ? Colors.white : const Color(0xFF1A1D21),
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                ),
              ),
              subtitle: Text(
                isDark ? 'Optimized for night' : 'Clarity and focus',
                style: TextStyle(
                  color: (isDark ? Colors.white : const Color(0xFF1A1D21)).withOpacity(0.5),
                  fontSize: 13,
                ),
              ),
              trailing: Switch(
                value: isDark,
                onChanged: themeProvider.isAutoThemeEnabled ? null : (val) => themeProvider.toggleTheme(val),
                activeColor: const Color(0xFF1DA1F2),
              ),
            ),
          ),

          // Auto Dark Mode Toggle
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            decoration: BoxDecoration(
              color: isDark ? Colors.white.withOpacity(0.05) : Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.brightness_auto_rounded, color: Colors.orange, size: 20),
              ),
              title: Text(
                'Auto Dark Mode',
                style: TextStyle(
                  color: isDark ? Colors.white : const Color(0xFF1A1D21),
                  fontWeight: FontWeight.w700,
                ),
              ),
              subtitle: Text(
                themeProvider.isSensorAvailable 
                    ? 'Switch automatically based on light'
                    : 'Sensor missing - Using Time-based fallback (7PM-7AM)',
                style: TextStyle(
                  color: (themeProvider.isSensorAvailable ? Colors.orange : Colors.redAccent).withOpacity(0.7),
                  fontSize: 12,
                  fontWeight: themeProvider.isSensorAvailable ? FontWeight.normal : FontWeight.bold,
                ),
              ),
              trailing: Switch(
                value: themeProvider.isAutoThemeEnabled,
                onChanged: (val) => themeProvider.setAutoTheme(val),
                activeColor: const Color(0xFF1DA1F2),
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            child: Divider(color: isDark ? Colors.white12 : Colors.black12),
          ),
          
          _sectionHeader(context, 'Advanced'),
          _settingsTile(
            context,
            Icons.terminal_rounded,
            'Server Settings',
            'Connection & IP configuration',
            isDark ? Colors.white : const Color(0xFF1A1D21),
            () {
              Navigator.pushNamed(context, '/server-settings');
            },
            isLast: true,
          ),
        ],
      ),
    );
  }

  Widget _biometricLockTile(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final box = Hive.box('settings');
    bool isEnabled = box.get('biometricLock', defaultValue: false);

    return StatefulBuilder(
      builder: (context, setState) {
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          decoration: BoxDecoration(
            color: isDark ? Colors.white.withOpacity(0.05) : Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.fingerprint_rounded, color: Colors.blue, size: 20),
            ),
            title: Text(
              'Biometric Lock',
              style: TextStyle(
                color: isDark ? Colors.white : const Color(0xFF1A1D21),
                fontWeight: FontWeight.w700,
                fontSize: 16,
              ),
            ),
            subtitle: Text(
              'Require fingerprint to open app',
              style: TextStyle(
                color: (isDark ? Colors.white : const Color(0xFF1A1D21)).withOpacity(0.5),
                fontSize: 13,
              ),
            ),
            trailing: Switch(
              value: isEnabled,
              onChanged: (value) async {
                if (value) {
                  // Check if biometric is available before enabling
                  if (!await BiometricService.canVerify()) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Biometric authentication is not available or not set up on this device.'),
                          backgroundColor: Colors.redAccent,
                        ),
                      );
                    }
                    return;
                  }
                  
                  // Authenticate once to confirm it works before enabling
                  final bool didAuthenticate = await BiometricService.authenticate(
                    reason: 'Please authenticate to enable Biometric Lock',
                  );
                  
                  if (!didAuthenticate) return;
                }

                await box.put('biometricLock', value);
                setState(() => isEnabled = value);
              },
              activeColor: const Color(0xFF1DA1F2),
            ),
          ),
        );
      },
    );
  }

  Widget _sectionHeader(BuildContext context, String title) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.fromLTRB(28, 16, 24, 12),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w900,
          color: isDark ? Colors.white54 : const Color(0xFF536471),
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _settingsTile(
    BuildContext context,
    IconData icon,
    String title,
    String subtitle,
    Color iconColor,
    VoidCallback onTap,
    {bool isLast = false}
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withOpacity(0.05) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: isDark ? [] : [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: iconColor.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: iconColor, size: 20),
        ),
        title: Text(
          title, 
          style: TextStyle(
            color: isDark ? Colors.white : const Color(0xFF1A1D21),
            fontWeight: FontWeight.w700,
            fontSize: 16,
          ),
        ),
        subtitle: Text(
          subtitle, 
          style: TextStyle(
            color: (isDark ? Colors.white : const Color(0xFF1A1D21)).withOpacity(0.5),
            fontSize: 13,
          ),
        ),
        trailing: Icon(
          Icons.chevron_right_rounded, 
          color: (isDark ? Colors.white : const Color(0xFF1A1D21)).withOpacity(0.2),
          size: 20,
        ),
        onTap: onTap,
      ),
    );
  }
}
