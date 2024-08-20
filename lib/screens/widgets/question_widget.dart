import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:quiz_app/models/question_model.dart';
import 'package:quiz_app/providers/auth_provider.dart';
import 'package:quiz_app/providers/quiz_provider.dart';
import 'package:quiz_app/screens/admin_page.dart';
import 'package:quiz_app/screens/widgets/quiz_option_list_tile.dart';
import 'package:quiz_app/utils/extensions/context_extension.dart';

class QuestionWidget extends StatelessWidget {
  const QuestionWidget({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer2<QuizProvider, AuthProvider>(
        builder: (context, quizProvider, authProvider, _) {
      final QuestionModel question = quizProvider.currentQuestion;
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          TimeAndQuestionCount(
            quizProvider: quizProvider,
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              question.question,
              style: context.textTheme.headlineMedium,
            ),
          ),
          (authProvider.currentUser != null &&
                  authProvider.currentUser!.isAdmin)
              ? const AdminPage()
              : Column(
                  children: List.generate(
                    question.options.length,
                    (index) {
                      return QuizOptionTile(
                        option: question.options[index],
                        isSelected: quizProvider.selectedIndex == index,
                        onTap: question.hasAnswered
                            ? null
                            : () {
                                quizProvider.checkAnswer(
                                    index, authProvider.currentUser!.uid);
                              },
                      );
                    },
                  ),
                ),
          const Row(
            children: [
              // if (!question.hasAnswered)
              //   ElevatedButton(
              //     onPressed: () {
              //       {
              //         quizProvider.toggleQuiz();
              //         setState(() {});
              //       }
              //     },
              //     child: Icon(
              //       quizProvider.isPaused
              //           ? Icons.play_arrow
              //           : Icons.pause,
              //     ),
              //   ),
              // if (question.hasAnswered)
              //   ElevatedButton(
              //     onPressed: () {
              //       {
              //         quizProvider.nextQuestion();
              //       }
              //     },
              //     child: const Text('Next'),
              //   ),
            ],
          ),
        ],
      );
    });
  }
}

class TimeAndQuestionCount extends StatelessWidget {
  const TimeAndQuestionCount({
    super.key,
    required this.quizProvider,
  });
  final QuizProvider quizProvider;
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text('Time Left: ${quizProvider.timeLeft} seconds'),
        Text(
            "Question: ${quizProvider.currentQuestionIndex + 1}/${quizProvider.quizQuestions.length}"),
      ],
    );
  }
}
