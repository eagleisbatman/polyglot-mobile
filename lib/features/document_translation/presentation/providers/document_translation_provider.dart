import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/services/document_api_service.dart';
import '../../../../core/analytics/analytics_service.dart';
import '../../../../core/analytics/analytics_events.dart';
import '../../../../core/analytics/analytics_provider.dart';
import '../../domain/entities/document_interaction.dart';

final documentApiServiceProvider = Provider<DocumentApiService>((ref) {
  return DocumentApiService();
});

class DocumentTranslationState {
  final bool isProcessing;
  final String? error;
  final List<DocumentInteraction> interactions;
  final String? selectedFilePath;
  final String mode; // 'translate' or 'summarize'
  final String targetLanguage;

  DocumentTranslationState({
    this.isProcessing = false,
    this.error,
    this.interactions = const [],
    this.selectedFilePath,
    this.mode = 'translate',
    this.targetLanguage = 'en',
  });

  DocumentTranslationState copyWith({
    bool? isProcessing,
    String? error,
    List<DocumentInteraction>? interactions,
    String? selectedFilePath,
    String? mode,
    String? targetLanguage,
  }) {
    return DocumentTranslationState(
      isProcessing: isProcessing ?? this.isProcessing,
      error: error,
      interactions: interactions ?? this.interactions,
      selectedFilePath: selectedFilePath ?? this.selectedFilePath,
      mode: mode ?? this.mode,
      targetLanguage: targetLanguage ?? this.targetLanguage,
    );
  }
}

class DocumentTranslationNotifier
    extends StateNotifier<DocumentTranslationState> {
  final DocumentApiService _apiService;
  final AnalyticsService _analytics;

  DocumentTranslationNotifier(this._apiService, this._analytics)
      : super(DocumentTranslationState());

  Future<void> processDocument(String filePath) async {
    _analytics.startTimedEvent(AnalyticsEvents.performanceDocumentProcessingTime);
    
    final eventName = state.mode == 'translate'
        ? AnalyticsEvents.documentTranslationRequested
        : AnalyticsEvents.documentSummarizationRequested;
    
    _analytics.trackEvent(
      eventName,
      properties: {
        AnalyticsProperties.targetLanguage: state.targetLanguage,
        AnalyticsProperties.documentMode: state.mode,
      },
    );

    state = state.copyWith(
      selectedFilePath: filePath,
      isProcessing: true,
      error: null,
    );

    try {
      final response = await _apiService.translateDocument(
        filePath: filePath,
        targetLanguage: state.targetLanguage,
        mode: state.mode,
      );

      _analytics.endTimedEvent(
        AnalyticsEvents.performanceDocumentProcessingTime,
        properties: {
          AnalyticsProperties.targetLanguage: state.targetLanguage,
          AnalyticsProperties.documentMode: state.mode,
        },
      );

      if (response.success && response.data != null) {
        final interaction = DocumentInteraction.fromResponse(
          response.data!,
          filePath,
          state.targetLanguage,
        );
        state = state.copyWith(
          isProcessing: false,
          interactions: [...state.interactions, interaction],
          error: null,
        );

        final completionEvent = state.mode == 'translate'
            ? AnalyticsEvents.documentTranslationCompleted
            : AnalyticsEvents.documentSummarizationCompleted;

        _analytics.trackEvent(
          completionEvent,
          properties: {
            AnalyticsProperties.targetLanguage: state.targetLanguage,
            AnalyticsProperties.interactionId: response.data!.interactionId,
            AnalyticsProperties.documentMode: state.mode,
            AnalyticsProperties.wordCount: response.data!.wordCount,
          },
        );

        if (state.interactions.length == 1) {
          _analytics.trackEvent(AnalyticsEvents.conversionFirstDocumentTranslation);
        }
      } else {
        state = state.copyWith(
          isProcessing: false,
          error: response.error ?? 'Processing failed',
        );
        _analytics.trackEvent(
          AnalyticsEvents.documentProcessingFailed,
          properties: {
            AnalyticsProperties.errorMessage: response.error ?? 'Processing failed',
            AnalyticsProperties.targetLanguage: state.targetLanguage,
            AnalyticsProperties.documentMode: state.mode,
          },
        );
      }
    } catch (e) {
      _analytics.trackError(
        errorType: 'document_processing',
        errorMessage: e.toString(),
      );
      state = state.copyWith(
        isProcessing: false,
        error: e.toString(),
      );
    }
  }

  void setMode(String mode) {
    _analytics.trackEvent(
      AnalyticsEvents.documentModeChanged,
      properties: {
        AnalyticsProperties.documentMode: mode,
      },
    );
    state = state.copyWith(mode: mode);
  }

  void setTargetLanguage(String language) {
    _analytics.trackEvent(
      AnalyticsEvents.documentTargetLanguageChanged,
      properties: {
        AnalyticsProperties.language: language,
      },
    );
    state = state.copyWith(targetLanguage: language);
  }

  void clearDocument() {
    _analytics.trackEvent(AnalyticsEvents.documentFileRemoved);
    state = state.copyWith(selectedFilePath: null);
  }
}

final documentTranslationProvider =
    StateNotifierProvider<DocumentTranslationNotifier, DocumentTranslationState>(
        (ref) {
  return DocumentTranslationNotifier(
    ref.read(documentApiServiceProvider),
    ref.read(analyticsServiceProvider),
  );
});

