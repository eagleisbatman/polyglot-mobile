import 'package:flutter/material.dart';
import '../../domain/entities/chat_message.dart';

/// Bubble for user-sent content (voice input, image, document)
class UserMessageBubble extends StatelessWidget {
  final String content;
  final MessageType type;
  final String? imageUrl;
  final String? documentName;
  final bool hasAudio;
  final bool isPlaying;
  final VoidCallback? onPlayAudio;

  const UserMessageBubble({
    super.key,
    required this.content,
    required this.type,
    this.imageUrl,
    this.documentName,
    this.hasAudio = false,
    this.isPlaying = false,
    this.onPlayAudio,
  });

  IconData _getTypeIcon() {
    switch (type) {
      case MessageType.voice:
        return Icons.mic;
      case MessageType.vision:
        return Icons.image;
      case MessageType.document:
        return Icons.description;
      case MessageType.text:
        return Icons.chat_bubble_outline;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Align(
      alignment: Alignment.centerRight,
      child: Container(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHighest,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(16),
            topRight: Radius.circular(16),
            bottomLeft: Radius.circular(16),
            bottomRight: Radius.circular(4),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _TypeIndicator(type: type, icon: _getTypeIcon(), theme: theme),
            const SizedBox(height: 6),
            if (imageUrl != null) _ImagePreview(imageUrl: imageUrl!, theme: theme),
            if (documentName != null) _DocumentChip(name: documentName!, theme: theme),
            Text(
              content,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface,
              ),
            ),
            // Play audio button for voice messages
            if (type == MessageType.voice && hasAudio && onPlayAudio != null)
              _PlayUserAudioButton(
                theme: theme,
                isPlaying: isPlaying,
                onPressed: onPlayAudio!,
              ),
          ],
        ),
      ),
    );
  }
}

class _TypeIndicator extends StatelessWidget {
  final MessageType type;
  final IconData icon;
  final ThemeData theme;

  const _TypeIndicator({
    required this.type,
    required this.icon,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: 14,
          color: theme.colorScheme.onSurfaceVariant.withOpacity(0.6),
        ),
        const SizedBox(width: 4),
        Text(
          type.name.toUpperCase(),
          style: theme.textTheme.labelSmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant.withOpacity(0.6),
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }
}

class _ImagePreview extends StatelessWidget {
  final String imageUrl;
  final ThemeData theme;

  const _ImagePreview({required this.imageUrl, required this.theme});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.network(
            imageUrl,
            height: 120,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => Container(
              height: 60,
              decoration: BoxDecoration(
                color: theme.colorScheme.error.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Center(
                child: Icon(Icons.broken_image, size: 24),
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
      ],
    );
  }
}

class _DocumentChip extends StatelessWidget {
  final String name;
  final ThemeData theme;

  const _DocumentChip({required this.name, required this.theme});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          decoration: BoxDecoration(
            color: theme.colorScheme.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.insert_drive_file,
                size: 16,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  name,
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: theme.colorScheme.primary,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
      ],
    );
  }
}

class _PlayUserAudioButton extends StatelessWidget {
  final ThemeData theme;
  final bool isPlaying;
  final VoidCallback onPressed;

  const _PlayUserAudioButton({
    required this.theme,
    required this.isPlaying,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: theme.colorScheme.secondary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                isPlaying ? Icons.stop : Icons.play_arrow,
                size: 16,
                color: theme.colorScheme.secondary,
              ),
              const SizedBox(width: 6),
              Text(
                isPlaying ? 'Stop' : 'Play my voice',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.secondary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

