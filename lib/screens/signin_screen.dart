import 'dart:developer';

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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sign In'),
      ),
      body: Consumer<AuthProvider>(
        builder: (context, authProvider, _) {
          return Padding(
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
                              final userName = _adminController.text.trim();

                              if (userName.isEmpty && authProvider.isAdmin) {
                                ToastUtils.showErrorToast("Enter admin name");
                                return;
                              }

                              if (userName == Constants.admin) {
                                await _handleAdminLogin(authProvider, userName);
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
          );
        },
      ),
    );
  }

  Future<void> _handleAdminLogin(
      AuthProvider authProvider, String userName) async {
    try {
      await authProvider.signInAnonymously(userName, isAdminLogin: true);

      if (mounted && authProvider.currentUser != null) {
        log("current user ${authProvider.currentUser}");
        context.pushReplacement(navigateTo: const QuizScreen());
      }
    } catch (e) {
      debugPrint("signin error $e");
      ToastUtils.showErrorToast(e.toString());
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _adminController.dispose();
    super.dispose();
  }
}
