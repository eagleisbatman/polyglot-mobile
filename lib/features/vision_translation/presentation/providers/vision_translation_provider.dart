import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/services/vision_api_service.dart';
import '../../../../core/analytics/analytics_service.dart';
import '../../../../core/analytics/analytics_events.dart';
import '../../../../core/analytics/analytics_provider.dart';
import '../../../../shared/models/vision_translation_response.dart';
import '../../domain/entities/vision_interaction.dart';

final visionApiServiceProvider = Provider<VisionApiService>((ref) {
  return VisionApiService();
});

class VisionTranslationState {
  final bool isProcessing;
  final String? error;
  final List<VisionInteraction> interactions;
  final String? selectedImagePath;
  final String targetLanguage;

  VisionTranslationState({
    this.isProcessing = false,
    this.error,
    this.interactions = const [],
    this.selectedImagePath,
    this.targetLanguage = 'en',
  });

  VisionTranslationState copyWith({
    bool? isProcessing,
    String? error,
    List<VisionInteraction>? interactions,
    String? selectedImagePath,
    String? targetLanguage,
  }) {
    return VisionTranslationState(
      isProcessing: isProcessing ?? this.isProcessing,
      error: error,
      interactions: interactions ?? this.interactions,
      selectedImagePath: selectedImagePath ?? this.selectedImagePath,
      targetLanguage: targetLanguage ?? this.targetLanguage,
    );
  }
}

class VisionTranslationNotifier extends StateNotifier<VisionTranslationState> {
  final VisionApiService _apiService;
  final AnalyticsService _analytics;

  VisionTranslationNotifier(this._apiService, this._analytics)
      : super(VisionTranslationState());

  Future<void> translateImage(String imagePath) async {
    _analytics.startTimedEvent(AnalyticsEvents.performanceImageProcessingTime);
    _analytics.trackEvent(
      AnalyticsEvents.visionTranslationRequested,
      properties: {
        AnalyticsProperties.targetLanguage: state.targetLanguage,
      },
    );

    state = state.copyWith(
      selectedImagePath: imagePath,
      isProcessing: true,
      error: null,
    );

    try {
      final response = await _apiService.translateImage(
        imagePath: imagePath,
        targetLanguage: state.targetLanguage,
      );

      _analytics.endTimedEvent(
        AnalyticsEvents.performanceImageProcessingTime,
        properties: {
          AnalyticsProperties.targetLanguage: state.targetLanguage,
        },
      );

      if (response.success && response.data != null) {
        final interaction = VisionInteraction.fromResponse(
          response.data!,
          imagePath,
          state.targetLanguage,
        );
        state = state.copyWith(
          isProcessing: false,
          interactions: [...state.interactions, interaction],
          error: null,
        );

        _analytics.trackEvent(
          AnalyticsEvents.visionTranslationCompleted,
          properties: {
            AnalyticsProperties.targetLanguage: state.targetLanguage,
            AnalyticsProperties.interactionId: response.data!.interactionId,
            'translated_text_length': response.data!.translatedText.length,
            AnalyticsProperties.confidence: response.data!.confidence,
            AnalyticsProperties.detectedLanguage: response.data!.detectedLanguage,
          },
        );

        if (state.interactions.length == 1) {
          _analytics.trackEvent(AnalyticsEvents.conversionFirstVisionTranslation);
        }
      } else {
        state = state.copyWith(
          isProcessing: false,
          error: response.error ?? 'Translation failed',
        );
        _analytics.trackEvent(
          AnalyticsEvents.visionTranslationFailed,
          properties: {
            AnalyticsProperties.errorMessage: response.error ?? 'Translation failed',
            AnalyticsProperties.targetLanguage: state.targetLanguage,
          },
        );
      }
    } catch (e) {
      _analytics.trackError(
        errorType: 'vision_translation',
        errorMessage: e.toString(),
      );
      state = state.copyWith(
        isProcessing: false,
        error: e.toString(),
      );
    }
  }

  void setTargetLanguage(String language) {
    _analytics.trackEvent(
      AnalyticsEvents.visionTargetLanguageChanged,
      properties: {
        AnalyticsProperties.language: language,
      },
    );
    state = state.copyWith(targetLanguage: language);
  }

  void clearImage() {
    _analytics.trackEvent(AnalyticsEvents.visionImageDiscarded);
    state = state.copyWith(selectedImagePath: null);
  }
}

final visionTranslationProvider =
    StateNotifierProvider<VisionTranslationNotifier, VisionTranslationState>((ref) {
  return VisionTranslationNotifier(
    ref.read(visionApiServiceProvider),
    ref.read(analyticsServiceProvider),
  );
});

