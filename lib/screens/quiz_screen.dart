import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:quiz_app/providers/auth_provider.dart';
import 'package:quiz_app/providers/quiz_provider.dart';
import 'package:quiz_app/screens/leader_ship_screen.dart';
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
    final quizProvider = context.read<QuizProvider>();
    final authProvider = context.read<AuthProvider>();
    // if (authProvider.currentUser != null) {
    //   if (authProvider.currentUser!.isAdmin) {
    //     quizProvider.startQuiz();
    //   }
    // }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quiz App'),
        actions: [
          Consumer2<QuizProvider, AuthProvider>(
              builder: (context, quizProvider, authProvider, _) {
            return quizProvider.isQuizEnded || authProvider.currentUser!.isAdmin
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
          Consumer2<AuthProvider, QuizProvider>(
              builder: (context, authProvider, quizProvider, _) {
            return IconButton(
              tooltip: "Logout",
              onPressed: () {
                quizProvider.resetAllAnswers();
                authProvider.logout();
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
                    isQuizEnded: quizProvider.isLoading,
                    question: quizProvider.currentQuestion,
                    currentUsername: authProvider.currentUser!.name,
                  );
          }
        },
      ),
    );
  }
}
