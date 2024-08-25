import 'package:flutter/material.dart';
import 'package:quiz_app/models/question_model.dart';
import 'package:quiz_app/screens/widgets/question_widget.dart';
import 'package:quiz_app/screens/widgets/result_widget.dart';
import 'package:quiz_app/utils/extensions/context_extension.dart';
import 'package:quiz_app/utils/extensions/naming_extension.dart';
import 'package:quiz_app/utils/extensions/spacer_extension.dart';

class QuizWidget extends StatelessWidget {
  const QuizWidget({
    super.key,
    required this.quizEnded,
    required this.question,
    required this.currentUsername,
    required this.isAdmin,
  });
  final QuestionModel question;
  final bool quizEnded;
  final String currentUsername;
  final bool isAdmin;

  @override
  Widget build(BuildContext context) {
    // debugPrint("(isQuizEnded && isAdmin) ${quizEnded} ${isAdmin}");
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                "Hey ${currentUsername.toPascalCase()}",
                style: context.textTheme.headlineLarge!.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
              20.vSpace,
              (quizEnded && !isAdmin)
                  ? const ResultWidget()
                  : const QuestionWidget()
            ],
          ),
        ),
      ),
    );
  }
}
