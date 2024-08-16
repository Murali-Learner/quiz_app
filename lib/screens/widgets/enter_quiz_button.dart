// ignore_for_file: use_build_context_synchronously

import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:quiz_app/providers/auth_provider.dart';
import 'package:quiz_app/screens/quiz_screen.dart';
import 'package:quiz_app/utils/extensions/context_extension.dart';
import 'package:quiz_app/utils/toast_utils.dart';

class EnterQuizButton extends StatelessWidget {
  const EnterQuizButton({
    super.key,
    required TextEditingController nameController,
  }) : _nameController = nameController;

  final TextEditingController _nameController;

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(builder: (context, authProvider, _) {
      return ElevatedButton(
        onPressed: () async {
          authProvider.toggleAdmin(false);
          if (_nameController.text.isEmpty) {
            ToastUtils.showErrorToast("Enter your name");
            return;
          }
          {
            try {
              bool userExists =
                  await authProvider.signInAnonymously(_nameController.text);
              log("user exists $userExists");
              if (userExists) {
                ToastUtils.showErrorToast('username already exists');
              } else if (authProvider.currentUser != null) {
                context.pushReplacement(navigateTo: const QuizScreen());
              } else {
                ToastUtils.showErrorToast("Something went wrong");
              }
            } catch (e) {
              // debugPrint("error $e");
              // ToastUtils.showErrorToast("An error occurred: $e");
            }
          }
        },
        child: const Text('Start Quizzing'),
      );
    });
  }
}
