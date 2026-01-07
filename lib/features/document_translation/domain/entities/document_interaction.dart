import '../../../../shared/models/document_translation_response.dart';

class DocumentInteraction {
  final String interactionId;
  final String result;
  final String mode;
  final String filePath;
  final String targetLanguage;
  final DateTime timestamp;

  DocumentInteraction({
    required this.interactionId,
    required this.result,
    required this.mode,
    required this.filePath,
    required this.targetLanguage,
    required this.timestamp,
  });

  factory DocumentInteraction.fromResponse(
    DocumentTranslationResponse response,
    String filePath,
    String targetLanguage,
  ) {
    return DocumentInteraction(
      interactionId: response.interactionId,
      result: response.result,
      mode: response.mode,
      filePath: filePath,
      targetLanguage: targetLanguage,
      timestamp: DateTime.now(),
    );
  }
}

