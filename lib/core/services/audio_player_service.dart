import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'package:audioplayers/audioplayers.dart';
import 'package:path_provider/path_provider.dart';

/// Service for playing audio files and PCM audio streams
class AudioPlayerService {
  final AudioPlayer _player = AudioPlayer();
  final List<Uint8List> _audioQueue = [];
  bool _isPlaying = false;
  String? _currentFilePath;

  /// Stream of playback state changes
  Stream<PlayerState> get onPlayerStateChanged => _player.onPlayerStateChanged;

  /// Current playback position
  Stream<Duration> get onPositionChanged => _player.onPositionChanged;

  /// Total duration of current audio
  Stream<Duration> get onDurationChanged => _player.onDurationChanged;

  bool get isPlaying => _isPlaying;

  /// Play an audio file from path
  Future<void> playFile(String filePath) async {
    try {
      _currentFilePath = filePath;
      await _player.play(DeviceFileSource(filePath));
      _isPlaying = true;
    } catch (e) {
      print('Error playing file: $e');
      _isPlaying = false;
    }
  }

  /// Play audio from bytes (for TTS playback)
  Future<void> playBytes(Uint8List audioData, {String mimeType = 'audio/wav'}) async {
    try {
      // Save to temp file and play
      final tempDir = await getTemporaryDirectory();
      final tempFile = File('${tempDir.path}/temp_audio_${DateTime.now().millisecondsSinceEpoch}.wav');
      
      // If it's PCM, convert to WAV
      if (mimeType.contains('pcm')) {
        final wavData = _pcmToWav(audioData, sampleRate: 24000);
        await tempFile.writeAsBytes(wavData);
      } else {
        await tempFile.writeAsBytes(audioData);
      }
      
      await _player.play(DeviceFileSource(tempFile.path));
      _isPlaying = true;
    } catch (e) {
      print('Error playing bytes: $e');
      _isPlaying = false;
    }
  }

  /// Queue PCM audio chunk for real-time playback
  void queueAudioChunk(Uint8List pcmData) {
    _audioQueue.add(pcmData);
    _processQueue();
  }

  Future<void> _processQueue() async {
    if (_isPlaying || _audioQueue.isEmpty) return;

    _isPlaying = true;
    while (_audioQueue.isNotEmpty) {
      final chunk = _audioQueue.removeAt(0);
      await playBytes(chunk, mimeType: 'audio/pcm');
      
      // Wait for completion
      await _player.onPlayerComplete.first;
    }
    _isPlaying = false;
  }

  /// Convert PCM to WAV format
  Uint8List _pcmToWav(Uint8List pcmData, {int sampleRate = 24000, int channels = 1, int bitsPerSample = 16}) {
    final byteRate = sampleRate * channels * bitsPerSample ~/ 8;
    final blockAlign = channels * bitsPerSample ~/ 8;
    final dataSize = pcmData.length;
    final fileSize = 36 + dataSize;

    final header = ByteData(44);
    
    // RIFF header
    header.setUint8(0, 0x52); // R
    header.setUint8(1, 0x49); // I
    header.setUint8(2, 0x46); // F
    header.setUint8(3, 0x46); // F
    header.setUint32(4, fileSize, Endian.little);
    header.setUint8(8, 0x57);  // W
    header.setUint8(9, 0x41);  // A
    header.setUint8(10, 0x56); // V
    header.setUint8(11, 0x45); // E

    // fmt chunk
    header.setUint8(12, 0x66); // f
    header.setUint8(13, 0x6D); // m
    header.setUint8(14, 0x74); // t
    header.setUint8(15, 0x20); // (space)
    header.setUint32(16, 16, Endian.little); // Subchunk1Size
    header.setUint16(20, 1, Endian.little);  // AudioFormat (PCM)
    header.setUint16(22, channels, Endian.little);
    header.setUint32(24, sampleRate, Endian.little);
    header.setUint32(28, byteRate, Endian.little);
    header.setUint16(32, blockAlign, Endian.little);
    header.setUint16(34, bitsPerSample, Endian.little);

    // data chunk
    header.setUint8(36, 0x64); // d
    header.setUint8(37, 0x61); // a
    header.setUint8(38, 0x74); // t
    header.setUint8(39, 0x61); // a
    header.setUint32(40, dataSize, Endian.little);

    // Combine header and PCM data
    final wavData = Uint8List(44 + pcmData.length);
    wavData.setAll(0, header.buffer.asUint8List());
    wavData.setAll(44, pcmData);

    return wavData;
  }

  /// Pause playback
  Future<void> pause() async {
    await _player.pause();
    _isPlaying = false;
  }

  /// Resume playback
  Future<void> resume() async {
    await _player.resume();
    _isPlaying = true;
  }

  /// Stop playback
  Future<void> stop() async {
    await _player.stop();
    _isPlaying = false;
    _audioQueue.clear();
  }

  /// Seek to position
  Future<void> seek(Duration position) async {
    await _player.seek(position);
  }

  /// Dispose resources
  Future<void> dispose() async {
    await _player.dispose();
    _audioQueue.clear();
  }
}

