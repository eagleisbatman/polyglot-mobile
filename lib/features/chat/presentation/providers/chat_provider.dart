import 'package:polyglot_mobile/core/utils/app_logger.dart';
import 'dart:async';
import 'dart:io';
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
  final String? conversationId;  // Current conversation ID
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
    this.conversationId,
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
    String? conversationId,
    bool clearConversationId = false,
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
      conversationId: clearConversationId ? null : (conversationId ?? this.conversationId),
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
  
  /// Stream of audio amplitude for waveform visualization
  Stream<double>? get amplitudeStream => _audioService.amplitudeStream;

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
    // Start with fresh chat - don't load history into main view
    // History is available through the history screen
    // Keep state empty for a new conversation each time
    AppLogger.d('Starting new chat session (history available in history screen)');
    state = state.copyWith(messages: []);
    return;
    
    // Old code - kept for reference
    /*
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
    */
    
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
  /// Start a new chat session - clears current messages
  void startNewSession() {
    _analytics.trackEvent(AnalyticsEvents.newSessionStarted);
    state = state.copyWith(
      messages: [],
      clearConversationId: true,  // Clear conversationId for new session
      liveUserText: null,
      liveModelText: null,
      error: null,
      isRecording: false,
      isProcessing: false,
      isConnected: false,
      currentlyPlayingId: null,
    );
  }

  /// Load a message from history into the chat
  void loadHistoryMessage(ChatMessage message) {
    state = state.copyWith(
      messages: [message],
      sourceLanguage: message.sourceLanguage,
      targetLanguage: message.targetLanguage,
      liveUserText: null,
      liveModelText: null,
      error: null,
      isRecording: false,
      isProcessing: false,
      currentlyPlayingId: null,
    );
  }

  /// Load a full conversation from history
  void loadConversation({
    required String conversationId,
    required List<ChatMessage> messages,
    required String sourceLanguage,
    required String targetLanguage,
  }) {
    state = state.copyWith(
      messages: messages,
      conversationId: conversationId,
      sourceLanguage: sourceLanguage,
      targetLanguage: targetLanguage,
      liveUserText: null,
      liveModelText: null,
      error: null,
      isRecording: false,
      isProcessing: false,
      currentlyPlayingId: null,
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

    state = state.copyWith(isConnecting: false, error: null);
    _userAudioChunks = []; // Reset audio chunks

    // TODO: Re-enable WebSocket when backend supports it properly
    // For now, go straight to batch recording for reliability
    AppLogger.d('Starting batch recording (WebSocket disabled temporarily)');
    await _startBatchRecording();
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
    AppLogger.i('Starting batch translation for: $audioPath');
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
    AppLogger.d('Message added to state, encoding audio...');

    try {
      final base64Audio = await _audioService.getRecordingAsBase64();
      if (base64Audio == null) {
        AppLogger.e('Failed to encode audio to base64');
        _updateMessage(messageId, (m) => m.copyWith(
          status: MessageStatus.error,
          error: 'Failed to encode audio',
        ));
        state = state.copyWith(isProcessing: false);
        return;
      }
      
      AppLogger.d('Audio encoded, size: ${base64Audio.length} chars. Calling API...');

      final response = await _apiService.translateVoice(
        audioBase64: base64Audio,
        sourceLanguage: state.sourceLanguage,
        targetLanguage: state.targetLanguage,
        conversationId: state.conversationId,
      );
      
      AppLogger.d('API response: success=${response.success}, error=${response.error}');

      if (response.success && response.data != null) {
        AppLogger.d('Translation received, audioUrl: ${response.data!.translationAudioUrl}');
        
        // Store conversationId for future messages in this session
        if (response.data!.conversationId.isNotEmpty) {
          state = state.copyWith(conversationId: response.data!.conversationId);
        }
        
        final updatedMessage = ChatMessage(
          id: messageId,
          type: MessageType.voice,
          status: MessageStatus.complete,
          userContent: response.data!.transcription,
          translatedContent: response.data!.translation,
          // Prefer Cloudinary URL, fallback to local path
          userAudioPath: response.data!.userAudioUrl ?? audioPath,
          translationAudioPath: response.data!.translationAudioUrl, // TTS audio URL
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
    try {
      // If already playing this audio, stop it
      if (state.currentlyPlayingId == '${messageId}_user') {
        await _playerService.stop();
        state = state.copyWith(currentlyPlayingId: null);
        return;
      }
      
      // Stop any currently playing audio first
      if (state.currentlyPlayingId != null) {
        await _playerService.stop();
      }
      
      final message = state.messages.firstWhere(
        (m) => m.id == messageId,
        orElse: () => throw Exception('Message not found'),
      );
      
      AppLogger.d('Playing user audio for message $messageId, path: ${message.userAudioPath}');
      
      if (message.userAudioPath != null) {
        // Check if file exists
        final file = File(message.userAudioPath!);
        if (!await file.exists()) {
          AppLogger.e('Audio file not found: ${message.userAudioPath}');
          state = state.copyWith(error: 'Audio file not found');
          return;
        }
        
        state = state.copyWith(currentlyPlayingId: '${messageId}_user');
        await _playerService.playFile(message.userAudioPath!);
        
        _playerService.onPlayerStateChanged.listen((playerState) {
          if (playerState == PlayerState.completed || playerState == PlayerState.stopped) {
            if (state.currentlyPlayingId == '${messageId}_user') {
              state = state.copyWith(currentlyPlayingId: null);
            }
          }
        });
      } else {
        AppLogger.w('No audio path for message $messageId');
      }
    } catch (e) {
      AppLogger.e('Error playing user audio: $e');
    }
  }

  /// Play translation audio (TTS)
  Future<void> playTranslationAudio(String messageId) async {
    try {
      // If already playing this audio, stop it
      if (state.currentlyPlayingId == '${messageId}_translation') {
        await _playerService.stop();
        state = state.copyWith(currentlyPlayingId: null);
        return;
      }
      
      // Stop any currently playing audio first
      if (state.currentlyPlayingId != null) {
        await _playerService.stop();
      }
      
      final message = state.messages.firstWhere(
        (m) => m.id == messageId,
        orElse: () => throw Exception('Message not found'),
      );
      
      AppLogger.d('Playing translation audio for message $messageId');
      
      if (message.translationAudioPath != null) {
        final audioPath = message.translationAudioPath!;
        final isUrl = audioPath.startsWith('http://') || audioPath.startsWith('https://');
        
        if (isUrl) {
          // Play from URL (Cloudinary)
          AppLogger.d('Playing translation audio from URL: $audioPath');
          state = state.copyWith(currentlyPlayingId: '${messageId}_translation');
          await _playerService.playUrl(audioPath);
          
          _playerService.onPlayerStateChanged.listen((playerState) {
            if (playerState == PlayerState.completed || playerState == PlayerState.stopped) {
              if (state.currentlyPlayingId == '${messageId}_translation') {
                state = state.copyWith(currentlyPlayingId: null);
              }
            }
          });
          return;
        } else {
          // Play from local file
          final file = File(audioPath);
          if (!await file.exists()) {
            AppLogger.e('Translation audio file not found: $audioPath');
            // Fall through to TTS
          } else {
            state = state.copyWith(currentlyPlayingId: '${messageId}_translation');
            await _playerService.playFile(audioPath);
            
            _playerService.onPlayerStateChanged.listen((playerState) {
              if (playerState == PlayerState.completed || playerState == PlayerState.stopped) {
                if (state.currentlyPlayingId == '${messageId}_translation') {
                  state = state.copyWith(currentlyPlayingId: null);
                }
              }
            });
            return;
          }
        }
      }
      
      // If no audio file, try TTS
      if (message.translatedContent != null) {
        AppLogger.d('No audio file, would use TTS for: ${message.translatedContent}');
        // TODO: Implement TTS for translation
        state = state.copyWith(error: 'TTS audio not yet implemented');
      }
    } catch (e) {
      AppLogger.e('Error playing translation audio: $e');
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
