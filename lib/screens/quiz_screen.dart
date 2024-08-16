import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:quiz_app/providers/auth_provider.dart';
import 'package:quiz_app/providers/quiz_provider.dart';
import 'package:quiz_app/screens/leader_ship_screen.dart';
import 'package:quiz_app/screens/signin_screen.dart';
import 'package:quiz_app/screens/widgets/quiz_option_list_tile.dart';
import 'package:quiz_app/screens/widgets/result_widget.dart';
import 'package:quiz_app/utils/extensions/context_extension.dart';
import 'package:quiz_app/utils/extensions/naming_extension.dart';
import 'package:quiz_app/utils/extensions/spacer_extension.dart';

class QuizScreen extends StatefulWidget {
  const QuizScreen({super.key});

  @override
  QuizScreenState createState() => QuizScreenState();
}

class QuizScreenState extends State<QuizScreen> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quiz App'),
        actions: [
          Consumer<QuizProvider>(builder: (context, quizProvider, _) {
            return quizProvider.isQuizEnded
                ? IconButton(
                    tooltip: "Leaderboard",
                    onPressed: () {
                      quizProvider.logout();
                      context.push(navigateTo: const LeadershipPage());
                    },
                    icon: const Icon(Icons.leaderboard_outlined),
                  )
                : const SizedBox.shrink();
          }),
          10.hSpace,
          IconButton(
            tooltip: "Logout",
            onPressed: () {
              final authProvider = context.read<AuthProvider>();
              final quizProvider = context.read<QuizProvider>();
              authProvider.logout();
              quizProvider.logout();
              context.pushReplacement(navigateTo: const SignInScreen());
            },
            icon: const Icon(Icons.logout),
          ),
          10.hSpace,
        ],
      ),
      body: Consumer2<QuizProvider, AuthProvider>(
        builder: (context, quizProvider, authProvider, child) {
          final question = quizProvider.currentQuestion;

          return Center(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    "Hey ${authProvider.currentUser!.name.toPascalCase()}",
                    style: context.textTheme.headlineLarge!.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  20.vSpace,
                  quizProvider.isQuizEnded
                      ? const ResultWidget()
                      : Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text(
                                    'Time Left: ${quizProvider.timeLeft} seconds'),
                                Text(
                                    "Question: ${quizProvider.currentQuestionIndex + 1}/${quizProvider.totalQuestions}"),
                              ],
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                question.question,
                                style: context.textTheme.headlineMedium,
                              ),
                            ),
                            ...List.generate(
                              question.options.length,
                              (index) {
                                return QuizOptionTile(
                                  option: question.options[index],
                                  isSelected:
                                      quizProvider.selectedIndex == index,
                                  onTap: question.hasAnswered
                                      ? null
                                      : () {
                                          quizProvider.checkAnswer(index);
                                        },
                                );
                              },
                            ),
                            Row(
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
                                if (question.hasAnswered)
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
                          ],
                        ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
