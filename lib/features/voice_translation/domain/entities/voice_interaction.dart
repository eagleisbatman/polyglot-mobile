import '../../../../shared/models/voice_translation_response.dart';

class VoiceInteraction {
  final String interactionId;
  final String transcription;
  final String translation;
  final String summary;
  final String sourceLanguage;
  final String targetLanguage;
  final DateTime timestamp;

  VoiceInteraction({
    required this.interactionId,
    required this.transcription,
    required this.translation,
    required this.summary,
    required this.sourceLanguage,
    required this.targetLanguage,
    required this.timestamp,
  });

  factory VoiceInteraction.fromResponse(
    VoiceTranslationResponse response,
    String sourceLanguage,
    String targetLanguage,
  ) {
    return VoiceInteraction(
      interactionId: response.interactionId,
      transcription: response.transcription,
      translation: response.translation,
      summary: response.summary,
      sourceLanguage: sourceLanguage,
      targetLanguage: targetLanguage,
      timestamp: DateTime.now(),
    );
  }
}

