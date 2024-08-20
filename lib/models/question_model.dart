class QuestionModel {
  final String id;
  final String question;
  final List<String> options;
  final int correctAnswerIndex;
  final String answeredUser;
  bool hasAnswered;

  QuestionModel({
    required this.question,
    required this.options,
    required this.id,
    required this.answeredUser,
    required this.correctAnswerIndex,
    this.hasAnswered = false,
  });

  factory QuestionModel.fromJson(Map<String, dynamic> json) {
    return QuestionModel(
      id: json['id'] ?? "",
      answeredUser: json['answeredUser'] ?? '',
      question: json['question'] ?? '',
      options: List<String>.from(json['options'] ?? []),
      correctAnswerIndex: json['correctAnswerIndex'] ?? 0,
      hasAnswered: json['hasAnswered'] ?? false,
    );
  }

  QuestionModel copyWith({
    String? id,
    String? question,
    List<String>? options,
    int? correctAnswerIndex,
    bool? hasAnswered,
    String? answeredUser,
  }) {
    return QuestionModel(
      id: id ?? this.id,
      question: question ?? this.question,
      options: options ?? this.options,
      correctAnswerIndex: correctAnswerIndex ?? this.correctAnswerIndex,
      hasAnswered: hasAnswered ?? this.hasAnswered,
      answeredUser: answeredUser ?? this.answeredUser,
    );
  }

  bool isCorrectAnswer(int answerIndex) {
    return answerIndex == correctAnswerIndex;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'question': question,
      'options': options,
      'correctAnswerIndex': correctAnswerIndex,
      'hasAnswered': hasAnswered,
      'answeredUser': answeredUser,
    };
  }
}
