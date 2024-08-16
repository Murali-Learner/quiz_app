import 'dart:async';

import 'package:flutter/material.dart';
import 'package:quiz_app/models/question_model.dart';
import 'package:quiz_app/utils/constants.dart';

class QuizProvider with ChangeNotifier {
  static final QuizProvider _instance = QuizProvider._internal();

  factory QuizProvider() {
    return _instance;
  }

  QuizProvider._internal() {
    // startTimer();// timer is handled only by ADMIN only
  }

  int _selectedIndex = -1;
  int _currentQuestionIndex = 0;
  int _score = 0;
  int _timeLeft = 5;
  Timer? _timer;
  bool _isQuizEnded = false;
  bool _isPaused = false;

  bool get isPaused => _isPaused;

  int get currentQuestionIndex => _currentQuestionIndex;
  int get totalQuestions => questions.length;
  int get score => _score;
  int get timeLeft => _timeLeft;
  bool get isQuizEnded => _isQuizEnded;
  int get selectedIndex => _selectedIndex;
  QuestionModel get currentQuestion => questions[_currentQuestionIndex];

  void startTimer() {
    _timer?.cancel();
    _isQuizEnded = false;
    _selectedIndex = -1;
    _timer = Timer.periodic(
      const Duration(seconds: 1),
      (timer) {
        if (_timeLeft > 0) {
          _timeLeft--;
          debugPrint("Time left: $_timeLeft");
          notifyListeners();
        } else {
          debugPrint("Time's up! Moving to next question...");
          _moveToNextQuestion();
        }
      },
    );
  }

  void _moveToNextQuestion() {
    _timer?.cancel();

    if (_currentQuestionIndex < questions.length - 1) {
      _currentQuestionIndex++;
      _timeLeft = 6;
      debugPrint("Moving to next question... $_currentQuestionIndex");
      startTimer();
    } else {
      debugPrint("Quiz ended!");
      _timer?.cancel();
      _isQuizEnded = true;
      _timeLeft = 0;

      debugPrint("Quiz ended!_$_timeLeft");
      notifyListeners();
    }
  }

  void toggleQuiz() {
    if (_isPaused) {
      // Resume quiz
      _isPaused = false;
      _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
        if (_timeLeft > 0) {
          _timeLeft--;
          notifyListeners();
        } else {
          _moveToNextQuestion();
        }
      });
    } else {
      // Pause quiz
      _isPaused = true;
      _timer?.cancel();
      notifyListeners();
    }
  }

  void nextQuestion() {
    _moveToNextQuestion();
  }

  void checkAnswer(int selectedIndex) {
    if (currentQuestion.isCorrectAnswer(selectedIndex)) {
      _score++;
    }
    currentQuestion.hasAnswered = true;
    _selectedIndex = selectedIndex;
    _timer?.cancel();
    notifyListeners();
  }

  void resetQuiz() {
    _currentQuestionIndex = 0;
    _score = 0;
    _isQuizEnded = false;
    for (var question in questions) {
      question.hasAnswered = false;
    }
    _timeLeft = 5;
    notifyListeners();
    // startTimer();
  }

  void logout() {
    _timer?.cancel();
    _timeLeft = 0;
    _score = 0;
    _currentQuestionIndex = 0;
    _isQuizEnded = true;
    notifyListeners();
  }
}
