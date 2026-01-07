import 'package:polyglot_mobile/core/utils/app_logger.dart';
import 'dart:async';
import 'dart:typed_data';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:audioplayers/audioplayers.dart';
import '../../../../core/services/audio_service.dart';
import '../../../../core/services/audio_player_service.dart';
import '../../../../core/services/realtime_translation_service.dart';
import '../../../../core/services/history_storage_service.dart';
import '../../../../core/services/history_sync_service.dart';
import '../../../../core/services/voice_api_service.dart';
import '../../../../core/analytics/analytics_service.dart';
import '../../../../core/analytics/analytics_events.dart';
import '../../../../core/analytics/analytics_provider.dart';
import '../../domain/entities/chat_message.dart';

// Service providers
final audioServiceProvider = Provider<AudioService>((ref) => AudioService());
final audioPlayerProvider = Provider<AudioPlayerService>((ref) => AudioPlayerService());
final realtimeServiceProvider = Provider<RealtimeTranslationService>((ref) => RealtimeTranslationService());
final historyStorageProvider = Provider<HistoryStorageService>((ref) => HistoryStorageService());
final historySyncProvider = Provider<HistorySyncService>((ref) => HistorySyncService());
final voiceApiProvider = Provider<VoiceApiService>((ref) => VoiceApiService());

class ChatState {
  final List<ChatMessage> messages;
  final String sourceLanguage;
  final String targetLanguage;
  final bool isRecording;
  final bool isProcessing;
  final bool isConnected;        // Real-time connection status
  final bool isConnecting;       // Connecting to real-time service
  final Duration recordingDuration;
  final String? liveUserText;    // Current live transcription from user
  final String? liveModelText;   // Current live transcription from model
  final String? error;
  final String? currentlyPlayingId;  // ID of message being played

  const ChatState({
    this.messages = const [],
    this.sourceLanguage = 'en',
    this.targetLanguage = 'hi',
    this.isRecording = false,
    this.isProcessing = false,
    this.isConnected = false,
    this.isConnecting = false,
    this.recordingDuration = Duration.zero,
    this.liveUserText,
    this.liveModelText,
    this.error,
    this.currentlyPlayingId,
  });

  ChatState copyWith({
    List<ChatMessage>? messages,
    String? sourceLanguage,
    String? targetLanguage,
    bool? isRecording,
    bool? isProcessing,
    bool? isConnected,
    bool? isConnecting,
    Duration? recordingDuration,
    String? liveUserText,
    String? liveModelText,
    String? error,
    String? currentlyPlayingId,
  }) {
    return ChatState(
      messages: messages ?? this.messages,
      sourceLanguage: sourceLanguage ?? this.sourceLanguage,
      targetLanguage: targetLanguage ?? this.targetLanguage,
      isRecording: isRecording ?? this.isRecording,
      isProcessing: isProcessing ?? this.isProcessing,
      isConnected: isConnected ?? this.isConnected,
      isConnecting: isConnecting ?? this.isConnecting,
      recordingDuration: recordingDuration ?? this.recordingDuration,
      liveUserText: liveUserText,
      liveModelText: liveModelText,
      error: error,
      currentlyPlayingId: currentlyPlayingId,
    );
  }
}

class ChatNotifier extends StateNotifier<ChatState> {
  final AudioService _audioService;
  final AudioPlayerService _playerService;
  final RealtimeTranslationService _realtimeService;
  final HistoryStorageService _historyStorage;
  final HistorySyncService _historySync;
  final VoiceApiService _apiService;
  final AnalyticsService _analytics;
  
  Timer? _recordingTimer;
  StreamSubscription<RealtimeEvent>? _realtimeSubscription;
  StreamSubscription<Uint8List>? _audioStreamSubscription;
  String _userTextAccumulator = '';
  String _modelTextAccumulator = '';
  String? _currentMessageId;
  String? _currentInteractionId;
  List<Uint8List> _translationAudioChunks = [];
  List<Uint8List> _userAudioChunks = []; // Store user audio for saving

  ChatNotifier(
    this._audioService,
    this._playerService,
    this._realtimeService,
    this._historyStorage,
    this._historySync,
    this._apiService,
    this._analytics,
  ) : super(const ChatState()) {
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    // Try to fetch from backend first, fall back to local
    try {
      final history = await _historySync.fetchHistory();
      if (history.isNotEmpty) {
        state = state.copyWith(messages: history);
        return;
      }
    } catch (e) {
      AppLogger.d('Failed to fetch from backend: $e');
    }
    
    // Fall back to local storage
    final history = await _historyStorage.getHistory();
    state = state.copyWith(messages: history);
  }
  
  /// Refresh history from backend
  Future<void> refreshHistory() async {
    final history = await _historySync.fetchHistory();
    state = state.copyWith(messages: history);
  }

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

  /// Start a new translation session (clear current conversation)
  void startNewSession() {
    _analytics.trackEvent(AnalyticsEvents.voiceRecordingStarted);
    state = state.copyWith(
      liveUserText: null,
      liveModelText: null,
      error: null,
    );
  }

  /// Start recording with real-time streaming
  Future<void> startRecording() async {
    _analytics.trackEvent(
      AnalyticsEvents.voiceRecordingStarted,
      properties: {
        AnalyticsProperties.sourceLanguage: state.sourceLanguage,
        AnalyticsProperties.targetLanguage: state.targetLanguage,
      },
    );

    state = state.copyWith(isConnecting: true, error: null);
    _userAudioChunks = []; // Reset audio chunks

    // Try real-time WebSocket first, but timeout quickly to fall back to batch
    AppLogger.d('Attempting WebSocket connection for real-time translation...');
    final connected = await _realtimeService.connect(
      sourceLanguage: state.sourceLanguage,
      targetLanguage: state.targetLanguage,
    );

    if (connected) {
      AppLogger.d('WebSocket connected, starting streaming recording');
      _setupRealtimeListeners();
      state = state.copyWith(isConnecting: false, isConnected: true);

      // Start streaming recording for real-time
      final audioStream = await _audioService.startStreamingRecording();
      if (audioStream != null) {
        _currentMessageId = DateTime.now().millisecondsSinceEpoch.toString();
        _userTextAccumulator = '';
        _modelTextAccumulator = '';
        _translationAudioChunks = [];
        
        state = state.copyWith(
          isRecording: true,
          recordingDuration: Duration.zero,
        );
        _startRecordingTimer();
        _startAudioStreaming(audioStream);
      } else {
        // Streaming recording failed, fall back to batch
        AppLogger.w('Streaming recording failed, falling back to batch mode');
        await _realtimeService.disconnect();
        await _startBatchRecording();
      }
    } else {
      // WebSocket not available, use batch recording
      AppLogger.d('WebSocket unavailable, using batch recording');
      await _startBatchRecording();
    }
  }
  
  /// Start batch recording (file-based, for when WebSocket is unavailable)
  Future<void> _startBatchRecording() async {
    state = state.copyWith(isConnecting: false, isConnected: false);
    
    final started = await _audioService.startRecording();
    if (started) {
      _currentMessageId = DateTime.now().millisecondsSinceEpoch.toString();
      _userTextAccumulator = '';
      _modelTextAccumulator = '';
      _translationAudioChunks = [];
      
      state = state.copyWith(
        isRecording: true,
        recordingDuration: Duration.zero,
      );
      _startRecordingTimer();
      AppLogger.d('Batch recording started');
    } else {
      state = state.copyWith(error: 'Failed to start recording');
      AppLogger.e('Failed to start batch recording');
    }
  }

  void _setupRealtimeListeners() {
    _realtimeSubscription?.cancel();
    _realtimeSubscription = _realtimeService.events?.listen((event) {
      switch (event) {
        case UserTranscriptionEvent(:final text):
          _userTextAccumulator += text;
          state = state.copyWith(liveUserText: _userTextAccumulator);
          break;
        case ModelTranscriptionEvent(:final text):
          _modelTextAccumulator += text;
          state = state.copyWith(liveModelText: _modelTextAccumulator);
          break;
        case AudioOutputEvent(:final data):
          _translationAudioChunks.add(data);
          _playerService.queueAudioChunk(data);
          break;
        case SessionSavedEvent(:final interactionId):
          _currentInteractionId = interactionId;
          _uploadAudioFiles(interactionId);
          break;
        case TurnCompleteEvent():
          _finalizeTurn();
          break;
        case RealtimeErrorEvent(:final message):
          state = state.copyWith(error: message);
          break;
        case RealtimeDisconnectedEvent():
          state = state.copyWith(isConnected: false);
          break;
        default:
          break;
      }
    });
  }

  void _finalizeTurn() {
    if (_userTextAccumulator.isEmpty && _modelTextAccumulator.isEmpty) return;

    final messageId = _currentMessageId ?? DateTime.now().millisecondsSinceEpoch.toString();
    
    // Check if message already exists
    final existingIndex = state.messages.indexWhere((m) => m.id == messageId);
    
    final message = ChatMessage(
      id: messageId,
      type: MessageType.voice,
      status: MessageStatus.complete,
      userContent: _userTextAccumulator,
      translatedContent: _modelTextAccumulator,
      sourceLanguage: state.sourceLanguage,
      targetLanguage: state.targetLanguage,
      timestamp: DateTime.now(),
    );

    List<ChatMessage> updatedMessages;
    if (existingIndex >= 0) {
      updatedMessages = [...state.messages];
      updatedMessages[existingIndex] = message;
    } else {
      updatedMessages = [...state.messages, message];
    }

    state = state.copyWith(
      messages: updatedMessages,
      liveUserText: null,
      liveModelText: null,
    );

    // Save to history
    _historyStorage.saveMessage(message);

    // Reset accumulators for next turn
    _userTextAccumulator = '';
    _modelTextAccumulator = '';
    _currentMessageId = DateTime.now().millisecondsSinceEpoch.toString();
  }

  void _startAudioStreaming(Stream<Uint8List> audioStream) {
    _audioStreamSubscription?.cancel();
    _audioStreamSubscription = audioStream.listen(
      (chunk) {
        // Store chunk for later saving
        _userAudioChunks.add(chunk);
        // Send to realtime service for translation
        _realtimeService.sendAudioChunk(chunk);
      },
      onError: (error) {
        AppLogger.d('Audio streaming error: $error');
        state = state.copyWith(error: 'Audio streaming error');
      },
      onDone: () {
        AppLogger.d('Audio streaming completed');
      },
    );
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

    AppLogger.d('Stopping recording. isConnected: ${state.isConnected}');

    final audioPath = await _audioService.stopRecording();
    
    // Disconnect real-time if connected
    if (state.isConnected) {
      AppLogger.d('Finalizing real-time session');
      _finalizeTurn(); // Save any pending transcription
      await _realtimeService.disconnect();
      _realtimeSubscription?.cancel();
      _audioStreamSubscription?.cancel();
      state = state.copyWith(isRecording: false, isConnected: false);
    } else if (audioPath != null && audioPath.isNotEmpty) {
      // Batch translation mode
      AppLogger.d('Processing batch translation: $audioPath');
      state = state.copyWith(isRecording: false, isProcessing: true);
      await _translateAudioBatch(audioPath);
    } else {
      AppLogger.e('No audio path available after recording');
      state = state.copyWith(
        isRecording: false,
        error: 'No audio recorded. Please try again.',
      );
    }
  }

  void cancelRecording() {
    _recordingTimer?.cancel();
    _audioService.stopRecording();
    _realtimeService.disconnect();
    _realtimeSubscription?.cancel();
    state = state.copyWith(
      isRecording: false,
      isConnected: false,
      recordingDuration: Duration.zero,
      liveUserText: null,
      liveModelText: null,
    );
  }

  /// Batch translation fallback (when real-time is unavailable)
  Future<void> _translateAudioBatch(String audioPath) async {
    final messageId = DateTime.now().millisecondsSinceEpoch.toString();
    
    final newMessage = ChatMessage(
      id: messageId,
      type: MessageType.voice,
      status: MessageStatus.sending,
      userAudioPath: audioPath,
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
        final updatedMessage = ChatMessage(
          id: messageId,
          type: MessageType.voice,
          status: MessageStatus.complete,
          userContent: response.data!.transcription,
          translatedContent: response.data!.translation,
          userAudioPath: audioPath,
          sourceLanguage: state.sourceLanguage,
          targetLanguage: state.targetLanguage,
          timestamp: DateTime.now(),
        );
        
        _updateMessage(messageId, (_) => updatedMessage);
        _historyStorage.saveMessage(updatedMessage);
        
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

  /// Play user's recorded audio
  Future<void> playUserAudio(String messageId) async {
    final message = state.messages.firstWhere(
      (m) => m.id == messageId,
      orElse: () => throw Exception('Message not found'),
    );
    
    if (message.userAudioPath != null) {
      state = state.copyWith(currentlyPlayingId: '${messageId}_user');
      await _playerService.playFile(message.userAudioPath!);
      
      _playerService.onPlayerStateChanged.listen((playerState) {
        if (playerState == PlayerState.completed || playerState == PlayerState.stopped) {
          state = state.copyWith(currentlyPlayingId: null);
        }
      });
    }
  }

  /// Play translation audio (TTS)
  Future<void> playTranslationAudio(String messageId) async {
    final message = state.messages.firstWhere(
      (m) => m.id == messageId,
      orElse: () => throw Exception('Message not found'),
    );
    
    if (message.translationAudioPath != null) {
      state = state.copyWith(currentlyPlayingId: '${messageId}_translation');
      await _playerService.playFile(message.translationAudioPath!);
      
      _playerService.onPlayerStateChanged.listen((playerState) {
        if (playerState == PlayerState.completed || playerState == PlayerState.stopped) {
          state = state.copyWith(currentlyPlayingId: null);
        }
      });
    } else if (message.translatedContent != null) {
      // TODO: Generate TTS for the translation text
      state = state.copyWith(error: 'TTS audio not available');
    }
  }

  /// Stop audio playback
  Future<void> stopPlayback() async {
    await _playerService.stop();
    state = state.copyWith(currentlyPlayingId: null);
  }

  /// Delete a message
  Future<void> deleteMessage(String messageId) async {
    await _historyStorage.deleteMessage(messageId);
    final messages = state.messages.where((m) => m.id != messageId).toList();
    state = state.copyWith(messages: messages);
  }

  /// Clear all messages from current session
  void clearCurrentSession() {
    state = state.copyWith(
      liveUserText: null,
      liveModelText: null,
      error: null,
    );
  }

  Future<void> addImageMessage(String imagePath) async {
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
    
    // TODO: Implement actual vision translation
    await Future.delayed(const Duration(seconds: 2));
    final updatedMessage = message.copyWith(
      status: MessageStatus.complete,
      userContent: 'Image captured',
      translatedContent: 'Vision translation coming soon...',
    );
    _updateMessage(messageId, (_) => updatedMessage);
    _historyStorage.saveMessage(updatedMessage);
  }

  Future<void> addDocumentMessage(String documentPath, String documentName) async {
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
    
    // TODO: Implement actual document translation
    await Future.delayed(const Duration(seconds: 2));
    final updatedMessage = message.copyWith(
      status: MessageStatus.complete,
      userContent: 'Document: $documentName',
      translatedContent: 'Document translation coming soon...',
    );
    _updateMessage(messageId, (_) => updatedMessage);
    _historyStorage.saveMessage(updatedMessage);
  }

  /// Upload audio files to backend after session is saved
  Future<void> _uploadAudioFiles(String interactionId) async {
    try {
      // Upload user's audio if available
      final recordingPath = _audioService.currentRecordingPath;
      if (recordingPath != null) {
        await _historySync.uploadAudio(
          filePath: recordingPath,
          interactionId: interactionId,
          type: 'user',
        );
      }
      
      // Refresh history to get updated URLs
      await refreshHistory();
    } catch (e) {
      AppLogger.d('Error uploading audio files: $e');
    }
  }

  @override
  @override
  void dispose() {
    _recordingTimer?.cancel();
    _realtimeSubscription?.cancel();
    _audioStreamSubscription?.cancel();
    _realtimeService.disconnect();
    _playerService.dispose();
    super.dispose();
  }
}

final chatProvider = StateNotifierProvider<ChatNotifier, ChatState>((ref) {
  return ChatNotifier(
    ref.read(audioServiceProvider),
    ref.read(audioPlayerProvider),
    ref.read(realtimeServiceProvider),
    ref.read(historyStorageProvider),
    ref.read(historySyncProvider),
    ref.read(voiceApiProvider),
    ref.read(analyticsServiceProvider),
  );
});
