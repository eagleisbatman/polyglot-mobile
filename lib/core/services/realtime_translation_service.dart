import 'package:polyglot_mobile/core/utils/app_logger.dart';
import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Real-time translation service using backend WebSocket proxy
/// Connects to our backend which proxies to Gemini Live API
class RealtimeTranslationService {
  WebSocketChannel? _channel;
  StreamController<RealtimeEvent>? _eventController;
  bool _isConnected = false;
  String? _sessionId;
  String _sourceLanguage = 'en';
  String _targetLanguage = 'hi';

  /// Stream of real-time events (transcriptions, audio, status)
  Stream<RealtimeEvent>? get events => _eventController?.stream;

  bool get isConnected => _isConnected;
  String? get sessionId => _sessionId;

  /// Connect to backend WebSocket for real-time translation
  /// Optionally pass an auth token for authenticated connections
  Future<bool> connect({
    required String sourceLanguage,
    required String targetLanguage,
    String? authToken,
  }) async {
    _sourceLanguage = sourceLanguage;
    _targetLanguage = targetLanguage;

    try {
      _eventController = StreamController<RealtimeEvent>.broadcast();
      
      // Get backend URL from environment
      final apiBaseUrl = dotenv.env['API_BASE_URL'] ?? 'http://localhost:3000';
      
      // Convert HTTP URL to WebSocket URL
      final wsUrl = apiBaseUrl
          .replaceFirst('https://', 'wss://')
          .replaceFirst('http://', 'ws://');
      
      // Add auth token as query parameter if provided
      var fullWsUrl = Uri.parse('$wsUrl/api/v1/realtime');
      if (authToken != null && authToken.isNotEmpty) {
        fullWsUrl = fullWsUrl.replace(
          queryParameters: {'token': authToken},
        );
      }

      AppLogger.d('Connecting to WebSocket: $fullWsUrl');
      _channel = WebSocketChannel.connect(fullWsUrl);
      
      // Wait for the connection to be ready with a timeout
      final completer = Completer<bool>();
      Timer? timeoutTimer;
      
      // Set a 2 second timeout for connection (fail fast)
      timeoutTimer = Timer(const Duration(seconds: 2), () {
        if (!completer.isCompleted) {
          AppLogger.w('WebSocket connection timeout');
          completer.complete(false);
        }
      });
      
      // Listen to responses
      _channel!.stream.listen(
        (message) {
          // First message means connection is established
          if (!completer.isCompleted) {
            timeoutTimer?.cancel();
            _isConnected = true;
            _eventController?.add(RealtimeEvent.connected());
            completer.complete(true);
          }
          _handleMessage(message);
        },
        onError: (error) {
          AppLogger.e('WebSocket error: $error');
          _eventController?.add(RealtimeEvent.error(error.toString()));
          _isConnected = false;
          if (!completer.isCompleted) {
            timeoutTimer?.cancel();
            completer.complete(false);
          }
        },
        onDone: () {
          AppLogger.d('WebSocket connection closed');
          _eventController?.add(RealtimeEvent.disconnected());
          _isConnected = false;
          if (!completer.isCompleted) {
            timeoutTimer?.cancel();
            completer.complete(false);
          }
        },
      );

      // Wait for connection result
      final connected = await completer.future;
      
      if (!connected) {
        await _channel?.sink.close();
        _channel = null;
      }
      
      return connected;
    } catch (e) {
      AppLogger.e('WebSocket connect error: $e');
      _eventController?.add(RealtimeEvent.error(e.toString()));
      return false;
    }
  }

  void _handleMessage(dynamic message) {
    try {
      final data = jsonDecode(message as String) as Map<String, dynamic>;
      final type = data['type'] as String?;

      switch (type) {
        case 'session_id':
          _sessionId = data['sessionId'] as String?;
          // Send setup message with language configuration
          _sendSetup();
          break;
          
        case 'ready':
          _eventController?.add(RealtimeEvent.ready());
          break;
          
        case 'user_transcription':
          final text = data['text'] as String?;
          if (text != null && text.isNotEmpty) {
            _eventController?.add(RealtimeEvent.userTranscription(text));
          }
          break;
          
        case 'model_transcription':
          final text = data['text'] as String?;
          if (text != null && text.isNotEmpty) {
            _eventController?.add(RealtimeEvent.modelTranscription(text));
          }
          break;
          
        case 'audio':
          final audioData = data['data'] as String?;
          if (audioData != null) {
            final audioBytes = base64Decode(audioData);
            _eventController?.add(RealtimeEvent.audioOutput(audioBytes));
          }
          break;
          
        case 'turn_complete':
          _eventController?.add(RealtimeEvent.turnComplete());
          break;
          
        case 'session_saved':
          final interactionId = data['interactionId'] as String?;
          if (interactionId != null) {
            _eventController?.add(RealtimeEvent.sessionSaved(interactionId));
          }
          break;
          
        case 'error':
          final errorMessage = data['message'] as String? ?? 'Unknown error';
          _eventController?.add(RealtimeEvent.error(errorMessage));
          break;
          
        case 'gemini_disconnected':
          _eventController?.add(RealtimeEvent.error('Translation service disconnected'));
          break;
      }
    } catch (e) {
      AppLogger.d('Error parsing message: $e');
    }
  }

  void _sendSetup() {
    if (_channel == null) return;
    
    final setupMessage = {
      'type': 'setup',
      'sourceLanguage': _sourceLanguage,
      'targetLanguage': _targetLanguage,
    };
    
    _channel!.sink.add(jsonEncode(setupMessage));
  }

  /// Send audio chunk for real-time processing
  void sendAudioChunk(Uint8List audioData) {
    if (!_isConnected || _channel == null) return;

    final message = {
      'type': 'audio',
      'data': base64Encode(audioData),
    };

    _channel!.sink.add(jsonEncode(message));
  }

  /// End the current session
  void endSession() {
    if (_channel == null) return;
    
    final message = {'type': 'end'};
    _channel!.sink.add(jsonEncode(message));
  }

  /// Disconnect from the service
  Future<void> disconnect() async {
    endSession();
    _isConnected = false;
    await _channel?.sink.close();
    _channel = null;
    await _eventController?.close();
    _eventController = null;
    _sessionId = null;
  }
}

/// Events emitted by the real-time translation service
sealed class RealtimeEvent {
  const RealtimeEvent();

  factory RealtimeEvent.connected() = RealtimeConnectedEvent;
  factory RealtimeEvent.ready() = RealtimeReadyEvent;
  factory RealtimeEvent.disconnected() = RealtimeDisconnectedEvent;
  factory RealtimeEvent.error(String message) = RealtimeErrorEvent;
  factory RealtimeEvent.userTranscription(String text) = UserTranscriptionEvent;
  factory RealtimeEvent.modelTranscription(String text) = ModelTranscriptionEvent;
  factory RealtimeEvent.audioOutput(Uint8List data) = AudioOutputEvent;
  factory RealtimeEvent.turnComplete() = TurnCompleteEvent;
  factory RealtimeEvent.sessionSaved(String interactionId) = SessionSavedEvent;
}

class RealtimeConnectedEvent extends RealtimeEvent {
  const RealtimeConnectedEvent();
}

class RealtimeReadyEvent extends RealtimeEvent {
  const RealtimeReadyEvent();
}

class RealtimeDisconnectedEvent extends RealtimeEvent {
  const RealtimeDisconnectedEvent();
}

class RealtimeErrorEvent extends RealtimeEvent {
  final String message;
  const RealtimeErrorEvent(this.message);
}

class UserTranscriptionEvent extends RealtimeEvent {
  final String text;
  const UserTranscriptionEvent(this.text);
}

class ModelTranscriptionEvent extends RealtimeEvent {
  final String text;
  const ModelTranscriptionEvent(this.text);
}

class AudioOutputEvent extends RealtimeEvent {
  final Uint8List data;
  const AudioOutputEvent(this.data);
}

class TurnCompleteEvent extends RealtimeEvent {
  const TurnCompleteEvent();
}

class SessionSavedEvent extends RealtimeEvent {
  final String interactionId;
  const SessionSavedEvent(this.interactionId);
}
