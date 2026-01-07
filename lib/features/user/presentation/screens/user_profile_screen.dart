import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/test_tags.dart';
import '../../../../core/services/auth_service.dart';
import '../../../../shared/widgets/error_banner.dart';
import '../../../../shared/widgets/loading_indicator.dart';

class UserProfileScreen extends ConsumerStatefulWidget {
  const UserProfileScreen({super.key});

  @override
  ConsumerState<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends ConsumerState<UserProfileScreen> {
  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final user = authState.user;

    return Scaffold(
      key: const Key(TestTags.userProfileScreen),
      appBar: AppBar(
        title: const Text('Profile'),
      ),
      body: SafeArea(
        child: authState.status == AuthStatus.loading
            ? const LoadingIndicator(message: 'Loading profile...')
            : SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 24),
                    // Device avatar
                    CircleAvatar(
                      radius: 50,
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      child: Icon(
                        _getDeviceIcon(user?.osName),
                        size: 40,
                        color: Theme.of(context).colorScheme.onPrimary,
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Device name
                    Text(
                      '${user?.deviceBrand ?? ''} ${user?.deviceModel ?? 'Device'}',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    // OS info
                    Text(
                      '${user?.osName ?? 'Unknown'} ${user?.osVersion ?? ''}',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                    ),
                    const SizedBox(height: 32),

                    if (authState.error != null)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: ErrorBanner(
                          message: authState.error!,
                          onRetry: null,
                        ),
                      ),

                    // Location section
                    _buildSectionCard(
                      context,
                      title: 'Location',
                      icon: Icons.location_on,
                      children: [
                        _buildInfoRow('Country', user?.country ?? 'Not set'),
                        _buildInfoRow('City', user?.city ?? 'Not set'),
                        _buildInfoRow('Timezone', user?.timezone ?? 'Unknown'),
                      ],
                      action: TextButton(
                        onPressed: () {
                          // TODO: Navigate to location settings
                          context.push('/preferences');
                        },
                        child: const Text('Update Location'),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Language preferences section
                    _buildSectionCard(
                      context,
                      title: 'Language Preferences',
                      icon: Icons.translate,
                      children: [
                        _buildInfoRow('Source', user?.preferredSourceLanguage ?? 'en'),
                        _buildInfoRow('Target', user?.preferredTargetLanguage ?? 'hi'),
                      ],
                      action: TextButton(
                        onPressed: () {
                          context.push('/preferences');
                        },
                        child: const Text('Change'),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // App info section
                    _buildSectionCard(
                      context,
                      title: 'App Info',
                      icon: Icons.info_outline,
                      children: [
                        _buildInfoRow('Version', user?.appVersion ?? '1.0.0'),
                        _buildInfoRow(
                          'Member since',
                          user?.createdAt != null
                              ? _formatDate(user!.createdAt)
                              : 'Unknown',
                        ),
                        _buildInfoRow(
                          'Last active',
                          user?.lastActiveAt != null
                              ? _formatDate(user!.lastActiveAt!)
                              : 'Unknown',
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),

                    // Settings button
                    ListTile(
                      leading: const Icon(Icons.settings),
                      title: const Text('Preferences'),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () {
                        context.push('/preferences');
                      },
                    ),
                    const Divider(),
                    ListTile(
                      leading: const Icon(Icons.history),
                      title: const Text('Translation History'),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () {
                        context.push('/history');
                      },
                    ),
                    const Divider(),

                    // Device ID (for debugging)
                    ExpansionTile(
                      leading: const Icon(Icons.developer_mode),
                      title: const Text('Developer Info'),
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: SelectableText(
                            'User ID:\n${user?.id ?? 'Unknown'}',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  fontFamily: 'monospace',
                                ),
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

  Widget _buildSectionCard(
    BuildContext context, {
    required String title,
    required IconData icon,
    required List<Widget> children,
    Widget? action,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 20),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const Spacer(),
                if (action != null) action,
              ],
            ),
            const SizedBox(height: 12),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  IconData _getDeviceIcon(String? osName) {
    if (osName == null) return Icons.devices;
    if (osName.toLowerCase().contains('ios')) return Icons.phone_iphone;
    if (osName.toLowerCase().contains('android')) return Icons.phone_android;
    return Icons.devices;
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}
