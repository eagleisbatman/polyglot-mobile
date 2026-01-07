import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/services/history_api_service.dart';

final historyApiServiceProvider = Provider<HistoryApiService>((ref) {
  return HistoryApiService();
});

class HistoryState {
  final bool isLoading;
  final String? error;
  final List<HistoryItem> items;
  final int total;
  final int limit;
  final int offset;
  final String filterType; // 'all', 'voice', 'vision', 'document'

  HistoryState({
    this.isLoading = false,
    this.error,
    this.items = const [],
    this.total = 0,
    this.limit = 50,
    this.offset = 0,
    this.filterType = 'all',
  });

  HistoryState copyWith({
    bool? isLoading,
    String? error,
    List<HistoryItem>? items,
    int? total,
    int? limit,
    int? offset,
    String? filterType,
  }) {
    return HistoryState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      items: items ?? this.items,
      total: total ?? this.total,
      limit: limit ?? this.limit,
      offset: offset ?? this.offset,
      filterType: filterType ?? this.filterType,
    );
  }
}

class HistoryNotifier extends StateNotifier<HistoryState> {
  final HistoryApiService _historyApiService;

  HistoryNotifier(this._historyApiService) : super(HistoryState()) {
    loadHistory();
  }

  Future<void> loadHistory({
    String? type,
    bool refresh = false,
  }) async {
    final filterType = type ?? state.filterType;

    state = state.copyWith(
      isLoading: true,
      error: null,
      offset: refresh ? 0 : state.offset,
    );

    final response = await _historyApiService.getHistory(
      type: filterType,
      limit: state.limit,
      offset: refresh ? 0 : state.offset,
    );

    if (response.success && response.data != null) {
      final newItems = refresh
          ? response.data!.items
          : [...state.items, ...response.data!.items];
      
      state = state.copyWith(
        isLoading: false,
        items: newItems,
        total: response.data!.total,
        offset: newItems.length,
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
    if (state.items.length >= state.total || state.isLoading) {
      return;
    }
    await loadHistory();
  }

  Future<void> refresh() async {
    await loadHistory(refresh: true);
  }

  Future<void> filterByType(String type) async {
    await loadHistory(type: type, refresh: true);
  }

  Future<bool> deleteItem(String id) async {
    final response = await _historyApiService.deleteHistoryItem(id);

    if (response.success) {
      state = state.copyWith(
        items: state.items.where((item) => item.id != id).toList(),
        total: state.total - 1,
      );
      return true;
    } else {
      state = state.copyWith(
        error: response.error ?? 'Failed to delete item',
      );
      return false;
    }
  }

  Future<HistoryItem?> getItem(String id) async {
    final response = await _historyApiService.getHistoryItem(id);

    if (response.success && response.data != null) {
      return response.data;
    } else {
      state = state.copyWith(
        error: response.error ?? 'Failed to load item',
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

