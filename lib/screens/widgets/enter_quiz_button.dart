import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:quiz_app/providers/auth_provider.dart';
import 'package:quiz_app/screens/quiz_screen.dart';
import 'package:quiz_app/utils/constants.dart';
import 'package:quiz_app/utils/extensions/context_extension.dart';
import 'package:quiz_app/utils/toast_utils.dart';

class EnterQuizButton extends StatefulWidget {
  const EnterQuizButton({
    super.key,
    required TextEditingController nameController,
  }) : _nameController = nameController;

  final TextEditingController _nameController;

  @override
  State<EnterQuizButton> createState() => _EnterQuizButtonState();
}

class _EnterQuizButtonState extends State<EnterQuizButton> {
  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(builder: (context, authProvider, _) {
      return ElevatedButton(
        onPressed: () async {
          authProvider.toggleAdmin(false);
          if (widget._nameController.text.isEmpty) {
            ToastUtils.showErrorToast("Enter your name");
            return;
          }
          if (widget._nameController.text.toUpperCase().trim() ==
              Constants.admin) {
            ToastUtils.showErrorToast("Name Already Exists");
            return;
          }
          {
            // try {
            await authProvider
                .signInAnonymously(widget._nameController.text.trim())
                .catchError((error) {
              ToastUtils.showErrorToast("Login Error $error");
            }).whenComplete(() {
              if (!mounted) {
                return;
              } else {
                if (authProvider.currentUser != null) {
                  context.pushReplacement(navigateTo: const QuizScreen());
                } else {
                  ToastUtils.showErrorToast("Something went wrong");
                }
              }
            });

            // }
            //  catch (e) {
            //   debugPrint("error $e");
            //   // ToastUtils.showErrorToast("An error occurred: $e");
            // }
          }
        },
        child: const Text('Start Quizzing'),
      );
    });
  }
}
