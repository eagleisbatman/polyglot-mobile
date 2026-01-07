import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/services/voice_api_service.dart';
import '../../../../core/services/audio_service.dart';
import '../../../../core/analytics/analytics_service.dart';
import '../../../../core/analytics/analytics_events.dart';
import '../../../../core/analytics/analytics_provider.dart';
import '../../domain/entities/voice_interaction.dart';

final voiceApiServiceProvider = Provider<VoiceApiService>((ref) {
  return VoiceApiService();
});

final audioServiceProvider = Provider<AudioService>((ref) {
  return AudioService();
});

class VoiceTranslationState {
  final bool isRecording;
  final bool isProcessing;
  final String? error;
  final List<VoiceInteraction> interactions;
  final String? currentInteractionId;
  final String sourceLanguage;
  final String targetLanguage;

  VoiceTranslationState({
    this.isRecording = false,
    this.isProcessing = false,
    this.error,
    this.interactions = const [],
    this.currentInteractionId,
    this.sourceLanguage = 'en',
    this.targetLanguage = 'hi',
  });

  VoiceTranslationState copyWith({
    bool? isRecording,
    bool? isProcessing,
    String? error,
    List<VoiceInteraction>? interactions,
    String? currentInteractionId,
    String? sourceLanguage,
    String? targetLanguage,
  }) {
    return VoiceTranslationState(
      isRecording: isRecording ?? this.isRecording,
      isProcessing: isProcessing ?? this.isProcessing,
      error: error,
      interactions: interactions ?? this.interactions,
      currentInteractionId: currentInteractionId ?? this.currentInteractionId,
      sourceLanguage: sourceLanguage ?? this.sourceLanguage,
      targetLanguage: targetLanguage ?? this.targetLanguage,
    );
  }
}

class VoiceTranslationNotifier extends StateNotifier<VoiceTranslationState> {
  final VoiceApiService _apiService;
  final AudioService _audioService;
  final AnalyticsService _analytics;

  VoiceTranslationNotifier(
    this._apiService,
    this._audioService,
    this._analytics,
  ) : super(VoiceTranslationState());

  Future<void> startRecording() async {
    _analytics.trackEvent(
      AnalyticsEvents.voiceRecordingStarted,
      properties: {
        AnalyticsProperties.sourceLanguage: state.sourceLanguage,
        AnalyticsProperties.targetLanguage: state.targetLanguage,
      },
    );
    _analytics.startTimedEvent(AnalyticsEvents.performanceAudioRecordingDuration);

    final started = await _audioService.startRecording();
    if (started) {
      state = state.copyWith(isRecording: true, error: null);
    } else {
      state = state.copyWith(error: 'Failed to start recording');
      _analytics.trackError(
        errorType: 'audio_recording',
        errorMessage: 'Failed to start recording',
      );
    }
  }

  Future<void> stopRecording() async {
    _analytics.endTimedEvent(AnalyticsEvents.performanceAudioRecordingDuration);
    _analytics.trackEvent(AnalyticsEvents.voiceRecordingStopped);

    final audioPath = await _audioService.stopRecording();
    if (audioPath != null) {
      state = state.copyWith(isRecording: false, isProcessing: true);
      await _translateAudio(audioPath);
    } else {
      state = state.copyWith(isRecording: false, error: 'Failed to stop recording');
      _analytics.trackError(
        errorType: 'audio_recording',
        errorMessage: 'Failed to stop recording',
      );
    }
  }

  Future<void> _translateAudio(String audioPath) async {
    _analytics.startTimedEvent(AnalyticsEvents.performanceTranslationLatency);
    _analytics.trackEvent(
      AnalyticsEvents.voiceTranslationRequested,
      properties: {
        AnalyticsProperties.sourceLanguage: state.sourceLanguage,
        AnalyticsProperties.targetLanguage: state.targetLanguage,
        AnalyticsProperties.languagePair: '${state.sourceLanguage}_${state.targetLanguage}',
      },
    );

    try {
      final base64Audio = await _audioService.getRecordingAsBase64();
      if (base64Audio == null) {
        state = state.copyWith(
          isProcessing: false,
          error: 'Failed to encode audio',
        );
        _analytics.trackError(
          errorType: 'audio_encoding',
          errorMessage: 'Failed to encode audio',
        );
        return;
      }

      final response = await _apiService.translateVoice(
        audioBase64: base64Audio,
        sourceLanguage: state.sourceLanguage,
        targetLanguage: state.targetLanguage,
        previousInteractionId: state.currentInteractionId,
      );

      _analytics.endTimedEvent(
        AnalyticsEvents.performanceTranslationLatency,
        properties: {
          AnalyticsProperties.sourceLanguage: state.sourceLanguage,
          AnalyticsProperties.targetLanguage: state.targetLanguage,
        },
      );

      if (response.success && response.data != null) {
        final interaction = VoiceInteraction.fromResponse(
          response.data!,
          state.sourceLanguage,
          state.targetLanguage,
        );
        state = state.copyWith(
          isProcessing: false,
          interactions: [...state.interactions, interaction],
          currentInteractionId: response.data!.interactionId,
          error: null,
        );

        _analytics.trackEvent(
          AnalyticsEvents.voiceTranslationCompleted,
          properties: {
            AnalyticsProperties.sourceLanguage: state.sourceLanguage,
            AnalyticsProperties.targetLanguage: state.targetLanguage,
            AnalyticsProperties.interactionId: response.data!.interactionId,
            AnalyticsProperties.transcriptionLength: response.data!.transcription.length,
            AnalyticsProperties.translationLength: response.data!.translation.length,
            AnalyticsProperties.detectedLanguage: response.data!.detectedLanguage,
            if (response.data!.followUpQuestions.isNotEmpty)
              'follow_up_questions_count': response.data!.followUpQuestions.length,
          },
        );

        // Track first translation conversion
        if (state.interactions.length == 1) {
          _analytics.trackEvent(AnalyticsEvents.conversionFirstVoiceTranslation);
        }
      } else {
        state = state.copyWith(
          isProcessing: false,
          error: response.error ?? 'Translation failed',
        );
        _analytics.trackEvent(
          AnalyticsEvents.voiceTranslationFailed,
          properties: {
            AnalyticsProperties.errorMessage: response.error ?? 'Translation failed',
            AnalyticsProperties.sourceLanguage: state.sourceLanguage,
            AnalyticsProperties.targetLanguage: state.targetLanguage,
          },
        );
      }
    } catch (e) {
      _analytics.trackError(
        errorType: 'translation',
        errorMessage: e.toString(),
      );
      state = state.copyWith(
        isProcessing: false,
        error: e.toString(),
      );
    }
  }

  void setSourceLanguage(String language) {
    _analytics.trackEvent(
      AnalyticsEvents.voiceLanguageChanged,
      properties: {
        AnalyticsProperties.language: language,
        'language_type': 'source',
      },
    );
    state = state.copyWith(sourceLanguage: language);
  }

  void setTargetLanguage(String language) {
    _analytics.trackEvent(
      AnalyticsEvents.voiceLanguageChanged,
      properties: {
        AnalyticsProperties.language: language,
        'language_type': 'target',
      },
    );
    state = state.copyWith(targetLanguage: language);
  }

  void swapLanguages() {
    _analytics.trackEvent(
      AnalyticsEvents.voiceLanguageSwapped,
      properties: {
        AnalyticsProperties.sourceLanguage: state.sourceLanguage,
        AnalyticsProperties.targetLanguage: state.targetLanguage,
      },
    );
    final temp = state.sourceLanguage;
    state = state.copyWith(
      sourceLanguage: state.targetLanguage,
      targetLanguage: temp,
    );
  }
}

final voiceTranslationProvider =
    StateNotifierProvider<VoiceTranslationNotifier, VoiceTranslationState>((ref) {
  return VoiceTranslationNotifier(
    ref.read(voiceApiServiceProvider),
    ref.read(audioServiceProvider),
    ref.read(analyticsServiceProvider),
  );
});

