// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:quiz_app/screens/quiz_screen.dart';
import 'package:quiz_app/screens/widgets/enter_quiz_button.dart';
import 'package:quiz_app/screens/widgets/global_text_filed.dart';
import 'package:quiz_app/utils/constants.dart';
import 'package:quiz_app/utils/extensions/context_extension.dart';
import 'package:quiz_app/utils/extensions/spacer_extension.dart';
import 'package:quiz_app/utils/toast_utils.dart';

import '../providers/auth_provider.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  SignInScreenState createState() => SignInScreenState();
}

class SignInScreenState extends State<SignInScreen> {
  final _nameController = TextEditingController();
  final _adminController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Sign In'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: authProvider.isLoading
            ? const Center(child: CircularProgressIndicator())
            : Column(
                children: [
                  if (!authProvider.isAdmin)
                    GlobalTextFormField(
                      controller: _nameController,
                    ),
                  if (authProvider.isAdmin)
                    GlobalTextFormField(
                      controller: _adminController,
                      isAdminLogin: true,
                    ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      EnterQuizButton(
                        nameController: _nameController,
                      ),
                      10.hSpace,
                      ElevatedButton(
                        onPressed: () async {
                          authProvider.toggleAdmin(true);
                          if (_adminController.text.isEmpty) {
                            ToastUtils.showErrorToast("Enter admin name");
                            return;
                          }
                          if (_adminController.text == Constants.admin) {
                            await authProvider.signInAnonymously(
                              _adminController.text,
                              isAdminLogin: true,
                            );
                            context.pushReplacement(
                                navigateTo: const QuizScreen());
                          } else {
                            ToastUtils.showErrorToast("Invalid admin name");
                          }
                        },
                        child: const Text('Admin Login'),
                      ),
                    ],
                  ),
                ],
              ),
      ),
    );
  }
}
