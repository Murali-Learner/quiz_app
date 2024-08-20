import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:quiz_app/firebase_options.dart';
import 'package:quiz_app/models/question_model.dart';
import 'package:quiz_app/providers/auth_provider.dart';
import 'package:quiz_app/providers/quiz_provider.dart';
import 'package:quiz_app/screens/app_screen.dart';
import 'package:quiz_app/utils/constants.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) => QuizProvider(),
        ),
        ChangeNotifierProvider(
          create: (context) => AuthProvider(),
        ),
      ],
      child: MaterialApp(
        title: 'Quiz App',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
        ),
        home: const AppScreen(),
      ),
    );
  }
}

class Push extends StatelessWidget {
  const Push({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ElevatedButton(
            onPressed: () async {
              final databaseRef = FirebaseDatabase.instance.ref();
              try {
                for (QuestionModel question in quizQuestionsQ) {
                  await databaseRef
                      .child('questions/${question.id}')
                      .set(question.toJson());
                }
                debugPrint('All questions stored successfully');
              } catch (e) {
                debugPrint('Failed to store questions: $e');
              }
            },
            child: Text("data")),
      ),
    );
  }
}
