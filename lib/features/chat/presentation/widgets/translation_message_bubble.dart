import 'package:flutter/material.dart';
import '../../domain/entities/chat_message.dart';
import 'streaming_dots.dart';
import 'audio_play_button.dart';

/// Bubble for AI translation responses
class TranslationMessageBubble extends StatelessWidget {
  final ChatMessage message;
  final VoidCallback? onPlayAudio;
  final VoidCallback? onRetry;
  final bool isPlaying;

  const TranslationMessageBubble({
    super.key,
    required this.message,
    this.onPlayAudio,
    this.onRetry,
    this.isPlaying = false,
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
      isPlaying: isPlaying,
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
  final bool isPlaying;
  final VoidCallback? onPlayAudio;

  const _TranslationContent({
    required this.message,
    required this.theme,
    required this.isStreaming,
    this.isPlaying = false,
    this.onPlayAudio,
  });

  @override
  Widget build(BuildContext context) {
    final hasAudio = message.translationAudioPath != null || 
                     message.translatedContent != null;
    
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
        // Show play button for voice messages (only when complete)
        if (message.type == MessageType.voice && hasAudio && onPlayAudio != null && message.status == MessageStatus.complete)
          Padding(
            padding: const EdgeInsets.only(top: 12),
            child: Align(
              alignment: Alignment.centerLeft,
              child: AudioPlayButton(
                isPlaying: isPlaying,
                onPressed: onPlayAudio!,
                color: theme.colorScheme.primary,
              ),
            ),
          ),
        if (isStreaming) ...[
          const SizedBox(height: 4),
          const StreamingDots(),
        ],
      ],
    );
  }
}


