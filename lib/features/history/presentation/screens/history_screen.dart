import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/test_tags.dart';
import '../../../../shared/widgets/error_banner.dart';
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
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Item'),
        content: const Text('Are you sure you want to delete this item?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      final success = await ref.read(historyProvider.notifier).deleteItem(id);
      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Item deleted successfully')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final historyState = ref.watch(historyProvider);
    final notifier = ref.read(historyProvider.notifier);

    return Scaffold(
      key: const Key(TestTags.historyScreen),
      appBar: AppBar(
        title: const Text('Translation History'),
        actions: [
          PopupMenuButton<String>(
            key: const Key(TestTags.historyFilterButton),
            onSelected: (value) {
              notifier.filterByType(value);
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'all',
                child: Text('All'),
              ),
              const PopupMenuItem(
                value: 'voice',
                child: Text('Voice'),
              ),
              const PopupMenuItem(
                value: 'vision',
                child: Text('Vision'),
              ),
              const PopupMenuItem(
                value: 'document',
                child: Text('Document'),
              ),
            ],
            child: const Icon(Icons.filter_list),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => notifier.refresh(),
        child: Column(
          children: [
            if (historyState.error != null)
              Padding(
                padding: const EdgeInsets.all(16),
                child: ErrorBanner(
                  message: historyState.error!,
                  onRetry: () => notifier.refresh(),
                ),
              ),
            // Initial loading state (empty items, loading)
            if (historyState.items.isEmpty && historyState.isLoading)
              const Expanded(
                child: Center(
                  child: CircularProgressIndicator(),
                ),
              )
            // Empty state (no items, not loading)
            else if (historyState.items.isEmpty && !historyState.isLoading)
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.history,
                        size: 64,
                        color: Theme.of(context).colorScheme.outline,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No history yet',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Your translation history will appear here',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
              )
            // Items list
            else
              Expanded(
                child: ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(16),
                  itemCount: historyState.items.length +
                      (historyState.isLoading ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (index >= historyState.items.length) {
                      return const Padding(
                        padding: EdgeInsets.all(16),
                        child: Center(child: CircularProgressIndicator()),
                      );
                    }

                    final item = historyState.items[index];
                    return Card(
                      key: Key('${TestTags.historyItem}_${item.id}'),
                      margin: const EdgeInsets.only(bottom: 12),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Header row: icon, languages, time, menu
                            Row(
                              children: [
                                _getTypeIcon(item.type),
                                const SizedBox(width: 8),
                                Text(
                                  '${item.sourceLanguage ?? 'Auto'} → ${item.targetLanguage.toUpperCase()}',
                                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                                    color: Theme.of(context).colorScheme.primary,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const Spacer(),
                                Text(
                                  _formatDate(item.createdAt),
                                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: Theme.of(context).colorScheme.outline,
                                  ),
                                ),
                                PopupMenuButton(
                                  padding: EdgeInsets.zero,
                                  iconSize: 20,
                                  itemBuilder: (context) => [
                                    PopupMenuItem(
                                      child: const Text('Delete'),
                                      onTap: () {
                                        Future.delayed(Duration.zero, () {
                                          _handleDelete(item.id);
                                        });
                                      },
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            // Transcription (original text)
                            Text(
                              item.displayTitle,
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.w500,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            // Translation
                            if (item.displaySubtitle != null) ...[
                              const SizedBox(height: 6),
                              Text(
                                item.displaySubtitle!,
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                                  fontStyle: FontStyle.italic,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }

  Icon _getTypeIcon(String type) {
    switch (type) {
      case 'voice':
        return const Icon(Icons.mic);
      case 'vision':
        return const Icon(Icons.camera_alt);
      case 'document':
        return const Icon(Icons.description);
      default:
        return const Icon(Icons.translate);
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
        return '${difference.inMinutes} minutes ago';
      }
      return '${difference.inHours} hours ago';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
    }
  }
}

