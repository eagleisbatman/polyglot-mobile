class VisionTranslationResponse {
  final String interactionId;
  final String translatedText;
  final String confidence;
  final String detectedLanguage;

  VisionTranslationResponse({
    required this.interactionId,
    required this.translatedText,
    required this.confidence,
    required this.detectedLanguage,
  });

  factory VisionTranslationResponse.fromJson(Map<String, dynamic> json) {
    return VisionTranslationResponse(
      interactionId: json['interactionId'] as String,
      translatedText: json['translatedText'] as String,
      confidence: json['confidence'] as String,
      detectedLanguage: json['detectedLanguage'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'interactionId': interactionId,
      'translatedText': translatedText,
      'confidence': confidence,
      'detectedLanguage': detectedLanguage,
    };
  }
}

