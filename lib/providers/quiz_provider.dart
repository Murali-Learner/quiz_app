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
    resetQuiz();
    fetchQuestions();
  }

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
  bool _quizEnded = false;
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
  bool get quizEnded => _quizEnded;
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
        _quizzesRef.child('quizEnded').onValue.listen((event) {
      _quizEnded = event.snapshot.value as bool;
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

  Future<void> updateQuizEnded(bool ended) async {
    try {
      await _quizzesRef.child("quizEnded").set(ended);
      _quizEnded = ended;
      notifyListeners();
    } catch (e) {
      debugPrint("Error updating quizEnded: $e");
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
    updateQuizEnded(false);
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

  Future<void> checkAnswer(int selectedIndex, String uid) async {
    if (!_quizActive) {
      ToastUtils.showErrorToast("Timer isn't running");
      return;
    }

    log("Checking answer...");
    if (currentQuestion.isCorrectAnswer(selectedIndex)) {
      _score++;
    }

    // Update question state
    final updatedQuestion = currentQuestion.copyWith(
      hasAnswered: true,
      answeredUser: uid,
    );

    _selectedIndex = selectedIndex;
    await updateQuestion(updatedQuestion);

    notifyListeners();

    // Delay before moving to the next question to give time for the user to see feedback
    await Future.delayed(const Duration(seconds: 1));

    // Proceed to the next question
    await nextQuestion();
  }

  Future<void> nextQuestion() async {
    log("Proceeding to next question...");
    setBtnLoading(true);

    try {
      _timer?.cancel(); // Cancel existing timer
      _selectedIndex = -1;

      if (_currentQuestionIndex < _quizQuestions.length - 1) {
        _currentQuestionIndex++;
        _timeLeft = Constants.questionDuration;

        await _quizzesRef.child("currentQuestion").set(_currentQuestionIndex);
        await _quizzesRef.child("timerDuration").set(_timeLeft);
        await updateQuizActive(true);

        startTimer(); // Start timer for the next question
      } else {
        endQuiz();
      }
    } catch (e) {
      log("Error in nextQuestion: $e");
    } finally {
      setBtnLoading(false); // Ensure the button loading state is reset
    }
  }

  Future<void> endQuiz() async {
    _timer?.cancel();

    _timeLeft = 0;
    updateQuizEnded(true);
    updateQuizActive(false);
    notifyListeners();
    await _quizzesRef.child("timerDuration").set(0);
  }

  void toggleQuiz() async {
    if (!_quizActive) {
      _isPaused = false;
      startTimer();
      await updateQuizActive(true);
    } else {
      _isPaused = true;
      _timer?.cancel();
      _timer = null;
      notifyListeners();
      await updateQuizActive(false);
    }
    notifyListeners();
  }

  void fetchQuestions() {
    setLoading(true);

    _questionsRef.onValue.listen((event) {
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
          }
        }
      }
      log("_quizQuestions.length ${_quizQuestions.length}");
      setLoading(false);
      notifyListeners();
    });
  }

  Future<void> updateQuestion(QuestionModel updatedQuestion) async {
    log("I'm here to update the question");
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
    log("question is updated");
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

      for (var i = 0; i < _quizQuestions.length; i++) {
        questions[i] = questions[i].copyWith(
          hasAnswered: false,
          answeredUser: '',
        );
      }

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
    _quizEnded = false;
    _timer?.cancel();
    _timeLeft = Constants.questionDuration;

    try {
      await _quizzesRef.update({
        'quizActive': false,
        'quizEnded': false,
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
        for (var element in snapshotsList) {
          if (element != null) {
            questions.add(
                QuestionModel.fromJson(Map<String, dynamic>.from(element)));
          }
        }
      }
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
