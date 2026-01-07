import 'package:flutter/material.dart';
import '../../domain/entities/chat_message.dart';
import 'streaming_dots.dart';

/// Bubble for AI translation responses
class TranslationMessageBubble extends StatelessWidget {
  final ChatMessage message;
  final VoidCallback? onPlayAudio;
  final VoidCallback? onRetry;

  const TranslationMessageBubble({
    super.key,
    required this.message,
    this.onPlayAudio,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isError = message.status == MessageStatus.error;
    final isStreaming = message.status == MessageStatus.streaming;
    final isSending = message.status == MessageStatus.sending;

    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isError
              ? theme.colorScheme.error.withOpacity(0.1)
              : theme.colorScheme.primaryContainer,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(16),
            topRight: Radius.circular(16),
            bottomLeft: Radius.circular(4),
            bottomRight: Radius.circular(16),
          ),
        ),
        child: _buildContent(theme, isError, isStreaming, isSending),
      ),
    );
  }

  Widget _buildContent(
    ThemeData theme,
    bool isError,
    bool isStreaming,
    bool isSending,
  ) {
    if (isError) {
      return _ErrorContent(
        error: message.error,
        theme: theme,
        onRetry: onRetry,
      );
    }

    if (isSending || (isStreaming && message.translatedContent == null)) {
      return _LoadingContent(
        isStreaming: isStreaming,
        theme: theme,
      );
    }

    return _TranslationContent(
      message: message,
      theme: theme,
      isStreaming: isStreaming,
      onPlayAudio: onPlayAudio,
    );
  }
}

class _ErrorContent extends StatelessWidget {
  final String? error;
  final ThemeData theme;
  final VoidCallback? onRetry;

  const _ErrorContent({
    required this.error,
    required this.theme,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.error_outline,
              size: 18,
              color: theme.colorScheme.error,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                error ?? 'Translation failed',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.error,
                ),
              ),
            ),
          ],
        ),
        if (onRetry != null) ...[
          const SizedBox(height: 8),
          TextButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh, size: 16),
            label: const Text('Retry'),
            style: TextButton.styleFrom(
              foregroundColor: theme.colorScheme.error,
              padding: EdgeInsets.zero,
              minimumSize: const Size(0, 32),
            ),
          ),
        ],
      ],
    );
  }
}

class _LoadingContent extends StatelessWidget {
  final bool isStreaming;
  final ThemeData theme;

  const _LoadingContent({
    required this.isStreaming,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 16,
          height: 16,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: theme.colorScheme.onPrimaryContainer,
          ),
        ),
        const SizedBox(width: 12),
        Text(
          isStreaming ? 'Translating...' : 'Processing...',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onPrimaryContainer.withOpacity(0.7),
            fontStyle: FontStyle.italic,
          ),
        ),
      ],
    );
  }
}

class _TranslationContent extends StatelessWidget {
  final ChatMessage message;
  final ThemeData theme;
  final bool isStreaming;
  final VoidCallback? onPlayAudio;

  const _TranslationContent({
    required this.message,
    required this.theme,
    required this.isStreaming,
    this.onPlayAudio,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          message.translatedContent ?? '',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onPrimaryContainer,
            height: 1.4,
          ),
        ),
        if (message.type == MessageType.voice &&
            message.audioUrl != null &&
            onPlayAudio != null)
          _PlayAudioButton(theme: theme, onPressed: onPlayAudio!),
        if (isStreaming) ...[
          const SizedBox(height: 4),
          const StreamingDots(),
        ],
      ],
    );
  }
}

class _PlayAudioButton extends StatelessWidget {
  final ThemeData theme;
  final VoidCallback onPressed;

  const _PlayAudioButton({
    required this.theme,
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
            color: theme.colorScheme.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.volume_up,
                size: 16,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(width: 6),
              Text(
                'Play audio',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.primary,
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

