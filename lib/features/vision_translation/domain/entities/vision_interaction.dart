import '../../../../shared/models/vision_translation_response.dart';

class VisionInteraction {
  final String interactionId;
  final String translatedText;
  final String imagePath;
  final String targetLanguage;
  final DateTime timestamp;

  VisionInteraction({
    required this.interactionId,
    required this.translatedText,
    required this.imagePath,
    required this.targetLanguage,
    required this.timestamp,
  });

  factory VisionInteraction.fromResponse(
    VisionTranslationResponse response,
    String imagePath,
    String targetLanguage,
  ) {
    return VisionInteraction(
      interactionId: response.interactionId,
      translatedText: response.translatedText,
      imagePath: imagePath,
      targetLanguage: targetLanguage,
      timestamp: DateTime.now(),
    );
  }
}

