class FollowUpQuestion {
  final String questionText;
  final String questionId;
  final String category;
  final int priority;

  FollowUpQuestion({
    required this.questionText,
    required this.questionId,
    required this.category,
    required this.priority,
  });

  factory FollowUpQuestion.fromJson(Map<String, dynamic> json) {
    return FollowUpQuestion(
      questionText: json['questionText'] as String,
      questionId: json['questionId'] as String,
      category: json['category'] as String,
      priority: json['priority'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'questionText': questionText,
      'questionId': questionId,
      'category': category,
      'priority': priority,
    };
  }
}

