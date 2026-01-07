
/// Represents a message in the unified chat interface
enum MessageType { voice, vision, document, text }
enum MessageStatus { sending, streaming, complete, error }

class ChatMessage {
  final String id;
  final MessageType type;
  final MessageStatus status;
  final String? userContent;           // Original user input (transcription/text)
  final String? translatedContent;     // Translated response
  final String? liveUserText;          // Live streaming user transcription
  final String? liveModelText;         // Live streaming model transcription
  final String? userAudioPath;         // Path to user's recorded audio (for replay)
  final String? translationAudioPath;  // Path to TTS audio (for replay)
  final String? audioUrl;              // For voice messages (legacy)
  final String? imageUrl;              // For vision messages
  final String? documentName;          // For document messages
  final String sourceLanguage;
  final String targetLanguage;
  final DateTime timestamp;
  final String? error;

  const ChatMessage({
    required this.id,
    required this.type,
    required this.status,
    this.userContent,
    this.translatedContent,
    this.liveUserText,
    this.liveModelText,
    this.userAudioPath,
    this.translationAudioPath,
    this.audioUrl,
    this.imageUrl,
    this.documentName,
    required this.sourceLanguage,
    required this.targetLanguage,
    required this.timestamp,
    this.error,
  });

  ChatMessage copyWith({
    String? id,
    MessageType? type,
    MessageStatus? status,
    String? userContent,
    String? translatedContent,
    String? liveUserText,
    String? liveModelText,
    String? userAudioPath,
    String? translationAudioPath,
    String? audioUrl,
    String? imageUrl,
    String? documentName,
    String? sourceLanguage,
    String? targetLanguage,
    DateTime? timestamp,
    String? error,
  }) {
    return ChatMessage(
      id: id ?? this.id,
      type: type ?? this.type,
      status: status ?? this.status,
      userContent: userContent ?? this.userContent,
      translatedContent: translatedContent ?? this.translatedContent,
      liveUserText: liveUserText ?? this.liveUserText,
      liveModelText: liveModelText ?? this.liveModelText,
      userAudioPath: userAudioPath ?? this.userAudioPath,
      translationAudioPath: translationAudioPath ?? this.translationAudioPath,
      audioUrl: audioUrl ?? this.audioUrl,
      imageUrl: imageUrl ?? this.imageUrl,
      documentName: documentName ?? this.documentName,
      sourceLanguage: sourceLanguage ?? this.sourceLanguage,
      targetLanguage: targetLanguage ?? this.targetLanguage,
      timestamp: timestamp ?? this.timestamp,
      error: error,
    );
  }

  /// Convert to JSON for history storage
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.name,
      'status': status.name,
      'userContent': userContent,
      'translatedContent': translatedContent,
      'userAudioPath': userAudioPath,
      'translationAudioPath': translationAudioPath,
      'imageUrl': imageUrl,
      'documentName': documentName,
      'sourceLanguage': sourceLanguage,
      'targetLanguage': targetLanguage,
      'timestamp': timestamp.toIso8601String(),
      'error': error,
    };
  }

  /// Create from JSON for history retrieval
  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      id: json['id'] as String,
      type: MessageType.values.firstWhere((e) => e.name == json['type']),
      status: MessageStatus.values.firstWhere((e) => e.name == json['status']),
      userContent: json['userContent'] as String?,
      translatedContent: json['translatedContent'] as String?,
      userAudioPath: json['userAudioPath'] as String?,
      translationAudioPath: json['translationAudioPath'] as String?,
      imageUrl: json['imageUrl'] as String?,
      documentName: json['documentName'] as String?,
      sourceLanguage: json['sourceLanguage'] as String,
      targetLanguage: json['targetLanguage'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      error: json['error'] as String?,
    );
  }
}

