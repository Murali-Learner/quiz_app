import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:quiz_app/providers/quiz_provider.dart';
import 'package:quiz_app/screens/leader_board_screen.dart';
import 'package:quiz_app/screens/widgets/admin_quiz_table.dart';
import 'package:quiz_app/screens/widgets/retake_quiz_button.dart';
import 'package:quiz_app/utils/extensions/context_extension.dart';
import 'package:quiz_app/utils/extensions/spacer_extension.dart';

class AdminPage extends StatefulWidget {
  const AdminPage({super.key});

  @override
  AdminPageState createState() => AdminPageState();
}

class AdminPageState extends State<AdminPage> {
  @override
  Widget build(BuildContext context) {
    return Consumer<QuizProvider>(builder: (context, quizProvider, _) {
      log(" quizProvider.isPaused ${quizProvider.quizActive}");
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (quizProvider.isQuizEnded)
            Column(
              children: [
                Text(
                  "Quiz Ended",
                  style: context.textTheme.bodyLarge,
                ),
                10.vSpace,
                Wrap(
                  runAlignment: WrapAlignment.spaceAround,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        context.push(navigateTo: const LeaderBoardPage());
                      },
                      child: const Text("Show LeaderBoards"),
                    ),
                    10.hSpace,
                    const RetakeQuizButton(),
                  ],
                ),
              ],
            ),
          if (!quizProvider.isQuizEnded)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                ElevatedButton(
                  onPressed: () {
                    {
                      quizProvider.toggleQuiz();
                    }
                  },
                  child: Icon(
                    quizProvider.quizActive ? Icons.pause : Icons.play_arrow,
                  ),
                ),
                ElevatedButton(
                  onPressed: quizProvider.btnLoading
                      ? null
                      : () {
                          {
                            quizProvider.nextQuestion();
                          }
                        },
                  child: quizProvider.btnLoading
                      ? const CircularProgressIndicator()
                      : const Text('Next'),
                ),
              ],
            ),
          10.vSpace,
          const AdminQuizTable(),
        ],
      );
    });
  }
}
