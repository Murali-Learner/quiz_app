import 'package:flutter/material.dart';
import 'package:quiz_app/models/question_model.dart';

class Constants {
  static const admin = "MURALI";
  static final GlobalKey<FormState> formKey = GlobalKey<FormState>();
}

final List<QuestionModel> quizQuestionsQ = [
  QuestionModel(
    answeredUser: '',
    hasAnswered: false,
    id: '1',
    question: 'Which company developed Flutter?',
    options: ['Apple', 'Microsoft', 'Google', 'Facebook'],
    correctAnswerIndex: 2,
  ),
  QuestionModel(
    answeredUser: '',
    hasAnswered: false,
    id: '2',
    question: 'What programming language is used to develop Flutter apps?',
    options: ['Java', 'Kotlin', 'Swift', 'Dart'],
    correctAnswerIndex: 3,
  ),
  QuestionModel(
    answeredUser: '',
    hasAnswered: false,
    id: '3',
    question: 'Which widget is used to create an immutable object in Flutter?',
    options: [
      'StatefulWidget',
      'StatelessWidget',
      'InheritedWidget',
      'Provider'
    ],
    correctAnswerIndex: 1,
  ),
  QuestionModel(
    answeredUser: '',
    hasAnswered: false,
    id: '4',
    question: 'What is the command to create a new Flutter project?',
    options: [
      'flutter new project',
      'flutter create',
      'flutter init',
      'flutter generate'
    ],
    correctAnswerIndex: 1,
  ),
  QuestionModel(
    answeredUser: '',
    hasAnswered: false,
    id: '5',
    question: 'Which widget is used to display a list of items in Flutter?',
    options: ['ListView', 'GridView', 'Column', 'Row'],
    correctAnswerIndex: 0,
  ),
  QuestionModel(
    answeredUser: '',
    hasAnswered: false,
    id: '6',
    question: 'What is the purpose of a StatefulWidget?',
    options: [
      'To create a widget that does not maintain state',
      'To create a widget that can change dynamically',
      'To handle user inputs only',
      'To create a fixed layout'
    ],
    correctAnswerIndex: 1,
  ),
  QuestionModel(
    answeredUser: '',
    hasAnswered: false,
    id: '7',
    question: 'How do you define a constant in Dart?',
    options: ['var x = 10;', 'final x = 10;', 'const x = 10;', 'x = 10;'],
    correctAnswerIndex: 2,
  ),
  QuestionModel(
    answeredUser: '',
    hasAnswered: false,
    id: '8',
    question: 'What method is used to rebuild the UI in Flutter?',
    options: ['setState()', 'rebuild()', 'notifyListeners()', 'updateUI()'],
    correctAnswerIndex: 0,
  ),
  QuestionModel(
    answeredUser: '',
    hasAnswered: false,
    id: '9',
    question: 'Which of the following is true about Dart?',
    options: [
      'Dart is a statically typed language',
      'Dart is a dynamically typed language',
      'Dart does not support asynchronous programming',
      'Dart is not used in Flutter'
    ],
    correctAnswerIndex: 0,
  ),
  QuestionModel(
    answeredUser: '',
    hasAnswered: false,
    id: '10',
    question: 'What is a Scaffold in Flutter?',
    options: [
      'A base structure for a material design layout',
      'A tool to manage Flutter packages',
      'A testing tool in Flutter',
      'A way to handle state in Flutter'
    ],
    correctAnswerIndex: 0,
  ),
];
