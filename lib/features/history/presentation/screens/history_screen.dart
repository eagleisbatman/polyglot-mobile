import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/test_tags.dart';
import '../../../../core/services/history_api_service.dart';
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
    final success = await ref.read(historyProvider.notifier).deleteItem(id);
    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Deleted'),
          behavior: SnackBarBehavior.floating,
          action: SnackBarAction(
            label: 'Undo',
            onPressed: () {
              // TODO: Implement undo
            },
          ),
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
    if (historyState.items.isEmpty && historyState.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    // Empty state
    if (historyState.items.isEmpty && !historyState.isLoading) {
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

    // Items list
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
      itemCount: historyState.items.length,
      itemBuilder: (context, index) {
        final item = historyState.items[index];
        
        return Dismissible(
          key: Key(item.id),
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
          onDismissed: (_) => _handleDelete(item.id),
          child: _buildHistoryCard(item, theme),
        );
      },
    );
  }

  Widget _buildHistoryCard(HistoryItem item, ThemeData theme) {
    final typeIcon = _getTypeIconData(item.type);
    
    return GestureDetector(
      onTap: () => _showTranslationDetails(item, theme),
      child: Container(
        key: Key('${TestTags.historyItem}_${item.id}'),
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
            // Top row: type badge, time
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
                        '${item.sourceLanguage?.toUpperCase() ?? 'AUTO'} → ${item.targetLanguage.toUpperCase()}',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.colorScheme.onPrimaryContainer,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                Text(
                  _formatDate(item.createdAt),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.outline,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 12),
            
            // Original text
            Text(
              item.displayTitle,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
                height: 1.4,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            
            // Translation
            if (item.displaySubtitle != null) ...[
              const SizedBox(height: 8),
              Text(
                item.displaySubtitle!,
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

  void _showTranslationDetails(HistoryItem item, ThemeData theme) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (context, scrollController) => Container(
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              // Handle bar
              Container(
                margin: const EdgeInsets.only(top: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: theme.colorScheme.outlineVariant,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              
              // Header
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primaryContainer,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(_getTypeIconData(item.type), size: 16,
                            color: theme.colorScheme.onPrimaryContainer),
                          const SizedBox(width: 6),
                          Text(
                            '${item.sourceLanguage?.toUpperCase() ?? 'AUTO'} → ${item.targetLanguage.toUpperCase()}',
                            style: theme.textTheme.labelMedium?.copyWith(
                              color: theme.colorScheme.onPrimaryContainer,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Spacer(),
                    Text(
                      _formatDate(item.createdAt),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.outline,
                      ),
                    ),
                  ],
                ),
              ),
              
              const Divider(height: 1),
              
              // Content
              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(16),
                  children: [
                    // Original text section
                    _buildSection(
                      theme: theme,
                      title: 'Original',
                      content: item.transcription ?? item.displayTitle,
                      icon: Icons.record_voice_over,
                    ),
                    
                    const SizedBox(height: 20),
                    
                    // Translation section
                    _buildSection(
                      theme: theme,
                      title: 'Translation',
                      content: item.translation ?? item.displaySubtitle ?? '',
                      icon: Icons.translate,
                    ),
                    
                    if (item.summary != null && item.summary!.isNotEmpty) ...[
                      const SizedBox(height: 20),
                      _buildSection(
                        theme: theme,
                        title: 'Summary',
                        content: item.summary!,
                        icon: Icons.short_text,
                      ),
                    ],
                    
                    // Audio playback buttons (if available)
                    if (item.userAudioUrl != null || item.translationAudioUrl != null) ...[
                      const SizedBox(height: 24),
                      Row(
                        children: [
                          if (item.userAudioUrl != null)
                            Expanded(
                              child: _buildPlayButton(
                                theme: theme,
                                label: 'Play Original',
                                icon: Icons.play_circle_outline,
                                onTap: () {
                                  // TODO: Play user audio
                                },
                              ),
                            ),
                          if (item.userAudioUrl != null && item.translationAudioUrl != null)
                            const SizedBox(width: 12),
                          if (item.translationAudioUrl != null)
                            Expanded(
                              child: _buildPlayButton(
                                theme: theme,
                                label: 'Play Translation',
                                icon: Icons.volume_up,
                                onTap: () {
                                  // TODO: Play translation audio
                                },
                              ),
                            ),
                        ],
                      ),
                    ],
                    
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSection({
    required ThemeData theme,
    required String title,
    required String content,
    required IconData icon,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 16, color: theme.colorScheme.primary),
            const SizedBox(width: 6),
            Text(
              title,
              style: theme.textTheme.labelMedium?.copyWith(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(10),
          ),
          child: SelectableText(
            content,
            style: theme.textTheme.bodyMedium?.copyWith(
              height: 1.5,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPlayButton({
    required ThemeData theme,
    required String label,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Material(
      color: theme.colorScheme.secondaryContainer,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 20, color: theme.colorScheme.onSecondaryContainer),
              const SizedBox(width: 8),
              Text(
                label,
                style: theme.textTheme.labelMedium?.copyWith(
                  color: theme.colorScheme.onSecondaryContainer,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
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
