import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

import '../models/user_model.dart';

class AuthProvider with ChangeNotifier {
  late FirebaseAuth _auth;
  late DatabaseReference _database;

  bool _isLoading = false;
  UserModel? _currentUser;
  bool _isAdmin = false;

  bool get isLoading => _isLoading;
  bool get isAdmin => _isAdmin;
  UserModel? get currentUser => _currentUser;

  AuthProvider() {
    authChanges();
  }

  void toggleAdmin(bool value) {
    _isAdmin = value;
    notifyListeners();
  }

  void authChanges() {
    _auth = FirebaseAuth.instance;
    _database = FirebaseDatabase.instance.ref();

    _auth.authStateChanges().listen((user) {
      if (user != null) {
        debugPrint("User ID: ${user.uid}");
        _onAuthStateChanged(user);
      } else {
        debugPrint("User is null");
        _onAuthStateChanged(null);
      }
    });
  }

  Stream<List<UserModel>> getLeaderboardStream() {
    return _database
        .child('users')
        .orderByChild('highestScore')
        .onValue
        .map((event) {
      final usersMap = event.snapshot.value as Map<dynamic, dynamic>;
      final usersList = usersMap.entries.map((entry) {
        return UserModel.fromJson(
          Map<String, dynamic>.from(entry.value),
        ).copyWith(uid: entry.key);
      }).toList();

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

  Future<bool> signInAnonymously(String userName,
      {bool isAdminLogin = false}) async {
    _setLoading(true);
    try {
      UserModel? userModel = await getUserByName(userName);
      if (userModel == null) {
        UserCredential userCredential = await _auth.signInAnonymously();
        User? user = userCredential.user;
        DatabaseReference usersRef = _database.child('users');

        if (user != null) {
          final now = DateTime.now();
          _currentUser = UserModel(
            isAdmin: false,
            uid: user.uid,
            name: userName,
            createdAt: now,
            lastQuizTime: now,
            highestScore: 0,
          );

          debugPrint("_current user ${_currentUser!.toJson()}");
          notifyListeners();
          // Save new user to the database
          await usersRef.child(_currentUser!.uid).set(_currentUser!.toJson());
        }

        return false;
      } else {
        if (isAdminLogin) {
          _currentUser = userModel;
          notifyListeners();
        } else {
          _currentUser = null;
          notifyListeners();
        }
        return true;
      }
    } catch (e) {
      debugPrint('Failed to sign in anonymously: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<UserModel?> getUserByName(String name) async {
    try {
      DatabaseReference usersRef = _database.child('users');
      DatabaseEvent event =
          await usersRef.orderByChild('name').equalTo(name).once();

      DataSnapshot snapshot = event.snapshot;

      if (snapshot.exists && snapshot.value != null) {
        final Map<dynamic, dynamic> userData =
            snapshot.value as Map<dynamic, dynamic>;

        String uid = userData.keys.first;

        final Map<String, dynamic> userMap =
            Map<String, dynamic>.from(userData);

        final jsonData = Map<String, dynamic>.from(userMap[uid] as Map);

        final userModel = UserModel(
          uid: uid,
          name: jsonData["name"],
          createdAt: DateTime.parse(jsonData["createdAt"]),
          lastQuizTime: DateTime.parse(jsonData["lastQuizTime"]),
          highestScore: jsonData["highestScore"],
          isAdmin: jsonData["isAdmin"] ?? false,

          // scoreList: List<int>.from((jsonData["scoreList"] ?? []) as List),
        );
        return userModel;
      } else {
        debugPrint("user not found");
        return null;
      }
    } catch (e) {
      debugPrint("user not found $e");
      return null;
    }
  }

  void updateQuizData(int newScore) async {
    debugPrint("newScore $newScore");
    if (_currentUser != null) {
      final now = DateTime.now();
      _currentUser = _currentUser!.copyWith(
        lastQuizTime: now,
        // scoreList: List.from(_currentUser!.scoreList)..add(newScore),
        highestScore: newScore > _currentUser!.highestScore
            ? newScore
            : _currentUser!.highestScore,
      );
      debugPrint("_currentUser ${_currentUser!.toJson()}");
      await _database
          .child('users/${_currentUser!.uid}')
          .update(_currentUser!.toJson());

      notifyListeners();
    }
  }

  void _onAuthStateChanged(User? user) async {
    if (user == null) {
      _currentUser = null;
    } else {
      final userSnapshot = await _database.child('users/${user.uid}').get();
      if (userSnapshot.exists) {
        log('data ${userSnapshot.value}');
        final data = userSnapshot.value as Map<Object?, Object?>;
        _currentUser = UserModel.fromJson(Map<String, dynamic>.from(data));

        debugPrint("statement ${_currentUser!.toJson()}");
      } else {
        _currentUser = null;
      }
    }
    notifyListeners();
  }

  void signOut() async {
    _setLoading(true);
    await _auth.signOut();
    _setLoading(false);
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  Future<void> logout() async {
    _setLoading(true);
    try {
      await _auth.signOut();
      _currentUser = null;

      notifyListeners();
    } catch (e) {
      debugPrint('Failed to log out: $e');
    } finally {
      _setLoading(false);
    }
  }
}
