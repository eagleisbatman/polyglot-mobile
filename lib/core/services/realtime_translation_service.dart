import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Real-time translation service using Gemini Live API
/// Handles bidirectional audio streaming for live translation
class RealtimeTranslationService {
  WebSocketChannel? _channel;
  StreamController<RealtimeEvent>? _eventController;
  bool _isConnected = false;
  String _sourceLanguage = 'en';
  String _targetLanguage = 'hi';

  /// Stream of real-time events (transcriptions, audio, status)
  Stream<RealtimeEvent>? get events => _eventController?.stream;

  bool get isConnected => _isConnected;

  /// Connect to Gemini Live API for real-time translation
  Future<bool> connect({
    required String sourceLanguage,
    required String targetLanguage,
  }) async {
    _sourceLanguage = sourceLanguage;
    _targetLanguage = targetLanguage;

    try {
      _eventController = StreamController<RealtimeEvent>.broadcast();
      
      final apiKey = dotenv.env['GEMINI_API_KEY'];
      if (apiKey == null || apiKey.isEmpty) {
        _eventController?.add(RealtimeEvent.error('GEMINI_API_KEY not configured'));
        return false;
      }

      // Gemini Live API WebSocket endpoint
      final wsUrl = Uri.parse(
        'wss://generativelanguage.googleapis.com/ws/google.ai.generativelanguage.v1beta.GenerativeService.BidiGenerateContent?key=$apiKey'
      );

      _channel = WebSocketChannel.connect(wsUrl);
      
      // Send initial setup message
      final setupMessage = _createSetupMessage();
      _channel!.sink.add(jsonEncode(setupMessage));

      // Listen to responses
      _channel!.stream.listen(
        _handleMessage,
        onError: (error) {
          _eventController?.add(RealtimeEvent.error(error.toString()));
          _isConnected = false;
        },
        onDone: () {
          _eventController?.add(RealtimeEvent.disconnected());
          _isConnected = false;
        },
      );

      _isConnected = true;
      _eventController?.add(RealtimeEvent.connected());
      return true;
    } catch (e) {
      _eventController?.add(RealtimeEvent.error(e.toString()));
      return false;
    }
  }

  Map<String, dynamic> _createSetupMessage() {
    return {
      'setup': {
        'model': 'models/gemini-2.0-flash-exp',
        'generation_config': {
          'response_modalities': ['AUDIO', 'TEXT'],
          'speech_config': {
            'voice_config': {
              'prebuilt_voice_config': {
                'voice_name': 'Kore'
              }
            }
          }
        },
        'system_instruction': {
          'parts': [{
            'text': '''You are an expert real-time interpreter.
LANGUAGE PAIR: $_sourceLanguage → $_targetLanguage

RULES:
1. Listen to audio input in $_sourceLanguage
2. Translate EVERYTHING to $_targetLanguage immediately
3. Speak the translation out loud in $_targetLanguage
4. Transcribe both the original speech and your translation
5. Be natural and conversational in your translations
6. If the speaker pauses, complete the current thought before translating
7. Maintain the speaker's tone and intent

DO NOT add commentary. JUST translate.'''
          }]
        },
        'tools': [],
      }
    };
  }

  void _handleMessage(dynamic message) {
    try {
      final data = jsonDecode(message as String) as Map<String, dynamic>;
      
      // Handle setup complete
      if (data.containsKey('setupComplete')) {
        _eventController?.add(RealtimeEvent.ready());
        return;
      }

      // Handle server content
      final serverContent = data['serverContent'] as Map<String, dynamic>?;
      if (serverContent != null) {
        // Input transcription (user's speech)
        final inputTranscription = serverContent['inputTranscription'] as Map<String, dynamic>?;
        if (inputTranscription != null) {
          final text = inputTranscription['text'] as String?;
          if (text != null && text.isNotEmpty) {
            _eventController?.add(RealtimeEvent.userTranscription(text));
          }
        }

        // Output transcription (model's translation text)
        final outputTranscription = serverContent['outputTranscription'] as Map<String, dynamic>?;
        if (outputTranscription != null) {
          final text = outputTranscription['text'] as String?;
          if (text != null && text.isNotEmpty) {
            _eventController?.add(RealtimeEvent.modelTranscription(text));
          }
        }

        // Model audio output
        final modelTurn = serverContent['modelTurn'] as Map<String, dynamic>?;
        if (modelTurn != null) {
          final parts = modelTurn['parts'] as List<dynamic>?;
          if (parts != null && parts.isNotEmpty) {
            final inlineData = parts[0]['inlineData'] as Map<String, dynamic>?;
            if (inlineData != null) {
              final audioData = inlineData['data'] as String?;
              if (audioData != null) {
                final audioBytes = base64Decode(audioData);
                _eventController?.add(RealtimeEvent.audioOutput(audioBytes));
              }
            }
          }
        }

        // Turn complete
        final turnComplete = serverContent['turnComplete'] as bool?;
        if (turnComplete == true) {
          _eventController?.add(RealtimeEvent.turnComplete());
        }
      }
    } catch (e) {
      print('Error parsing message: $e');
    }
  }

  /// Send audio chunk for real-time processing
  void sendAudioChunk(Uint8List audioData) {
    if (!_isConnected || _channel == null) return;

    final message = {
      'realtimeInput': {
        'mediaChunks': [{
          'mimeType': 'audio/pcm;rate=16000',
          'data': base64Encode(audioData),
        }]
      }
    };

    _channel!.sink.add(jsonEncode(message));
  }

  /// Disconnect from the service
  Future<void> disconnect() async {
    _isConnected = false;
    await _channel?.sink.close();
    _channel = null;
    await _eventController?.close();
    _eventController = null;
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

