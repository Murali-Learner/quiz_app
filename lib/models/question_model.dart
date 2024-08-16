class QuestionModel {
  final String question;
  final List<String> options;
  final int correctAnswerIndex;
  bool hasAnswered;

  QuestionModel({
    required this.question,
    required this.options,
    required this.correctAnswerIndex,
    this.hasAnswered = false,
  });

  bool isCorrectAnswer(int answerIndex) {
    return answerIndex == correctAnswerIndex;
  }
}
