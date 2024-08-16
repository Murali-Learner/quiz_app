import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:quiz_app/providers/auth_provider.dart';
import 'package:quiz_app/providers/quiz_provider.dart';
import 'package:quiz_app/screens/quiz_screen.dart';
import 'package:quiz_app/screens/signin_screen.dart';

class AppScreen extends StatelessWidget {
  const AppScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer2<AuthProvider, QuizProvider>(
          builder: (context, authProvider, quizProvider, _) {
        if (authProvider.isLoading) {
          return const Center(child: CircularProgressIndicator.adaptive());
        } else if (authProvider.currentUser == null) {
          return const SignInScreen();
        } else {
          return const QuizScreen();
        }
      }),
    );
  }
}
