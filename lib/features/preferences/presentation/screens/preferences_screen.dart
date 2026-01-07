import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/test_tags.dart';
import '../../../../core/constants/supported_languages.dart';
import '../../../../shared/widgets/error_banner.dart';
import '../../../../shared/widgets/loading_indicator.dart';
import '../providers/preferences_provider.dart';
import '../../../../core/services/preferences_api_service.dart';
import '../../../../core/services/auth_service.dart';
import '../../../../core/services/location_service.dart';

class PreferencesScreen extends ConsumerStatefulWidget {
  const PreferencesScreen({super.key});

  @override
  ConsumerState<PreferencesScreen> createState() => _PreferencesScreenState();
}

class _PreferencesScreenState extends ConsumerState<PreferencesScreen> {
  String? _selectedSourceLanguage;
  String? _selectedTargetLanguage;
  String? _selectedTheme;
  bool? _enableNotifications;
  bool? _enableLocationTracking;
  bool _hasChanges = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final prefs = ref.read(preferencesProvider).preferences;
      if (prefs != null) {
        setState(() {
          _selectedSourceLanguage = prefs.defaultSourceLanguage;
          _selectedTargetLanguage = prefs.defaultTargetLanguage;
          _selectedTheme = prefs.theme;
          _enableNotifications = prefs.enableNotifications;
          // _enableLocationTracking = prefs.enableLocationTracking; // TODO: Add to UserPreferences model
        });
      }
    });
  }

  Future<void> _handleSave() async {
    final success = await ref.read(preferencesProvider.notifier).updatePreferences(
          defaultSourceLanguage: _selectedSourceLanguage,
          defaultTargetLanguage: _selectedTargetLanguage,
          theme: _selectedTheme,
          enableNotifications: _enableNotifications,
          enableLocationTracking: _enableLocationTracking,
        );

    if (success && mounted) {
      setState(() {
        _hasChanges = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Preferences saved successfully')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final preferencesState = ref.watch(preferencesProvider);
    final prefs = preferencesState.preferences ?? UserPreferences();

    _selectedSourceLanguage ??= prefs.defaultSourceLanguage ?? 'en';
    _selectedTargetLanguage ??= prefs.defaultTargetLanguage ?? 'es';
    _selectedTheme ??= prefs.theme;
    _enableNotifications ??= prefs.enableNotifications;
    _enableLocationTracking ??= false;

    return Scaffold(
      key: const Key(TestTags.preferencesScreen),
      appBar: AppBar(
        title: const Text('Preferences'),
        actions: [
          if (_hasChanges)
            TextButton(
              key: const Key(TestTags.preferencesSaveButton),
              onPressed: preferencesState.isLoading ? null : _handleSave,
              child: preferencesState.isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Save'),
            ),
        ],
      ),
      body: SafeArea(
        child: preferencesState.isLoading && prefs.defaultSourceLanguage == null
            ? const LoadingIndicator(message: 'Loading preferences...')
            : SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (preferencesState.error != null)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: ErrorBanner(
                          message: preferencesState.error!,
                          onRetry: null,
                        ),
                      ),
                    _buildSection(
                      title: 'Language Preferences',
                      children: [
                        _buildLanguageDropdown(
                          label: 'Default Source Language',
                          value: _selectedSourceLanguage ?? 'en',
                          onChanged: (value) {
                            setState(() {
                              _selectedSourceLanguage = value;
                              _hasChanges = true;
                            });
                          },
                        ),
                        const SizedBox(height: 16),
                        _buildLanguageDropdown(
                          label: 'Default Target Language',
                          value: _selectedTargetLanguage ?? 'es',
                          onChanged: (value) {
                            setState(() {
                              _selectedTargetLanguage = value;
                              _hasChanges = true;
                            });
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    _buildSection(
                      title: 'Appearance',
                      children: [
                        _buildThemeSelector(),
                      ],
                    ),
                    const SizedBox(height: 24),
                    _buildSection(
                      title: 'Notifications',
                      children: [
                        SwitchListTile(
                          key: const Key(TestTags.preferencesNotificationsSwitch),
                          title: const Text('Enable Notifications'),
                          subtitle: const Text(
                            'Receive notifications about translations',
                          ),
                          value: _enableNotifications ?? true,
                          onChanged: (value) {
                            setState(() {
                              _enableNotifications = value;
                              _hasChanges = true;
                            });
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    _buildLocationSection(context),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required List<Widget> children,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 12),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: children,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLanguageDropdown({
    required String label,
    required String value,
    required ValueChanged<String?> onChanged,
  }) {
    return DropdownButtonFormField<String>(
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: const Icon(Icons.language),
      ),
      value: value,
      items: SupportedLanguages.all.map((lang) {
        return DropdownMenuItem(
          value: lang.code,
          child: Text('${lang.name} (${lang.nativeName})'),
        );
      }).toList(),
      onChanged: onChanged,
    );
  }

  Widget _buildThemeSelector() {
    return SegmentedButton<String>(
      segments: const [
        ButtonSegment(
          value: 'light',
          label: Text('Light'),
          icon: Icon(Icons.light_mode),
        ),
        ButtonSegment(
          value: 'dark',
          label: Text('Dark'),
          icon: Icon(Icons.dark_mode),
        ),
        ButtonSegment(
          value: 'system',
          label: Text('System'),
          icon: Icon(Icons.brightness_auto),
        ),
      ],
      selected: {_selectedTheme ?? 'system'},
      onSelectionChanged: (Set<String> newSelection) {
        setState(() {
          _selectedTheme = newSelection.first;
          _hasChanges = true;
        });
      },
    );
  }

  Widget _buildLocationSection(BuildContext context) {
    final authState = ref.watch(authProvider);
    final user = authState.user;
    final locationService = ref.watch(locationServiceProvider);

    return _buildSection(
      title: 'Location',
      children: [
        // Current location info
        if (user?.country != null || user?.city != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Row(
              children: [
                const Icon(Icons.location_on, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    [user?.city, user?.region, user?.country]
                        .where((s) => s != null && s.isNotEmpty)
                        .join(', '),
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
              ],
            ),
          ),
        // Enable location switch
        SwitchListTile(
          key: const Key(TestTags.preferencesLocationSwitch),
          title: const Text('Enable Location Tracking'),
          subtitle: const Text(
            'Automatically detect language based on location',
          ),
          value: _enableLocationTracking ?? true,
          onChanged: (value) async {
            if (value) {
              // Request permission when enabling
              final hasPermission = await locationService.requestPermission();
              if (!hasPermission && mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text('Location permission required'),
                    action: SnackBarAction(
                      label: 'Settings',
                      onPressed: () => locationService.openSettings(),
                    ),
                  ),
                );
                return;
              }
            }
            setState(() {
              _enableLocationTracking = value;
              _hasChanges = true;
            });
          },
        ),
        const SizedBox(height: 8),
        // Update location button
        FilledButton.tonalIcon(
          onPressed: () async {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Getting your location...')),
            );
            
            final success = await locationService.updateLocationOnServer();
            
            if (mounted) {
              ScaffoldMessenger.of(context).hideCurrentSnackBar();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    success
                        ? 'Location updated successfully'
                        : 'Failed to update location. Please grant permission.',
                  ),
                  action: !success
                      ? SnackBarAction(
                          label: 'Settings',
                          onPressed: () => locationService.openSettings(),
                        )
                      : null,
                ),
              );
            }
          },
          icon: const Icon(Icons.my_location),
          label: const Text('Update My Location'),
        ),
      ],
    );
  }
}

