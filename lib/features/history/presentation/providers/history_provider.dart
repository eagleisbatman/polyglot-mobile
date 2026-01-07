import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/services/history_api_service.dart';

final historyApiServiceProvider = Provider<HistoryApiService>((ref) {
  return HistoryApiService();
});

class HistoryState {
  final bool isLoading;
  final String? error;
  final List<Conversation> conversations;
  final int total;
  final int limit;
  final int page;
  final String filterType; // 'all', 'voice', 'vision', 'document'

  HistoryState({
    this.isLoading = false,
    this.error,
    this.conversations = const [],
    this.total = 0,
    this.limit = 20,
    this.page = 1,
    this.filterType = 'all',
  });

  HistoryState copyWith({
    bool? isLoading,
    String? error,
    List<Conversation>? conversations,
    int? total,
    int? limit,
    int? page,
    String? filterType,
  }) {
    return HistoryState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      conversations: conversations ?? this.conversations,
      total: total ?? this.total,
      limit: limit ?? this.limit,
      page: page ?? this.page,
      filterType: filterType ?? this.filterType,
    );
  }
  
  bool get hasMore => conversations.length < total;
}

class HistoryNotifier extends StateNotifier<HistoryState> {
  final HistoryApiService _historyApiService;

  HistoryNotifier(this._historyApiService) : super(HistoryState()) {
    loadConversations();
  }

  Future<void> loadConversations({
    String? type,
    bool refresh = false,
  }) async {
    final filterType = type ?? state.filterType;
    final page = refresh ? 1 : state.page;

    state = state.copyWith(
      isLoading: true,
      error: null,
    );

    final response = await _historyApiService.getConversations(
      type: filterType,
      page: page,
      limit: state.limit,
    );

    if (response.success && response.data != null) {
      final newConversations = refresh
          ? response.data!.items
          : [...state.conversations, ...response.data!.items];
      
      state = state.copyWith(
        isLoading: false,
        conversations: newConversations,
        total: response.data!.total,
        page: page + 1,
        filterType: filterType,
      );
    } else {
      state = state.copyWith(
        isLoading: false,
        error: response.error ?? 'Failed to load history',
      );
    }
  }

  Future<void> loadMore() async {
    if (!state.hasMore || state.isLoading) {
      return;
    }
    await loadConversations();
  }

  Future<void> refresh() async {
    await loadConversations(refresh: true);
  }

  Future<void> filterByType(String type) async {
    await loadConversations(type: type, refresh: true);
  }

  Future<bool> deleteConversation(String id) async {
    final response = await _historyApiService.deleteConversation(id);

    if (response.success) {
      state = state.copyWith(
        conversations: state.conversations.where((c) => c.id != id).toList(),
        total: state.total - 1,
      );
      return true;
    } else {
      state = state.copyWith(
        error: response.error ?? 'Failed to delete conversation',
      );
      return false;
    }
  }

  Future<ConversationDetailResponse?> getConversationMessages(String conversationId) async {
    final response = await _historyApiService.getConversationMessages(conversationId);

    if (response.success && response.data != null) {
      return response.data;
    } else {
      state = state.copyWith(
        error: response.error ?? 'Failed to load conversation',
      );
      return null;
    }
  }
}

final historyProvider =
    StateNotifierProvider<HistoryNotifier, HistoryState>((ref) {
  final historyApiService = ref.watch(historyApiServiceProvider);
  return HistoryNotifier(historyApiService);
});
