import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/services/audio_service.dart';
import '../../../../core/services/voice_api_service.dart';
import '../../../../core/analytics/analytics_service.dart';
import '../../../../core/analytics/analytics_events.dart';
import '../../../../core/analytics/analytics_provider.dart';
import '../../domain/entities/chat_message.dart';

final audioServiceProvider = Provider<AudioService>((ref) => AudioService());

final voiceApiProvider = Provider<VoiceApiService>((ref) => VoiceApiService());

class ChatState {
  final List<ChatMessage> messages;
  final String sourceLanguage;
  final String targetLanguage;
  final bool isRecording;
  final bool isProcessing;
  final Duration recordingDuration;
  final String? error;

  const ChatState({
    this.messages = const [],
    this.sourceLanguage = 'en',
    this.targetLanguage = 'hi',
    this.isRecording = false,
    this.isProcessing = false,
    this.recordingDuration = Duration.zero,
    this.error,
  });

  ChatState copyWith({
    List<ChatMessage>? messages,
    String? sourceLanguage,
    String? targetLanguage,
    bool? isRecording,
    bool? isProcessing,
    Duration? recordingDuration,
    String? error,
  }) {
    return ChatState(
      messages: messages ?? this.messages,
      sourceLanguage: sourceLanguage ?? this.sourceLanguage,
      targetLanguage: targetLanguage ?? this.targetLanguage,
      isRecording: isRecording ?? this.isRecording,
      isProcessing: isProcessing ?? this.isProcessing,
      recordingDuration: recordingDuration ?? this.recordingDuration,
      error: error,
    );
  }
}

class ChatNotifier extends StateNotifier<ChatState> {
  final AudioService _audioService;
  final VoiceApiService _apiService;
  final AnalyticsService _analytics;
  Timer? _recordingTimer;

  ChatNotifier(this._audioService, this._apiService, this._analytics)
      : super(const ChatState());

  void setSourceLanguage(String lang) {
    _analytics.trackEvent(
      AnalyticsEvents.voiceLanguageChanged,
      properties: {'language': lang, 'type': 'source'},
    );
    state = state.copyWith(sourceLanguage: lang);
  }

  void setTargetLanguage(String lang) {
    _analytics.trackEvent(
      AnalyticsEvents.voiceLanguageChanged,
      properties: {'language': lang, 'type': 'target'},
    );
    state = state.copyWith(targetLanguage: lang);
  }

  void swapLanguages() {
    final temp = state.sourceLanguage;
    state = state.copyWith(
      sourceLanguage: state.targetLanguage,
      targetLanguage: temp,
    );
    _analytics.trackEvent(AnalyticsEvents.voiceLanguageSwapped);
  }

  Future<void> startRecording() async {
    _analytics.trackEvent(
      AnalyticsEvents.voiceRecordingStarted,
      properties: {
        AnalyticsProperties.sourceLanguage: state.sourceLanguage,
        AnalyticsProperties.targetLanguage: state.targetLanguage,
      },
    );

    final started = await _audioService.startRecording();
    if (started) {
      state = state.copyWith(
        isRecording: true,
        recordingDuration: Duration.zero,
        error: null,
      );
      _startRecordingTimer();
    } else {
      state = state.copyWith(error: 'Failed to start recording');
    }
  }

  void _startRecordingTimer() {
    _recordingTimer?.cancel();
    _recordingTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      state = state.copyWith(
        recordingDuration: state.recordingDuration + const Duration(seconds: 1),
      );
    });
  }

  Future<void> stopRecording() async {
    _recordingTimer?.cancel();
    _analytics.trackEvent(AnalyticsEvents.voiceRecordingStopped);

    final audioPath = await _audioService.stopRecording();
    if (audioPath != null) {
      state = state.copyWith(isRecording: false, isProcessing: true);
      await _translateAudio(audioPath);
    } else {
      state = state.copyWith(
        isRecording: false,
        error: 'Failed to stop recording',
      );
    }
  }

  void cancelRecording() {
    _recordingTimer?.cancel();
    _audioService.stopRecording();
    state = state.copyWith(
      isRecording: false,
      recordingDuration: Duration.zero,
    );
  }

  Future<void> _translateAudio(String audioPath) async {
    final messageId = DateTime.now().millisecondsSinceEpoch.toString();
    
    // Add placeholder message
    final newMessage = ChatMessage(
      id: messageId,
      type: MessageType.voice,
      status: MessageStatus.sending,
      sourceLanguage: state.sourceLanguage,
      targetLanguage: state.targetLanguage,
      timestamp: DateTime.now(),
    );
    
    state = state.copyWith(
      messages: [...state.messages, newMessage],
    );

    try {
      final base64Audio = await _audioService.getRecordingAsBase64();
      if (base64Audio == null) {
        _updateMessage(messageId, (m) => m.copyWith(
          status: MessageStatus.error,
          error: 'Failed to encode audio',
        ));
        state = state.copyWith(isProcessing: false);
        return;
      }

      final response = await _apiService.translateVoice(
        audioBase64: base64Audio,
        sourceLanguage: state.sourceLanguage,
        targetLanguage: state.targetLanguage,
      );

      if (response.success && response.data != null) {
        _updateMessage(messageId, (m) => m.copyWith(
          status: MessageStatus.complete,
          userContent: response.data!.transcription,
          translatedContent: response.data!.translation,
        ));
        
        _analytics.trackEvent(
          AnalyticsEvents.voiceTranslationCompleted,
          properties: {
            AnalyticsProperties.sourceLanguage: state.sourceLanguage,
            AnalyticsProperties.targetLanguage: state.targetLanguage,
          },
        );
      } else {
        _updateMessage(messageId, (m) => m.copyWith(
          status: MessageStatus.error,
          error: response.error ?? 'Translation failed',
        ));
      }
    } catch (e) {
      _updateMessage(messageId, (m) => m.copyWith(
        status: MessageStatus.error,
        error: e.toString(),
      ));
    }

    state = state.copyWith(isProcessing: false);
  }

  void _updateMessage(String id, ChatMessage Function(ChatMessage) update) {
    final messages = state.messages.map((m) {
      if (m.id == id) return update(m);
      return m;
    }).toList();
    state = state.copyWith(messages: messages);
  }

  Future<void> addImageMessage(String imagePath) async {
    // TODO: Implement vision translation
    final messageId = DateTime.now().millisecondsSinceEpoch.toString();
    final message = ChatMessage(
      id: messageId,
      type: MessageType.vision,
      status: MessageStatus.sending,
      imageUrl: imagePath,
      sourceLanguage: state.sourceLanguage,
      targetLanguage: state.targetLanguage,
      timestamp: DateTime.now(),
    );
    state = state.copyWith(messages: [...state.messages, message]);
    
    // Simulated response for now
    await Future.delayed(const Duration(seconds: 2));
    _updateMessage(messageId, (m) => m.copyWith(
      status: MessageStatus.complete,
      userContent: 'Image captured',
      translatedContent: 'Vision translation coming soon...',
    ));
  }

  Future<void> addDocumentMessage(String documentPath, String documentName) async {
    // TODO: Implement document translation
    final messageId = DateTime.now().millisecondsSinceEpoch.toString();
    final message = ChatMessage(
      id: messageId,
      type: MessageType.document,
      status: MessageStatus.sending,
      documentName: documentName,
      sourceLanguage: state.sourceLanguage,
      targetLanguage: state.targetLanguage,
      timestamp: DateTime.now(),
    );
    state = state.copyWith(messages: [...state.messages, message]);
    
    // Simulated response for now
    await Future.delayed(const Duration(seconds: 2));
    _updateMessage(messageId, (m) => m.copyWith(
      status: MessageStatus.complete,
      userContent: 'Document: $documentName',
      translatedContent: 'Document translation coming soon...',
    ));
  }

  @override
  void dispose() {
    _recordingTimer?.cancel();
    super.dispose();
  }
}

final chatProvider = StateNotifierProvider<ChatNotifier, ChatState>((ref) {
  return ChatNotifier(
    ref.read(audioServiceProvider),
    ref.read(voiceApiProvider),
    ref.read(analyticsServiceProvider),
  );
});

