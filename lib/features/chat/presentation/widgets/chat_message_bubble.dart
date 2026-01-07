import 'package:flutter/material.dart';
import '../../domain/entities/chat_message.dart';
import 'user_message_bubble.dart';
import 'translation_message_bubble.dart';

/// Chat message bubble combining user content and translation response
/// 
/// This is a composite widget that displays:
/// - User's original input (voice transcription, image, document)
/// - AI's translation response
class ChatMessageBubble extends StatelessWidget {
  final ChatMessage message;
  final VoidCallback? onPlayUserAudio;
  final VoidCallback? onPlayTranslationAudio;
  final VoidCallback? onRetry;
  final bool isPlayingUserAudio;
  final bool isPlayingTranslation;

  const ChatMessageBubble({
    super.key,
    required this.message,
    this.onPlayUserAudio,
    this.onPlayTranslationAudio,
    this.onRetry,
    this.isPlayingUserAudio = false,
    this.isPlayingTranslation = false,
  });

  @override
  Widget build(BuildContext context) {
    // Show user bubble if there's content OR if it's a voice message with audio
    final showUserBubble = (message.userContent != null && message.userContent!.isNotEmpty) ||
                           (message.type == MessageType.voice && message.userAudioPath != null);
    
    // For voice messages without transcription yet, show "Transcribing..."
    final userContent = message.userContent ?? 
        (message.status == MessageStatus.sending ? 'Transcribing...' : 'Voice message');
    
    // Only show translation bubble if:
    // 1. We have translated content, OR
    // 2. We have user content AND still processing (transcription done, now translating)
    final hasUserContent = message.userContent != null && message.userContent!.isNotEmpty;
    final showTranslationBubble = message.translatedContent != null || 
        (hasUserContent && message.status == MessageStatus.sending);
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // User content (original input)
          if (showUserBubble)
            UserMessageBubble(
              content: userContent,
              type: message.type,
              imageUrl: message.imageUrl,
              documentName: message.documentName,
              hasAudio: message.userAudioPath != null,
              isPlaying: isPlayingUserAudio,
              onPlayAudio: onPlayUserAudio,
            ),
          
          if (showUserBubble && showTranslationBubble)
            const SizedBox(height: 8),
          
          // Translation response
          if (showTranslationBubble)
            TranslationMessageBubble(
              message: message,
              onPlayAudio: onPlayTranslationAudio,
              onRetry: onRetry,
              isPlaying: isPlayingTranslation,
            ),
          
          // Error state
          if (message.status == MessageStatus.error && message.error != null)
            _ErrorBubble(error: message.error!),
        ],
      ),
    );
  }
}

class _ErrorBubble extends StatelessWidget {
  final String error;
  
  const _ErrorBubble({required this.error});
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(top: 4),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: theme.colorScheme.errorContainer,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, size: 16, color: theme.colorScheme.error),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                error,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onErrorContainer,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
