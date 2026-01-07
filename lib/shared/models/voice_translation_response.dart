import 'follow_up_question.dart';

class VoiceTranslationResponse {
  final String interactionId;
  final String transcription;
  final String translation;
  final String summary;
  final String? translationAudioUrl; // TTS audio URL from Cloudinary
  final List<FollowUpQuestion> followUpQuestions;
  final String detectedLanguage;
  final String urgency;

  VoiceTranslationResponse({
    required this.interactionId,
    required this.transcription,
    required this.translation,
    required this.summary,
    this.translationAudioUrl,
    required this.followUpQuestions,
    required this.detectedLanguage,
    required this.urgency,
  });

  factory VoiceTranslationResponse.fromJson(Map<String, dynamic> json) {
    return VoiceTranslationResponse(
      interactionId: json['interactionId'] as String,
      transcription: json['transcription'] as String,
      translation: json['translation'] as String,
      summary: json['summary'] as String,
      translationAudioUrl: json['translationAudioUrl'] as String?,
      followUpQuestions: (json['followUpQuestions'] as List<dynamic>?)
              ?.map((e) => FollowUpQuestion.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      detectedLanguage: json['detectedLanguage'] as String? ?? 'en',
      urgency: json['urgency'] as String? ?? 'routine',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'interactionId': interactionId,
      'transcription': transcription,
      'translation': translation,
      'summary': summary,
      'translationAudioUrl': translationAudioUrl,
      'followUpQuestions': followUpQuestions.map((e) => e.toJson()).toList(),
      'detectedLanguage': detectedLanguage,
      'urgency': urgency,
    };
  }
}

