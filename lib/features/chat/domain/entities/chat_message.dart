/// Represents a message in the unified chat interface
enum MessageType { voice, vision, document, text }
enum MessageStatus { sending, streaming, complete, error }

class ChatMessage {
  final String id;
  final MessageType type;
  final MessageStatus status;
  final String? userContent;      // Original user input (transcription/text)
  final String? translatedContent; // Translated response
  final String? audioUrl;          // For voice messages
  final String? imageUrl;          // For vision messages
  final String? documentName;      // For document messages
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
      audioUrl: audioUrl ?? this.audioUrl,
      imageUrl: imageUrl ?? this.imageUrl,
      documentName: documentName ?? this.documentName,
      sourceLanguage: sourceLanguage ?? this.sourceLanguage,
      targetLanguage: targetLanguage ?? this.targetLanguage,
      timestamp: timestamp ?? this.timestamp,
      error: error,
    );
  }
}

