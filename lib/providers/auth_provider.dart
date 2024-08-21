import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

import '../models/user_model.dart';

class AuthProvider with ChangeNotifier {
  static final AuthProvider _instance = AuthProvider._internal();

  factory AuthProvider() => _instance;

  AuthProvider._internal() {
    _auth = FirebaseAuth.instance;
    _databaseRef =
        FirebaseDatabase.instance.ref("quizzes/quiz1/participatedUsers/");
    _listenAuthChanges();
  }

  late final FirebaseAuth _auth;
  late final DatabaseReference _databaseRef;

  bool _isLoading = false;
  UserModel? _currentUser;
  bool _isAdmin = false;

  bool get isLoading => _isLoading;
  bool get isAdmin => _isAdmin;
  UserModel? get currentUser => _currentUser;

  void toggleAdmin(bool value) {
    _isAdmin = value;
    notifyListeners();
  }

  void _listenAuthChanges() {
    _auth.authStateChanges().listen((user) {
      if (user != null) {
        _onAuthStateChanged(user);
      } else {
        _onAuthStateChanged(null);
      }
    });
  }

  Future<void> signInAnonymously(String userName,
      {bool isAdminLogin = false}) async {
    _setLoading(true);
    try {
      UserModel? userModel = await _getUserByName(userName);
      if (userModel == null) {
        UserCredential userCredential = await _auth.signInAnonymously();
        User? user = userCredential.user;
        if (user != null) {
          final now = DateTime.now();
          _currentUser = UserModel(
            uid: user.uid,
            name: userName,
            isAdmin: isAdminLogin,
            createdAt: now,
            lastQuizTime: now,
            highestScore: 0,
          );
          await _saveUserToDatabase(_currentUser!);
        }
      } else {
        if (userModel.isAdmin) {
          _isAdmin = true;
          notifyListeners();
        } else {
          _isAdmin = false;
          notifyListeners();
        }
        _currentUser = userModel;
        notifyListeners();
      }
      notifyListeners();
    } catch (e) {
      debugPrint('Failed to sign in anonymously: $e');
    } finally {
      _setLoading(false);
    }
  }

  void updateQuizData(int newScore) async {
    if (_currentUser != null && !isAdmin) {
      final now = DateTime.now();
      _currentUser = _currentUser!.copyWith(
        lastQuizTime: now,
        highestScore: newScore > _currentUser!.highestScore
            ? newScore
            : _currentUser!.highestScore,
      );
      await _databaseRef
          .child(_currentUser!.uid)
          .update(_currentUser!.toJson());
      notifyListeners();
    }
  }

  Future<void> logout() async {
    _setLoading(true);
    try {
      await _auth.signOut();
      _currentUser = null;
      _isAdmin = false;
      notifyListeners();
    } catch (e) {
      debugPrint('Failed to log out: $e');
    } finally {
      _setLoading(false);
    }
  }

  Stream<List<UserModel>> getLeaderboardStream() {
    return _databaseRef.orderByChild('highestScore').onValue.map((event) {
      final usersMap = event.snapshot.value as Map<dynamic, dynamic>;
      final usersList = usersMap.entries
          .map((entry) {
            return UserModel.fromJson(
              Map<String, dynamic>.from(entry.value),
            ).copyWith(uid: entry.key);
          })
          .toList()
          .where((user) {
            return user.isAdmin == false;
          })
          .toList();
      debugPrint("usersList.length ${usersList.length}");
      usersList.sort((a, b) {
        if (b.lastQuizTime != a.lastQuizTime) {
          return b.lastQuizTime.compareTo(a.lastQuizTime);
        } else {
          return a.highestScore.compareTo(b.highestScore);
        }
      });

      return usersList;
    });
  }

  void _onAuthStateChanged(User? user) async {
    if (user == null) {
      _currentUser = null;
    } else {
      final userSnapshot = await _databaseRef.child(user.uid).get();
      if (userSnapshot.exists) {
        final data = userSnapshot.value as Map<Object?, Object?>;
        _currentUser = UserModel.fromJson(Map<String, dynamic>.from(data));
      } else {
        _currentUser = null;
      }
    }
    notifyListeners();
  }

  Future<UserModel?> _getUserByName(String name) async {
    try {
      DatabaseEvent event =
          await _databaseRef.orderByChild('name').equalTo(name).once();
      DataSnapshot snapshot = event.snapshot;

      if (snapshot.exists && snapshot.value != null) {
        final userData = Map<dynamic, dynamic>.from(snapshot.value as Map);
        String uid = userData.keys.first;
        return UserModel.fromJson(Map<String, dynamic>.from(userData[uid]));
      } else {
        return null;
      }
    } catch (e) {
      debugPrint('Error fetching user: $e');
      return null;
    }
  }

  Future<void> _saveUserToDatabase(UserModel userModel) async {
    try {
      await _databaseRef.child(userModel.uid).set(userModel.toJson());
    } catch (e) {
      debugPrint('Error saving user to database: $e');
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
