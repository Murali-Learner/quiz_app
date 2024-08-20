import 'dart:async';
import 'dart:developer';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:quiz_app/models/question_model.dart';
import 'package:quiz_app/models/user_model.dart';

class QuizProvider with ChangeNotifier {
  static final QuizProvider _instance = QuizProvider._internal();

  factory QuizProvider() {
    return _instance;
  }
  QuizProvider._internal() {
    _dbInstance = FirebaseDatabase.instance;
    _questionsRef = _dbInstance.ref('questions');
    _quizVariablesRef = _dbInstance.ref('quiz_variables');
    _usersRef = _dbInstance.ref('users');

    fetchQuestions();
    updateQuizStarted(false);

    // startTimer(); timer controlled by ADMIN only
  }
  late final DatabaseReference _questionsRef;
  late final DatabaseReference _usersRef;
  late final DatabaseReference _quizVariablesRef;
  late final FirebaseDatabase _dbInstance;

  List<QuestionModel> _quizQuestions = [];
  int _selectedIndex = -1;
  int _currentQuestionIndex = 0;
  int _score = 0;
  int _timeLeft = 5;
  bool _quizStarted = false;
  Timer? _timer;
  bool _isQuizEnded = false;
  bool _isLoading = false;
  bool _isPaused = true;

  bool get isPaused => _isPaused;
  bool get isLoading => _isLoading;
  bool get quizStarted => _quizStarted;
  int get currentQuestionIndex => _currentQuestionIndex;
  List<QuestionModel> get quizQuestions => _quizQuestions;
  int get totalQuestions => quizQuestions.length;
  int get score => _score;
  int get timeLeft => _timeLeft;
  bool get isQuizEnded => _isQuizEnded;
  int get selectedIndex => _selectedIndex;
  // QuestionModel get currentQuestion => quizQuestions[_currentQuestionIndex];

  void setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  Future<void> updateQuizStarted(bool started) async {
    try {
      final snapshot = await _quizVariablesRef.child("quizStarted").get();
      final currentValue = snapshot.value as bool?;
      debugPrint("statement $currentValue");
      //  if (currentValue != started) {
      await _quizVariablesRef.child("quizStarted").set(started);
      _quizStarted = started;
      notifyListeners();
      // }
    } catch (e) {
      debugPrint("Error updating quizStarted: $e");
    }
  }

  QuestionModel get currentQuestion {
    return _quizQuestions[_currentQuestionIndex];
  }

  void startQuiz() {
    updateQuizStarted(true);
    startTimer();
  }

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
          nextQuestion();
        }
      },
    );
  }

  void nextQuestion() {
    _timer?.cancel();

    if (_currentQuestionIndex < quizQuestions.length - 1) {
      _currentQuestionIndex++;
      _timeLeft = 6;
      debugPrint("Moving to next question... $_currentQuestionIndex");
      startQuiz();
    } else {
      debugPrint("Quiz ended!");
      _timer?.cancel();
      _isQuizEnded = true;
      _timeLeft = 0;
      debugPrint("Quiz ended!_$_timeLeft");
      notifyListeners();
    }
  }

  void fetchQuestions() {
    setLoading(true);

    _questionsRef.onValue.listen((event) {
      final snapshotsList = event.snapshot.value as List;
      if (snapshotsList.isNotEmpty) {
        _quizQuestions.clear();

        for (var element in snapshotsList) {
          if (element != null) {
            _quizQuestions.add(
                QuestionModel.fromJson(Map<String, dynamic>.from(element))
                    .copyWith(
              hasAnswered: false,
              answeredUser: "",
            ));
          }
        }
      }
      log("_quizQuestions.length ${_quizQuestions.length} ");
      setLoading(false);
      notifyListeners();
    });
  }

  void updateQuestion(QuestionModel updatedQuestion) async {
    try {
      await _questionsRef
          .child(updatedQuestion.id)
          .update(updatedQuestion.toJson());
      int index = _quizQuestions
          .indexWhere((question) => question.id == updatedQuestion.id);
      if (index != -1) {
        _quizQuestions[index] = updatedQuestion;
        notifyListeners();
      }
    } catch (e) {
      debugPrint("Error updating question: $e");
    }
  }

  void resetAllAnswers() async {
    try {
      for (QuestionModel question in _quizQuestions) {
        var updatedQuestion = question.copyWith(
          hasAnswered: false,
          answeredUser: '',
        );
        await _questionsRef.child(question.id).update(updatedQuestion.toJson());
      }

      for (var i = 0; i < _quizQuestions.length; i++) {
        _quizQuestions[i] = _quizQuestions[i].copyWith(
          hasAnswered: false,
          answeredUser: '',
        );
      }
      debugPrint("statement");
      notifyListeners();
    } catch (e) {
      debugPrint("Error resetting answers: $e");
    }
  }

  Stream<List<QuestionModel>> getQuestionsStream() {
    return _questionsRef.onValue.map((event) {
      List<QuestionModel> questions = [];
      final snapshotsList = event.snapshot.value as List;
      if (snapshotsList.isNotEmpty) {
        for (var element in snapshotsList) {
          if (element != null) {
            questions.add(
                QuestionModel.fromJson(Map<String, dynamic>.from(element)));
          }
        }
        //  _quizQuestions.clear();
        // _quizQuestions = questions;
        notifyListeners();
        return questions;
      }
      return [];
    });
  }

  Stream<List<UserModel>> getUsersStream() {
    return _usersRef.onValue.map((event) {
      Map<dynamic, dynamic>? usersMap =
          event.snapshot.value as Map<dynamic, dynamic>?;
      if (usersMap != null) {
        List<UserModel> users = usersMap.entries
            .map((entry) {
              return UserModel.fromJson(Map<String, dynamic>.from(entry.value))
                  .copyWith(uid: entry.key);
            })
            .toList()
            .where((element) => element.isAdmin == false)
            .toList();
        return users;
      }
      return [];
    });
  }

  void toggleQuiz() {
    debugPrint("_isPaused $_quizStarted");
    if (!_quizStarted) {
      // Resume quiz
      _isPaused = false;
      _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
        if (_timeLeft > 0) {
          _timeLeft--;
          updateQuizStarted(true);
          notifyListeners();
        } else {
          nextQuestion();
        }
      });
    } else {
      // Pause quiz
      _isPaused = true;
      updateQuizStarted(false);
      _timer?.cancel();
      notifyListeners();
    }
  }

  void checkAnswer(int selectedIndex, String uid) {
    if (currentQuestion.isCorrectAnswer(selectedIndex)) {
      _score++;
    }
    QuestionModel model =
        currentQuestion.copyWith(hasAnswered: true, answeredUser: uid);

    updateQuestion(model);
    _quizQuestions[_currentQuestionIndex] = model;
    _selectedIndex = selectedIndex;
    _timer?.cancel();
    notifyListeners();
  }

  void resetQuiz() {
    setLoading(true);
    _currentQuestionIndex = 0;
    _score = 0;
    currentQuestion.hasAnswered = false;
    _selectedIndex = -1;
    _isQuizEnded = false;
    resetAllAnswers();
    updateQuizStarted(false);
    _timeLeft = 5;
    setLoading(false);
    notifyListeners();
  }

  void logout() {
    _timer?.cancel();
    _timeLeft = 0;
    _score = 0;
    // if (isAdmin) {
    // _quizQuestions.clear();
    resetAllAnswers();
    // }
    _currentQuestionIndex = 0;
    _isQuizEnded = true;
    updateQuizStarted(false);
    notifyListeners();
  }
}
