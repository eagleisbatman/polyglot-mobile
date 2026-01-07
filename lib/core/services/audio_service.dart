import 'package:polyglot_mobile/core/utils/app_logger.dart';
import 'dart:async';
import 'dart:io';
import 'dart:convert';
import 'dart:typed_data';
import 'package:record/record.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:path_provider/path_provider.dart';
import '../constants/app_constants.dart';

/// Audio service with real-time streaming support
class AudioService {
  final AudioRecorder _recorder = AudioRecorder();
  final AudioPlayer _player = AudioPlayer();
  bool _isRecording = false;
  bool _isStreaming = false;
  String? _currentRecordingPath;
  
  // Stream controller for real-time audio chunks
  StreamController<Uint8List>? _audioChunkController;
  StreamSubscription<RecordState>? _recordStateSubscription;
  
  // Amplitude stream for waveform visualization
  StreamController<double>? _amplitudeController;
  Timer? _amplitudeTimer;
  
  /// Stream of audio chunks for real-time processing
  Stream<Uint8List>? get audioChunkStream => _audioChunkController?.stream;
  
  /// Stream of amplitude values (0.0 to 1.0) for waveform visualization
  Stream<double>? get amplitudeStream => _amplitudeController?.stream;

  /// Start recording with real-time streaming
  /// Returns a stream of audio chunks for real-time processing
  Future<Stream<Uint8List>?> startStreamingRecording() async {
    try {
      if (!await _recorder.hasPermission()) {
        return null;
      }

      // Create new stream controller
      _audioChunkController = StreamController<Uint8List>.broadcast();
      
      // Start streaming recording
      final audioStream = await _recorder.startStream(
        const RecordConfig(
          encoder: AudioEncoder.pcm16bits,
          sampleRate: 16000, // Gemini requires 16kHz
          numChannels: 1,    // Mono
        ),
      );

      _isRecording = true;
      _isStreaming = true;

      // Forward audio chunks to our controller
      audioStream.listen(
        (chunk) {
          _audioChunkController?.add(chunk);
        },
        onError: (error) {
          AppLogger.d('Audio stream error: $error');
          _audioChunkController?.addError(error);
        },
        onDone: () {
          AppLogger.d('Audio stream completed');
        },
      );

      return _audioChunkController?.stream;
    } catch (e) {
      AppLogger.d('Failed to start streaming recording: $e');
      return null;
    }
  }

  /// Start recording to file (for batch processing fallback)
  Future<bool> startRecording() async {
    try {
      if (await _recorder.hasPermission()) {
        final directory = await getApplicationDocumentsDirectory();
        _currentRecordingPath = '${directory.path}/recording_${DateTime.now().millisecondsSinceEpoch}.wav';
        
        await _recorder.start(
          const RecordConfig(
            encoder: AudioEncoder.wav,
            sampleRate: AppConstants.audioSampleRate,
            numChannels: AppConstants.audioChannels,
          ),
          path: _currentRecordingPath!,
        );
        _isRecording = true;
        _isStreaming = false;
        
        // Start amplitude monitoring for waveform
        _startAmplitudeMonitoring();
        
        return true;
      }
      return false;
    } catch (e) {
      AppLogger.d('Failed to start recording: $e');
      return false;
    }
  }
  
  /// Start monitoring audio amplitude for waveform visualization
  void _startAmplitudeMonitoring() {
    _amplitudeController = StreamController<double>.broadcast();
    
    // Poll amplitude every 100ms
    _amplitudeTimer = Timer.periodic(const Duration(milliseconds: 100), (_) async {
      if (_isRecording) {
        try {
          final amplitude = await _recorder.getAmplitude();
          // Convert dBFS to 0-1 range (dBFS is typically -160 to 0)
          // -40 dB is quiet, 0 dB is max
          final normalized = ((amplitude.current + 40) / 40).clamp(0.0, 1.0);
          _amplitudeController?.add(normalized);
        } catch (e) {
          // Ignore amplitude errors
        }
      }
    });
  }
  
  /// Stop amplitude monitoring
  void _stopAmplitudeMonitoring() {
    _amplitudeTimer?.cancel();
    _amplitudeTimer = null;
    _amplitudeController?.close();
    _amplitudeController = null;
  }

  /// Stop recording (both streaming and file-based)
  Future<String?> stopRecording() async {
    try {
      // Stop amplitude monitoring
      _stopAmplitudeMonitoring();
      
      if (_isRecording) {
        String? path;
        
        if (_isStreaming) {
          // For streaming, we need to save the audio separately
          // The stream was processed in real-time
          await _recorder.stop();
          _audioChunkController?.close();
          _audioChunkController = null;
        } else {
          // For file-based recording
          path = await _recorder.stop();
        }
        
        _isRecording = false;
        _isStreaming = false;
        return path ?? _currentRecordingPath;
      }
      return null;
    } catch (e) {
      AppLogger.d('Failed to stop recording: $e');
      _isRecording = false;
      _isStreaming = false;
      return null;
    }
  }

  /// Cancel current recording without saving
  Future<void> cancelRecording() async {
    try {
      if (_isRecording) {
        await _recorder.stop();
        _audioChunkController?.close();
        _audioChunkController = null;
        _isRecording = false;
        _isStreaming = false;
        
        // Delete the recording file if it exists
        if (_currentRecordingPath != null) {
          final file = File(_currentRecordingPath!);
          if (await file.exists()) {
            await file.delete();
          }
        }
      }
    } catch (e) {
      AppLogger.d('Failed to cancel recording: $e');
      _isRecording = false;
      _isStreaming = false;
    }
  }

  /// Get the recording as base64 (for batch processing)
  Future<String?> getRecordingAsBase64() async {
    try {
      if (_currentRecordingPath != null) {
        final file = File(_currentRecordingPath!);
        if (await file.exists()) {
          final bytes = await file.readAsBytes();
          return base64Encode(bytes);
        }
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<void> playAudio(String audioPath) async {
    try {
      await _player.play(DeviceFileSource(audioPath));
    } catch (e) {
      // Handle error
    }
  }

  Future<void> stopPlayback() async {
    try {
      await _player.stop();
    } catch (e) {
      // Handle error
    }
  }

  bool get isRecording => _isRecording;
  bool get isStreaming => _isStreaming;
  
  /// Get the path of the current/last recording
  String? get currentRecordingPath => _currentRecordingPath;

  void dispose() {
    _audioChunkController?.close();
    _recordStateSubscription?.cancel();
    _recorder.dispose();
    _player.dispose();
  }
}
