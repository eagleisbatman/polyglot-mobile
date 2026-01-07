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
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // User content (original input)
          if (message.userContent != null && message.userContent!.isNotEmpty)
            UserMessageBubble(
              content: message.userContent!,
              type: message.type,
              imageUrl: message.imageUrl,
              documentName: message.documentName,
              hasAudio: message.userAudioPath != null,
              isPlaying: isPlayingUserAudio,
              onPlayAudio: onPlayUserAudio,
            ),
          
          const SizedBox(height: 8),
          
          // Translation response
          TranslationMessageBubble(
            message: message,
            onPlayAudio: onPlayTranslationAudio,
            onRetry: onRetry,
            isPlaying: isPlayingTranslation,
          ),
        ],
      ),
    );
  }
}
