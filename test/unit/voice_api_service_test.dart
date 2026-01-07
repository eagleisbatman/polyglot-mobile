import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import '../../lib/core/services/voice_api_service.dart';
import '../../lib/core/network/models/api_response.dart';
import '../../lib/shared/models/voice_translation_response.dart';

void main() {
  group('VoiceApiService', () {
    late VoiceApiService service;

    setUp(() {
      service = VoiceApiService();
    });

    test('translateVoice returns mock response when backend not configured', () async {
      final response = await service.translateVoice(
        audioBase64: 'test_audio_base64',
        sourceLanguage: 'en',
        targetLanguage: 'hi',
      );

      expect(response.success, isTrue);
      expect(response.data, isNotNull);
      expect(response.data?.transcription, isNotEmpty);
      expect(response.data?.translation, isNotEmpty);
    });
  });
}

