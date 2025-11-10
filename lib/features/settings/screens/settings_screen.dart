import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:life_hub/core/constants/app_colors.dart';
import 'package:life_hub/providers/theme_provider.dart';
import 'package:life_hub/providers/settings_provider.dart';
import 'package:life_hub/features/settings/widgets/settings_item.dart';
import 'package:life_hub/features/settings/widgets/settings_toggle_item.dart';
import 'package:life_hub/features/settings/widgets/settings_section.dart';
import 'package:life_hub/features/settings/screens/profile_screen.dart';
import 'package:life_hub/features/settings/screens/privacy_screen.dart';
import 'package:life_hub/features/settings/screens/backup_screen.dart';
import 'package:life_hub/features/settings/screens/about_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(25),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SettingsSection(title: 'Account'),
                    const SizedBox(height: 12),
                    _buildAccountSection(context),
                    
                    const SizedBox(height: 30),
                    const SettingsSection(title: 'Preferences'),
                    const SizedBox(height: 12),
                    _buildPreferencesSection(context),
                    
                    const SizedBox(height: 30),
                    const SettingsSection(title: 'App'),
                    const SizedBox(height: 12),
                    _buildAppSection(context),
                    
                    const SizedBox(height: 30),
                    _buildLogoutButton(context),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 15),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Colors.white.withOpacity(0.1),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Center(
                child: Icon(
                  Icons.arrow_back_ios_new,
                  color: Colors.white,
                  size: 18,
                ),
              ),
            ),
          ),
          const SizedBox(width: 15),
          const Text(
            'Settings',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAccountSection(BuildContext context) {
    return Column(
      children: [
        SettingsItem(
          icon: '👤',
          title: 'Profile',
          subtitle: 'Edit your personal info',
          gradientColors: const [
            AppColors.purpleGradientStart,
            AppColors.purpleGradientEnd,
          ],
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const ProfileScreen()),
          ),
        ),
      ],
    );
  }

  Widget _buildPreferencesSection(BuildContext context) {
    return Consumer2<ThemeProvider, SettingsProvider>(
      builder: (context, themeProvider, settingsProvider, _) {
        return Column(
          children: [
            SettingsToggleItem(
              icon: '🌙',
              title: 'Dark Mode',
              subtitle: themeProvider.isDarkMode 
                  ? 'Currently enabled' 
                  : 'Currently disabled',
              gradientColors: const [
                AppColors.purpleGradientStart,
                AppColors.purpleGradientEnd,
              ],
              isEnabled: themeProvider.isDarkMode,
              onToggle: (value) => themeProvider.toggleTheme(),
            ),
            const SizedBox(height: 12),
            SettingsToggleItem(
              icon: '🔔',
              title: 'Notifications',
              subtitle: settingsProvider.notificationsEnabled
                  ? 'Push notifications enabled'
                  : 'Push notifications disabled',
              gradientColors: const [
                AppColors.blueGradientStart,
                AppColors.blueGradientEnd,
              ],
              isEnabled: settingsProvider.notificationsEnabled,
              onToggle: (value) => settingsProvider.toggleNotifications(),
            ),
            const SizedBox(height: 12),
            SettingsToggleItem(
              icon: '🔊',
              title: 'Sound',
              subtitle: settingsProvider.soundEnabled
                  ? 'Sound effects enabled'
                  : 'Sound effects disabled',
              gradientColors: const [
                AppColors.greenGradientStart,
                AppColors.greenGradientEnd,
              ],
              isEnabled: settingsProvider.soundEnabled,
              onToggle: (value) => settingsProvider.toggleSound(),
            ),
            const SizedBox(height: 12),
            SettingsToggleItem(
              icon: '📳',
              title: 'Vibration',
              subtitle: settingsProvider.vibrationEnabled
                  ? 'Haptic feedback enabled'
                  : 'Haptic feedback disabled',
              gradientColors: const [
                AppColors.pinkGradientStart,
                AppColors.pinkGradientEnd,
              ],
              isEnabled: settingsProvider.vibrationEnabled,
              onToggle: (value) => settingsProvider.toggleVibration(),
            ),
          ],
        );
      },
    );
  }

  Widget _buildAppSection(BuildContext context) {
    return Column(
      children: [
        SettingsItem(
          icon: '🔒',
          title: 'Privacy',
          subtitle: 'Manage your data',
          gradientColors: const [
            AppColors.yellowGradientStart,
            AppColors.yellowGradientEnd,
          ],
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const PrivacyScreen()),
          ),
        ),
        const SizedBox(height: 12),
        SettingsItem(
          icon: '💾',
          title: 'Backup',
          subtitle: 'Sync & backup data',
          gradientColors: const [
            AppColors.blueGradientStart,
            AppColors.blueGradientEnd,
          ],
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const BackupScreen()),
          ),
        ),
        const SizedBox(height: 12),
        SettingsItem(
          icon: 'ℹ️',
          title: 'About',
          subtitle: 'Version 1.0.0',
          gradientColors: const [
            AppColors.purpleGradientStart,
            AppColors.purpleGradientEnd,
          ],
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AboutScreen()),
          ),
        ),
      ],
    );
  }

  Widget _buildLogoutButton(BuildContext context) {
    return GestureDetector(
      onTap: () => _showLogoutDialog(context),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          border: Border.all(
            color: AppColors.highPriority.withOpacity(0.3),
            width: 1,
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        padding: const EdgeInsets.all(18),
        child: Row(
          children: [
            Container(
              width: 45,
              height: 45,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppColors.pinkGradientStart,
                    AppColors.pinkGradientEnd,
                  ],
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Center(
                child: Text('🚪', style: TextStyle(fontSize: 20)),
              ),
            ),
            const SizedBox(width: 15),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Logout',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Sign out of your account',
                    style: TextStyle(
                      color: AppColors.textGrey,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios,
              color: AppColors.highPriority,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.darkCard,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: const Text(
          'Logout',
          style: TextStyle(color: Colors.white),
        ),
        content: const Text(
          'Are you sure you want to logout?',
          style: TextStyle(color: AppColors.textGrey),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Cancel',
              style: TextStyle(color: AppColors.textGrey),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // Add logout logic here
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Logged out successfully'),
                  backgroundColor: AppColors.completed,
                ),
              );
            },
            child: const Text(
              'Logout',
              style: TextStyle(color: AppColors.highPriority),
            ),
          ),
        ],
      ),
    );
  }
}