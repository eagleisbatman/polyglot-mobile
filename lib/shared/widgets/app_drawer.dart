import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:package_info_plus/package_info_plus.dart';
import '../../core/services/auth_service.dart';

/// App drawer with navigation items
class AppDrawer extends ConsumerWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final authState = ref.watch(authProvider);
    final user = authState.user;

    return Drawer(
      child: Column(
        children: [
          // User Header
          _buildUserHeader(context, theme, user),
          
          // Navigation Items
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                const SizedBox(height: 8),
                
                // Profile
                _DrawerItem(
                  icon: Icons.person_outline,
                  title: 'Profile',
                  onTap: () {
                    Navigator.pop(context);
                    context.push('/profile');
                  },
                ),
                
                // Preferences
                _DrawerItem(
                  icon: Icons.settings_outlined,
                  title: 'Preferences',
                  onTap: () {
                    Navigator.pop(context);
                    context.push('/preferences');
                  },
                ),
                
                const Divider(height: 32),
                
                // Support Section Header
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Text(
                    'SUPPORT',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                      letterSpacing: 1.2,
                    ),
                  ),
                ),
                
                // Help & FAQ
                _DrawerItem(
                  icon: Icons.help_outline,
                  title: 'Help & FAQ',
                  onTap: () {
                    Navigator.pop(context);
                    _showHelpDialog(context);
                  },
                ),
                
                // About
                _DrawerItem(
                  icon: Icons.info_outline,
                  title: 'About Polyglot',
                  onTap: () {
                    Navigator.pop(context);
                    _showAboutDialog(context);
                  },
                ),
              ],
            ),
          ),
          
          // App Version Footer
          _buildVersionFooter(theme),
        ],
      ),
    );
  }

  Widget _buildUserHeader(BuildContext context, ThemeData theme, user) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 24,
        left: 16,
        right: 16,
        bottom: 24,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            theme.colorScheme.primary,
            theme.colorScheme.primary.withValues(alpha: 0.8),
          ],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Device Icon
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(
              _getDeviceIcon(user?.osName),
              size: 32,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          
          // Device Name
          Text(
            '${user?.deviceBrand ?? ''} ${user?.deviceModel ?? 'Device'}'.trim(),
            style: theme.textTheme.titleMedium?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          
          // Location & Language
          Row(
            children: [
              Icon(
                Icons.location_on_outlined,
                size: 14,
                color: Colors.white.withValues(alpha: 0.8),
              ),
              const SizedBox(width: 4),
              Text(
                user?.city ?? user?.country ?? 'Location not set',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: Colors.white.withValues(alpha: 0.8),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildVersionFooter(ThemeData theme) {
    return FutureBuilder<PackageInfo>(
      future: PackageInfo.fromPlatform(),
      builder: (context, snapshot) {
        final version = snapshot.data?.version ?? '1.0.0';
        final buildNumber = snapshot.data?.buildNumber ?? '1';
        
        return Container(
          padding: const EdgeInsets.all(16),
          child: Text(
            'v$version+$buildNumber',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        );
      },
    );
  }

  IconData _getDeviceIcon(String? osName) {
    if (osName == null) return Icons.devices;
    if (osName.toLowerCase().contains('ios')) return Icons.phone_iphone;
    if (osName.toLowerCase().contains('android')) return Icons.phone_android;
    return Icons.devices;
  }

  void _showHelpDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.help_outline),
            SizedBox(width: 12),
            Text('Help & FAQ'),
          ],
        ),
        content: const SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _FaqItem(
                question: 'How do I translate voice?',
                answer: 'Tap and hold the microphone button, speak in your source language, and release. The translation will appear automatically.',
              ),
              SizedBox(height: 16),
              _FaqItem(
                question: 'How do I translate images?',
                answer: 'Tap the camera icon to take a photo or select from gallery. The text in the image will be detected and translated.',
              ),
              SizedBox(height: 16),
              _FaqItem(
                question: 'Can I change languages?',
                answer: 'Tap the language selector at the top of the screen to change source and target languages.',
              ),
              SizedBox(height: 16),
              _FaqItem(
                question: 'Is my data private?',
                answer: 'Yes! Your translations are stored securely and never shared with third parties.',
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Got it'),
          ),
        ],
      ),
    );
  }

  void _showAboutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AboutDialog(
        applicationName: 'Polyglot',
        applicationVersion: '1.0.0',
        applicationIcon: Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary,
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(
            Icons.translate_rounded,
            size: 40,
            color: Colors.white,
          ),
        ),
        children: const [
          SizedBox(height: 16),
          Text(
            'Real-time voice, camera, and document translation powered by Google Gemini AI.',
          ),
          SizedBox(height: 16),
          Text(
            '© 2025 Polyglot. All rights reserved.',
            style: TextStyle(fontSize: 12),
          ),
        ],
      ),
    );
  }
}

class _DrawerItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;
  final Widget? trailing;

  const _DrawerItem({
    required this.icon,
    required this.title,
    required this.onTap,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return ListTile(
      leading: Icon(icon, color: theme.colorScheme.onSurfaceVariant),
      title: Text(title),
      trailing: trailing,
      onTap: onTap,
    );
  }
}

class _FaqItem extends StatelessWidget {
  final String question;
  final String answer;

  const _FaqItem({
    required this.question,
    required this.answer,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          question,
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          answer,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

