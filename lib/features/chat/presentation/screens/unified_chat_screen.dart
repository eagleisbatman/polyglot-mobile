import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import '../providers/chat_provider.dart';
import '../widgets/chat_input_bar.dart';
import '../widgets/chat_message_bubble.dart';
import '../widgets/compact_language_selector.dart';
import '../widgets/camera_options_sheet.dart';
import '../widgets/language_selector_sheet.dart';
import '../widgets/chat_empty_state.dart';
import '../../domain/entities/chat_message.dart';

/// Unified chat screen combining voice, vision, and document translation
/// in a single conversational interface
class UnifiedChatScreen extends ConsumerStatefulWidget {
  const UnifiedChatScreen({super.key});

  @override
  ConsumerState<UnifiedChatScreen> createState() => _UnifiedChatScreenState();
}

class _UnifiedChatScreenState extends ConsumerState<UnifiedChatScreen> {
  final _scrollController = ScrollController();
  final _imagePicker = ImagePicker();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      Future.delayed(const Duration(milliseconds: 100), () {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      });
    }
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }

  Future<void> _handleCamera() async {
    final result = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => const CameraOptionsSheet(),
    );

    if (result != null && mounted) {
      final XFile? image;
      if (result == 'camera') {
        image = await _imagePicker.pickImage(source: ImageSource.camera);
      } else {
        image = await _imagePicker.pickImage(source: ImageSource.gallery);
      }
      
      if (image != null) {
        ref.read(chatProvider.notifier).addImageMessage(image.path);
        _scrollToBottom();
      }
    }
  }

  Future<void> _handleAttachment() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'doc', 'docx', 'txt'],
    );

    if (result != null && result.files.isNotEmpty) {
      final file = result.files.first;
      ref.read(chatProvider.notifier).addDocumentMessage(
        file.path ?? '',
        file.name,
      );
      _scrollToBottom();
    }
  }

  void _showLanguageSelector() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => LanguageSelectorSheet(
        sourceLanguage: ref.read(chatProvider).sourceLanguage,
        targetLanguage: ref.read(chatProvider).targetLanguage,
        onSourceChanged: ref.read(chatProvider.notifier).setSourceLanguage,
        onTargetChanged: ref.read(chatProvider.notifier).setTargetLanguage,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(chatProvider);
    final notifier = ref.read(chatProvider.notifier);
    final theme = Theme.of(context);

    // Auto-scroll when new messages arrive
    ref.listen<ChatState>(chatProvider, (previous, next) {
      if (previous?.messages.length != next.messages.length) {
        _scrollToBottom();
      }
    });

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: _buildAppBar(state, notifier, theme),
      body: Column(
        children: [
          _buildMessagesList(state, theme),
          _buildInputBar(state, notifier),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(
    ChatState state,
    ChatNotifier notifier,
    ThemeData theme,
  ) {
    return AppBar(
      backgroundColor: theme.colorScheme.surface,
      surfaceTintColor: Colors.transparent,
      title: CompactLanguageSelector(
        sourceLanguage: state.sourceLanguage,
        targetLanguage: state.targetLanguage,
        onTap: _showLanguageSelector,
        onSwap: notifier.swapLanguages,
      ),
      centerTitle: true,
      leading: IconButton(
        icon: const Icon(Icons.menu),
        onPressed: () {
          // TODO: Open drawer or settings
        },
      ),
      actions: [
        // New translation button
        if (state.messages.isNotEmpty)
          IconButton(
            icon: const Icon(Icons.add_comment_outlined),
            tooltip: 'New translation',
            onPressed: notifier.startNewSession,
          ),
        IconButton(
          icon: const Icon(Icons.history),
          onPressed: () => context.push('/history'),
        ),
        IconButton(
          icon: const Icon(Icons.person_outline),
          onPressed: () => context.push('/profile'),
        ),
      ],
    );
  }

  Widget _buildMessagesList(ChatState state, ThemeData theme) {
    final notifier = ref.read(chatProvider.notifier);
    final hasLiveContent = state.liveUserText != null || state.liveModelText != null;
    final itemCount = state.messages.length + (hasLiveContent ? 1 : 0);
    
    return Expanded(
      child: state.messages.isEmpty && !hasLiveContent
          ? const ChatEmptyState()
          : ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.only(top: 16, bottom: 8),
              itemCount: itemCount,
              itemBuilder: (context, index) {
                // Show live streaming content at the end
                if (index == state.messages.length && hasLiveContent) {
                  return _buildLiveStreamingBubble(state, theme);
                }
                
                final message = state.messages[index];
                return ChatMessageBubble(
                  message: message,
                  isPlayingUserAudio: state.currentlyPlayingId == '${message.id}_user',
                  isPlayingTranslation: state.currentlyPlayingId == '${message.id}_translation',
                  onPlayUserAudio: message.userAudioPath != null
                      ? () => notifier.playUserAudio(message.id)
                      : null,
                  onPlayTranslationAudio: message.translatedContent != null
                      ? () => notifier.playTranslationAudio(message.id)
                      : null,
                  onRetry: message.status == MessageStatus.error
                      ? () {
                          // TODO: Retry translation
                        }
                      : null,
                );
              },
            ),
    );
  }

  Widget _buildLiveStreamingBubble(ChatState state, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // User's live transcription
          if (state.liveUserText != null && state.liveUserText!.isNotEmpty)
            Align(
              alignment: Alignment.centerRight,
              child: Container(
                constraints: BoxConstraints(
                  maxWidth: MediaQuery.of(context).size.width * 0.75,
                ),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.7),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: theme.colorScheme.primary.withOpacity(0.3),
                    style: BorderStyle.solid,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.mic,
                          size: 14,
                          color: theme.colorScheme.primary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'LISTENING...',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: theme.colorScheme.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      state.liveUserText!,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.8),
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          
          const SizedBox(height: 8),
          
          // Model's live translation
          if (state.liveModelText != null && state.liveModelText!.isNotEmpty)
            Align(
              alignment: Alignment.centerLeft,
              child: Container(
                constraints: BoxConstraints(
                  maxWidth: MediaQuery.of(context).size.width * 0.75,
                ),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer.withOpacity(0.7),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: theme.colorScheme.primary.withOpacity(0.3),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.translate,
                          size: 14,
                          color: theme.colorScheme.primary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'TRANSLATING...',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: theme.colorScheme.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      state.liveModelText!,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onPrimaryContainer,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildInputBar(ChatState state, ChatNotifier notifier) {
    return ChatInputBar(
      isRecording: state.isRecording,
      isProcessing: state.isProcessing,
      recordingDuration: _formatDuration(state.recordingDuration),
      onMicPressed: state.isRecording
          ? notifier.stopRecording
          : notifier.startRecording,
      onCameraPressed: _handleCamera,
      onAttachmentPressed: _handleAttachment,
      onCancelRecording: notifier.cancelRecording,
    );
  }
}
