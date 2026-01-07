import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/test_tags.dart';
import '../../../../shared/widgets/error_banner.dart';
import '../../../../shared/widgets/loading_indicator.dart';
import '../providers/user_provider.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

class UserProfileScreen extends ConsumerStatefulWidget {
  const UserProfileScreen({super.key});

  @override
  ConsumerState<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends ConsumerState<UserProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    final user = ref.read(userProfileProvider).user;
    if (user != null) {
      _emailController.text = user.email;
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _handleUpdate() async {
    if (!_formKey.currentState!.validate()) return;

    final success = await ref.read(userProfileProvider.notifier).updateProfile(
          email: _emailController.text.trim(),
        );

    if (success && mounted) {
      setState(() {
        _isEditing = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile updated successfully')),
      );
    }
  }

  Future<void> _handleLogout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Logout'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      // TODO: Implement logout with Clerk
      // await ref.read(authProvider.notifier).logout();
      if (mounted) {
        Navigator.of(context).pop();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final profileState = ref.watch(userProfileProvider);
    // final authState = ref.watch(authProvider); // TODO: Fix auth provider

    return Scaffold(
      key: const Key(TestTags.userProfileScreen),
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          if (!_isEditing)
            IconButton(
              key: const Key(TestTags.userProfileEditButton),
              icon: const Icon(Icons.edit),
              onPressed: () {
                setState(() {
                  _isEditing = true;
                });
              },
            ),
        ],
      ),
      body: SafeArea(
        child: profileState.isLoading
            ? const LoadingIndicator(message: 'Loading profile...')
            : SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 24),
                      CircleAvatar(
                        radius: 50,
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        child: Text(
                          profileState.user?.email[0].toUpperCase() ?? 'U',
                          style: TextStyle(
                            fontSize: 40,
                            color: Theme.of(context).colorScheme.onPrimary,
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      if (profileState.error != null)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: ErrorBanner(
                            message: profileState.error!,
                            onRetry: null,
                          ),
                        ),
                      TextFormField(
                        key: const Key(TestTags.userProfileEmailField),
                        controller: _emailController,
                        enabled: _isEditing,
                        keyboardType: TextInputType.emailAddress,
                        decoration: const InputDecoration(
                          labelText: 'Email',
                          prefixIcon: Icon(Icons.email),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your email';
                          }
                          if (!value.contains('@')) {
                            return 'Please enter a valid email';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      if (profileState.user?.createdAt != null)
                        ListTile(
                          leading: const Icon(Icons.calendar_today),
                          title: const Text('Member since'),
                          subtitle: Text(
                            _formatDate(profileState.user!.createdAt!),
                          ),
                        ),
                      const SizedBox(height: 24),
                      if (_isEditing) ...[
                        ElevatedButton(
                          key: const Key(TestTags.userProfileSaveButton),
                          onPressed: profileState.isLoading
                              ? null
                              : _handleUpdate,
                          child: profileState.isLoading
                              ? const LoadingIndicator()
                              : const Text('Save Changes'),
                        ),
                        const SizedBox(height: 8),
                        OutlinedButton(
                          key: const Key(TestTags.userProfileCancelButton),
                          onPressed: () {
                            setState(() {
                              _isEditing = false;
                              _emailController.text =
                                  profileState.user?.email ?? '';
                            });
                          },
                          child: const Text('Cancel'),
                        ),
                      ],
                      const SizedBox(height: 32),
                      const Divider(),
                      const SizedBox(height: 16),
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
                        key: const Key(TestTags.userProfileLogoutButton),
                        leading: const Icon(Icons.logout),
                        title: const Text('Logout'),
                        onTap: _handleLogout,
                      ),
                    ],
                  ),
                ),
              ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}

