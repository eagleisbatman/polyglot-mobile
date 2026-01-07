import 'dart:io';
import 'dart:convert';
import 'package:record/record.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:path_provider/path_provider.dart';
import '../constants/app_constants.dart';

class AudioService {
  final AudioRecorder _recorder = AudioRecorder();
  final AudioPlayer _player = AudioPlayer();
  bool _isRecording = false;
  String? _currentRecordingPath;

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
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  Future<String?> stopRecording() async {
    try {
      if (_isRecording) {
        final path = await _recorder.stop();
        _isRecording = false;
        return path;
      }
      return null;
    } catch (e) {
      _isRecording = false;
      return null;
    }
  }

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

  void dispose() {
    _recorder.dispose();
    _player.dispose();
  }
}

