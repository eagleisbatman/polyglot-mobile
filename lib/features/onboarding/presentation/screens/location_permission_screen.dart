import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import '../../../../core/services/auth_service.dart';
import '../../../../core/services/location_service.dart';

class LocationPermissionScreen extends ConsumerStatefulWidget {
  const LocationPermissionScreen({super.key});

  @override
  ConsumerState<LocationPermissionScreen> createState() =>
      _LocationPermissionScreenState();
}

class _LocationPermissionScreenState
    extends ConsumerState<LocationPermissionScreen> {
  bool _isLoading = false;
  int _denialCount = 0;

  Future<void> _requestLocation() async {
    setState(() => _isLoading = true);

    final locationService = ref.read(locationServiceProvider);

    // Check current permission status
    final permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.deniedForever) {
      // Permission permanently denied - show settings option
      if (mounted) {
        _showSettingsDialog();
      }
      setState(() => _isLoading = false);
      return;
    }

    // Request permission
    final granted = await locationService.requestPermission();

    if (granted) {
      // Permission granted - get location and continue
      await locationService.updateLocationOnServer();
      if (mounted) {
        _completeOnboarding();
      }
    } else {
      // Permission denied
      _denialCount++;
      
      if (_denialCount >= 2) {
        // After 2 denials, show settings dialog
        if (mounted) {
          _showSettingsDialog();
        }
      } else {
        // First denial - show message and allow skip
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Location helps us provide better translations'),
              duration: Duration(seconds: 2),
            ),
          );
        }
      }
    }

    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  void _showSettingsDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Location Permission'),
        content: const Text(
          'Location permission was denied. You can enable it in Settings, '
          'or we\'ll use your approximate location based on your network.',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _skipLocation();
            },
            child: const Text('Use Approximate'),
          ),
          FilledButton(
            onPressed: () async {
              Navigator.of(context).pop();
              await Geolocator.openAppSettings();
            },
            child: const Text('Open Settings'),
          ),
        ],
      ),
    );
  }

  Future<void> _skipLocation() async {
    setState(() => _isLoading = true);

    try {
      // Get location from IP (handled by backend)
      final authService = ref.read(authServiceProvider);
      final userId = await authService.getCurrentUserId();
      
      if (userId != null) {
        // Backend will use IP-based location when no coordinates provided
        await authService.updateLocation(
          userId: userId,
          // Empty location triggers IP-based detection on backend
        );
      }

      if (mounted) {
        _completeOnboarding();
      }
    } catch (e) {
      debugPrint('Skip location error: $e');
      if (mounted) {
        // Still complete onboarding even if IP location fails
        _completeOnboarding();
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _completeOnboarding() {
    // Mark onboarding as complete and navigate to main app
    ref.read(authProvider.notifier).completeOnboarding();
    
    // Pop all screens and go to home
    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const Spacer(flex: 1),

              // Location illustration
              Container(
                width: 180,
                height: 180,
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer,
                  shape: BoxShape.circle,
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Pulse animation effect (static for now)
                    ...List.generate(3, (index) {
                      return Container(
                        width: 180 - (index * 30),
                        height: 180 - (index * 30),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: theme.colorScheme.primary
                                .withOpacity(0.2 - (index * 0.05)),
                            width: 2,
                          ),
                        ),
                      );
                    }),
                    Icon(
                      Icons.location_on_rounded,
                      size: 80,
                      color: theme.colorScheme.primary,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 48),

              // Title
              Text(
                'Enable Location',
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 16),

              // Description
              Text(
                'Share your location so we can suggest relevant languages '
                'and provide better translation experiences based on where you are.',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  height: 1.5,
                ),
              ),

              const SizedBox(height: 12),

              // Privacy note
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.shield_outlined,
                      size: 20,
                      color: theme.colorScheme.primary,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Your location is only used to improve translations. '
                        'We never share it with third parties.',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const Spacer(flex: 2),

              // Allow location button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: FilledButton.icon(
                  onPressed: _isLoading ? null : _requestLocation,
                  icon: _isLoading
                      ? SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: theme.colorScheme.onPrimary,
                          ),
                        )
                      : const Icon(Icons.my_location),
                  label: Text(
                    _isLoading ? 'Getting Location...' : 'Allow Location Access',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  style: FilledButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // Skip button
              SizedBox(
                width: double.infinity,
                height: 48,
                child: TextButton(
                  onPressed: _isLoading ? null : _skipLocation,
                  child: Text(
                    'Not Now',
                    style: TextStyle(
                      fontSize: 16,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}

