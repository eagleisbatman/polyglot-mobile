class DocumentTranslationResponse {
  final String interactionId;
  final String result;
  final String mode;
  final int wordCount;

  DocumentTranslationResponse({
    required this.interactionId,
    required this.result,
    required this.mode,
    required this.wordCount,
  });

  factory DocumentTranslationResponse.fromJson(Map<String, dynamic> json) {
    return DocumentTranslationResponse(
      interactionId: json['interactionId'] as String,
      result: json['result'] as String,
      mode: json['mode'] as String,
      wordCount: json['wordCount'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'interactionId': interactionId,
      'result': result,
      'mode': mode,
      'wordCount': wordCount,
    };
  }
}

