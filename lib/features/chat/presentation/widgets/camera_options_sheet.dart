import 'package:flutter/material.dart';

/// Bottom sheet for camera/gallery options
class CameraOptionsSheet extends StatelessWidget {
  const CameraOptionsSheet({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 8),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: theme.colorScheme.onSurfaceVariant.withOpacity(0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),
          ListTile(
            leading: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.camera_alt,
                color: theme.colorScheme.primary,
              ),
            ),
            title: const Text('Take Photo'),
            subtitle: const Text('Use camera to capture text'),
            onTap: () => Navigator.pop(context, 'camera'),
          ),
          ListTile(
            leading: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: theme.colorScheme.secondaryContainer,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.photo_library,
                color: theme.colorScheme.secondary,
              ),
            ),
            title: const Text('Choose from Gallery'),
            subtitle: const Text('Select an existing image'),
            onTap: () => Navigator.pop(context, 'gallery'),
          ),
          SizedBox(height: MediaQuery.of(context).padding.bottom + 16),
        ],
      ),
    );
  }
}

