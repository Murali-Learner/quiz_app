import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:quiz_app/providers/quiz_provider.dart';
import 'package:quiz_app/screens/widgets/admin_quiz_table.dart';
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
      log(" quizProvider.isPaused ${quizProvider.isPaused}");
      return Column(
        children: [
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
                  quizProvider.isPaused ? Icons.play_arrow : Icons.pause,
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  {
                    quizProvider.nextQuestion();
                  }
                },
                child: const Text('Next'),
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
