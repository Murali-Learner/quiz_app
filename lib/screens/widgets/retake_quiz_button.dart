import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:quiz_app/providers/auth_provider.dart';
import 'package:quiz_app/providers/quiz_provider.dart';

class RetakeQuizButton extends StatelessWidget {
  const RetakeQuizButton({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        final quizProvider = context.read<QuizProvider>();
        final authProvider = context.read<AuthProvider>();
        authProvider.updateQuizData(quizProvider.score);
        quizProvider.resetQuiz();
      },
      child: const Text('Retake Quiz'),
    );
  }
}
