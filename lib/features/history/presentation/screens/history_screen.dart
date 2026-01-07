import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/test_tags.dart';
import '../../../../core/services/history_api_service.dart';
import '../../../chat/domain/entities/chat_message.dart';
import '../../../chat/presentation/providers/chat_provider.dart';
import '../providers/history_provider.dart';

class HistoryScreen extends ConsumerStatefulWidget {
  const HistoryScreen({super.key});

  @override
  ConsumerState<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends ConsumerState<HistoryScreen> {
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    // Refresh history when screen opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(historyProvider.notifier).refresh();
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent * 0.9) {
      ref.read(historyProvider.notifier).loadMore();
    }
  }

  Future<void> _handleDelete(String id) async {
    final success = await ref.read(historyProvider.notifier).deleteConversation(id);
    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Deleted'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final historyState = ref.watch(historyProvider);
    final notifier = ref.read(historyProvider.notifier);
    final theme = Theme.of(context);

    return Scaffold(
      key: const Key(TestTags.historyScreen),
      appBar: AppBar(
        title: const Text('History'),
        centerTitle: false,
      ),
      body: Column(
        children: [
          // Filter chips
          _buildFilterChips(historyState.filterType, notifier, theme),
          
          // Error state
          if (historyState.error != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: theme.colorScheme.errorContainer,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(Icons.error_outline, 
                      color: theme.colorScheme.onErrorContainer, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        historyState.error!,
                        style: TextStyle(color: theme.colorScheme.onErrorContainer),
                      ),
                    ),
                    TextButton(
                      onPressed: () => notifier.refresh(),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            ),
          
          // Content
          Expanded(
            child: RefreshIndicator(
              onRefresh: () => notifier.refresh(),
              child: _buildContent(historyState, theme),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChips(String activeFilter, HistoryNotifier notifier, ThemeData theme) {
    final filters = [
      ('all', 'All', Icons.apps),
      ('voice', 'Voice', Icons.mic),
      ('vision', 'Camera', Icons.camera_alt),
      ('document', 'Docs', Icons.description),
    ];

    return Container(
      height: 48,
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: filters.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final (value, label, icon) = filters[index];
          final isActive = activeFilter == value;
          
          return FilterChip(
            key: Key('${TestTags.historyFilterButton}_$value'),
            selected: isActive,
            label: Text(label),
            avatar: Icon(icon, size: 16),
            onSelected: (_) => notifier.filterByType(value),
            showCheckmark: false,
            side: BorderSide.none,
            backgroundColor: theme.colorScheme.surfaceContainerHighest,
            selectedColor: theme.colorScheme.primaryContainer,
          );
        },
      ),
    );
  }

  Widget _buildContent(HistoryState historyState, ThemeData theme) {
    // Loading state
    if (historyState.conversations.isEmpty && historyState.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    // Empty state
    if (historyState.conversations.isEmpty && !historyState.isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.history,
                size: 48,
                color: theme.colorScheme.outline,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'No translations yet',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Start a translation to see it here',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.outline,
              ),
            ),
          ],
        ),
      );
    }

    // Conversations list
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
      itemCount: historyState.conversations.length,
      itemBuilder: (context, index) {
        final conversation = historyState.conversations[index];
        
        return Dismissible(
          key: Key(conversation.id),
          direction: DismissDirection.endToStart,
          background: Container(
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 20),
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: theme.colorScheme.error,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(Icons.delete, color: theme.colorScheme.onError),
          ),
          onDismissed: (_) => _handleDelete(conversation.id),
          child: _buildConversationCard(conversation, theme),
        );
      },
    );
  }

  Widget _buildConversationCard(Conversation conversation, ThemeData theme) {
    final preview = conversation.preview;
    final typeIcon = _getTypeIconData(preview?.type ?? 'voice');
    
    return GestureDetector(
      onTap: () => _openConversation(conversation),
      child: Container(
        key: Key('${TestTags.historyItem}_${conversation.id}'),
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top row: type badge, message count, time
            Row(
              children: [
                // Type badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(typeIcon, size: 14, 
                        color: theme.colorScheme.onPrimaryContainer),
                      const SizedBox(width: 4),
                      Text(
                        '${conversation.sourceLanguage?.toUpperCase() ?? 'AUTO'} → ${conversation.targetLanguage.toUpperCase()}',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.colorScheme.onPrimaryContainer,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                // Message count badge
                if (conversation.messageCount > 1)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.secondaryContainer,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      '${conversation.messageCount} msgs',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.onSecondaryContainer,
                      ),
                    ),
                  ),
                const Spacer(),
                Text(
                  _formatDate(conversation.updatedAt),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.outline,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 12),
            
            // Original text (from preview)
            Text(
              conversation.displayTitle,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
                height: 1.4,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            
            // Translation (from preview)
            if (conversation.displaySubtitle != null) ...[
              const SizedBox(height: 8),
              Text(
                conversation.displaySubtitle!,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  height: 1.4,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _openConversation(Conversation conversation) async {
    // Fetch all messages in this conversation
    final detail = await ref.read(historyProvider.notifier)
        .getConversationMessages(conversation.id);
    
    if (detail == null || !mounted) return;
    
    // Convert all messages to ChatMessages
    final chatMessages = detail.messages.map((msg) {
      MessageType msgType;
      switch (msg.type) {
        case 'voice':
          msgType = MessageType.voice;
          break;
        case 'vision':
          msgType = MessageType.vision;
          break;
        case 'document':
          msgType = MessageType.document;
          break;
        default:
          msgType = MessageType.text;
      }
      
      return ChatMessage(
        id: msg.id,
        type: msgType,
        status: MessageStatus.complete,
        userContent: msg.transcription ?? msg.extractedText,
        translatedContent: msg.translation,
        userAudioPath: msg.userAudioUrl,
        translationAudioPath: msg.translationAudioUrl,
        imageUrl: msg.imageUrl,
        documentName: msg.documentName,
        sourceLanguage: msg.sourceLanguage ?? 'en',
        targetLanguage: msg.targetLanguage,
        timestamp: msg.createdAt,
      );
    }).toList();
    
    // Load conversation into chat provider
    ref.read(chatProvider.notifier).loadConversation(
      conversationId: conversation.id,
      messages: chatMessages,
      sourceLanguage: conversation.sourceLanguage ?? 'en',
      targetLanguage: conversation.targetLanguage,
    );
    
    // Navigate to chat screen
    context.go('/');
  }

  IconData _getTypeIconData(String type) {
    switch (type) {
      case 'voice':
        return Icons.mic;
      case 'vision':
        return Icons.camera_alt;
      case 'document':
        return Icons.description;
      default:
        return Icons.translate;
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      if (difference.inHours == 0) {
        if (difference.inMinutes == 0) {
          return 'Just now';
        }
        return '${difference.inMinutes}m ago';
      }
      return '${difference.inHours}h ago';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}
