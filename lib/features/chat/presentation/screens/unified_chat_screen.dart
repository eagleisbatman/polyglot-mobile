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
    return Expanded(
      child: state.messages.isEmpty
          ? const ChatEmptyState()
          : ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.only(top: 16, bottom: 8),
              itemCount: state.messages.length,
              itemBuilder: (context, index) {
                final message = state.messages[index];
                return ChatMessageBubble(
                  message: message,
                  onPlayAudio: message.audioUrl != null
                      ? () {
                          // TODO: Play audio
                        }
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
