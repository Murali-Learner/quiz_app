import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:quiz_app/providers/auth_provider.dart';
import 'package:quiz_app/providers/quiz_provider.dart';
import 'package:quiz_app/screens/leader_board_screen.dart';
import 'package:quiz_app/screens/signin_screen.dart';
import 'package:quiz_app/screens/widgets/quiz_widget.dart';
import 'package:quiz_app/utils/extensions/context_extension.dart';
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
    init();
  }

  init() async {
    await Future.delayed(Duration.zero).whenComplete(() {
      {
        final quizProvider = context.read<QuizProvider>();
        quizProvider.updateQuizActive(false);
        quizProvider.streamSubscriptions();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quiz App'),
        actions: [
          Consumer2<QuizProvider, AuthProvider>(
              builder: (context, quizProvider, authProvider, _) {
            return quizProvider.isQuizEnded &&
                    !authProvider.currentUser!.isAdmin
                ? IconButton(
                    tooltip: "Leaderboard",
                    onPressed: () {
                      quizProvider.resetQuiz();
                      context.push(navigateTo: const LeaderBoardPage());
                    },
                    icon: const Icon(Icons.leaderboard_outlined),
                  )
                : const SizedBox.shrink();
          }),
          10.hSpace,
          Consumer2<AuthProvider, QuizProvider>(
              builder: (context, authProvider, quizProvider, _) {
            return IconButton(
              tooltip: "Logout",
              onPressed: () {
                quizProvider.resetQuiz();
                authProvider.logout();
                quizProvider.dispose();
                context.pushReplacement(navigateTo: const SignInScreen());
              },
              icon: const Icon(Icons.logout),
            );
          }),
          10.hSpace,
        ],
      ),
      body: Consumer2<AuthProvider, QuizProvider>(
        builder: (context, authProvider, quizProvider, child) {
          if (quizProvider.isLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else {
            return quizProvider.quizQuestions.isEmpty
                ? const SizedBox.shrink()
                : QuizWidget(
                    isAdmin: authProvider.isAdmin,
                    isQuizEnded: quizProvider.isQuizEnded,
                    question: quizProvider.currentQuestion,
                    currentUsername: authProvider.currentUser == null
                        ? ""
                        : authProvider.currentUser!.name,
                  );
          }
        },
      ),
    );
  }
}
