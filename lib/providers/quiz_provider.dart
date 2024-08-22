import 'dart:async';
import 'dart:developer';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:quiz_app/models/question_model.dart';
import 'package:quiz_app/utils/constants.dart';
import 'package:quiz_app/utils/toast_utils.dart';

class QuizProvider with ChangeNotifier {
  static final QuizProvider _instance = QuizProvider._internal();

  factory QuizProvider() {
    return _instance;
  }
  QuizProvider._internal() {
    _dbInstance = FirebaseDatabase.instance;
    _quizzesRef = _dbInstance.ref('quizzes/quiz1/');
    _questionsRef = _dbInstance.ref('quizzes/quiz1/questions/');
    _participatedUsersRef = _dbInstance.ref('quizzes/quiz1/participatedUsers/');
    // storeQuestions();
    fetchQuestions();
  }
  // Future<void> storeQuestions() async {
  //   try {
  //     for (QuestionModel question in quizQuestionsQ) {
  //       await _questionsRef.child(question.id).set(question.toJson());
  //     }
  //     debugPrint('All questions stored successfully');
  //   } catch (e) {
  //     debugPrint('Failed to store questions: $e');
  //   }
  // }

  late StreamSubscription<DatabaseEvent> _timerSubscription;
  late StreamSubscription<DatabaseEvent> _quizActiveSubscription;
  late StreamSubscription<DatabaseEvent> _currentQuestionIndexSubscription;

  late final DatabaseReference _questionsRef;
  late final DatabaseReference _participatedUsersRef;
  late final DatabaseReference _quizzesRef;
  late final FirebaseDatabase _dbInstance;

  Map<String, QuestionModel> _quizQuestions = {};
  int _selectedIndex = -1;
  int _currentQuestionIndex = 0;
  int _score = 0;
  int _timeLeft = Constants.questionDuration;
  bool _quizActive = false;
  Timer? _timer;
  bool _isQuizEnded = false;
  bool _isLoading = false;
  bool _btnLoading = false;
  bool _isPaused = true;

  bool get isPaused => _isPaused;
  bool get isLoading => _isLoading;
  bool get btnLoading => _btnLoading;
  bool get quizActive => _quizActive;
  int get currentQuestionIndex => _currentQuestionIndex;
  Map<String, QuestionModel> get quizQuestions => _quizQuestions;
  int get totalQuestions => quizQuestions.length;
  int get score => _score;
  int get timeLeft => _timeLeft;
  bool get isQuizEnded => _isQuizEnded;
  int get selectedIndex => _selectedIndex;

  void setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void setBtnLoading(bool value) {
    _btnLoading = value;
    notifyListeners();
  }

  void streamSubscriptions() {
    _timerSubscription =
        _quizzesRef.child('timerDuration').onValue.listen((event) {
      _timeLeft = event.snapshot.value as int;
      notifyListeners();
    });

    _quizActiveSubscription =
        _quizzesRef.child('quizActive').onValue.listen((event) {
      _quizActive = event.snapshot.value as bool;
      notifyListeners();
    });

    _currentQuestionIndexSubscription =
        _quizzesRef.child('currentQuestion').onValue.listen((event) {
      _currentQuestionIndex = event.snapshot.value as int;
      notifyListeners();
    });
  }

  Future<void> updateQuizActive(bool active) async {
    try {
      await _quizzesRef.child("quizActive").set(active);
      _quizActive = active;
      notifyListeners();
    } catch (e) {
      debugPrint("Error updating quizActive: $e");
    }
  }

  QuestionModel get currentQuestion {
    return _quizQuestions[_currentQuestionIndex == 0
        ? (_currentQuestionIndex + 1).toString()
        : _currentQuestionIndex.toString()]!;
  }

  void startQuiz() {
    updateQuizActive(true);
    _currentQuestionIndex = 0;
    _timeLeft = Constants.questionDuration;
    _isQuizEnded = false;
    startTimer();
  }

  void startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(
      const Duration(seconds: 1),
      (timer) async {
        if (_timeLeft > 0) {
          _timeLeft--;
          await _quizzesRef.child("timerDuration").set(_timeLeft);
          notifyListeners();
        } else {
          nextQuestion();
        }
      },
    );
  }

  void checkAnswer(int selectedIndex, String uid) {
    if (quizActive) {
      if (currentQuestion.isCorrectAnswer(selectedIndex)) {
        _score++;
      }
      QuestionModel model =
          currentQuestion.copyWith(hasAnswered: true, answeredUser: uid);

      updateQuestion(model);
      _quizQuestions[_currentQuestionIndex.toString()] = model;
      _selectedIndex = selectedIndex;
      nextQuestion();
      notifyListeners();
    } else {
      ToastUtils.showErrorToast("Timer isn't running");
    }
  }

  void nextQuestion() async {
    setBtnLoading(true);
    Future.delayed(const Duration(seconds: Constants.delayDuration))
        .whenComplete(
      () async {
        debugPrint("delayed 2 seconds");
        _timer?.cancel();
        _selectedIndex = -1;

        if (_currentQuestionIndex < _quizQuestions.length - 1) {
          _currentQuestionIndex++;
          _timeLeft = Constants.questionDuration;
          await _quizzesRef.child("currentQuestion").set(_currentQuestionIndex);
          await _quizzesRef.child("timerDuration").set(_timeLeft);
          updateQuizActive(true);
          startTimer();
        } else {
          endQuiz();
        }
      },
    );

    setBtnLoading(false);
  }

  void toggleQuiz() async {
    debugPrint("_isPaused $_quizActive");
    if (!_quizActive) {
      // Resume quiz

      _isPaused = false;
      startTimer();
      await updateQuizActive(true);
    } else {
      // Pause quiz

      _isPaused = true;
      _timer?.cancel();
      _timer = null;

      await updateQuizActive(false);
    }
    notifyListeners();
  }

  void endQuiz() async {
    _timer?.cancel();
    _isQuizEnded = true;
    _timeLeft = 0;
    _quizActive = false;

    await _quizzesRef.child("quizActive").set(false);
    await _quizzesRef.child("timerDuration").set(0);
    notifyListeners();
  }

  void fetchQuestions() {
    setLoading(true);

    _questionsRef.onValue.listen((event) {
      // debugPrint("questions ${event.snapshot.value}");
      final snapshotsList = event.snapshot.value as List;
      if (snapshotsList.isNotEmpty) {
        _quizQuestions.clear();

        for (var element in snapshotsList) {
          if (element != null) {
            _quizQuestions[element["id"].toString()] =
                QuestionModel.fromJson(Map<String, dynamic>.from(element))
                    .copyWith(
              hasAnswered: false,
              answeredUser: "",
            );

            // _quizQuestions.add(
            //     QuestionModel.fromJson(Map<String, dynamic>.from(element))
            //         .copyWith(
            //   hasAnswered: false,
            //   answeredUser: "",
            // ));
          }
        }
      }
      log("_quizQuestions.length ${_quizQuestions.length}");
      setLoading(false);
      notifyListeners();
    });
  }

  void updateQuestion(QuestionModel updatedQuestion) async {
    try {
      await _questionsRef
          .child(updatedQuestion.id)
          .update(updatedQuestion.toJson());
      int index = _quizQuestions.values
          .where((question) => question.id == updatedQuestion.id)
          .toList()
          .indexOf(updatedQuestion);
      if (index != -1) {
        _quizQuestions[index.toString()] = updatedQuestion;
        notifyListeners();
      }
    } catch (e) {
      debugPrint("Error updating question: $e");
    }
  }

  Future<void> resetAllAnswers() async {
    try {
      List<QuestionModel> questions = _quizQuestions.values.toList();

      for (QuestionModel question in questions) {
        var updatedQuestion = question.copyWith(
          hasAnswered: false,
          answeredUser: '',
        );
        await _questionsRef.child(question.id).update(updatedQuestion.toJson());
      }
      debugPrint("db ques reset");
      // _quizQuestions.forEach((id, question) {

      // });
      for (var i = 0; i < _quizQuestions.length; i++) {
        questions[i] = questions[i].copyWith(
          hasAnswered: false,
          answeredUser: '',
        );
      }
      debugPrint("local ques reset");

      notifyListeners();
    } catch (e) {
      debugPrint("Error resetting answers: $e");
    }
  }

  Future<void> resetQuiz() async {
    setLoading(true);

    _currentQuestionIndex = 0;
    _score = 0;
    _quizActive = false;
    _selectedIndex = -1;
    _isQuizEnded = false;
    _timer?.cancel();
    _timeLeft = Constants.questionDuration;

    try {
      await _quizzesRef.update({
        'quizActive': false,
        'timerDuration': Constants.questionDuration,
        'currentQuestion': 0,
      });

      await resetAllAnswers();
      setLoading(false);
      notifyListeners();
    } catch (e) {
      debugPrint("Error resetting quiz: $e");
      setLoading(false);
    }
  }

  Stream<List<QuestionModel>> getQuestionsStream() {
    return _questionsRef.onValue.map((event) {
      List<QuestionModel> questions = [];
      final snapshotsList = event.snapshot.value as List;
      if (snapshotsList.isNotEmpty) {
        // log("question list ${snapshotsList.first}");
        for (var element in snapshotsList) {
          if (element != null) {
            questions.add(
                QuestionModel.fromJson(Map<String, dynamic>.from(element)));
          }
        }
      }
      log("questions.length ${questions.length}");
      return questions;
    });
  }

  @override
  void dispose() {
    super.dispose();
    _timerSubscription.cancel();
    _quizActiveSubscription.cancel();
    _currentQuestionIndexSubscription.cancel();
  }
}
