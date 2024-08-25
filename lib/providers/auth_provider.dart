import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

import '../models/user_model.dart';

class AuthProvider with ChangeNotifier {
  static final AuthProvider _instance = AuthProvider._internal();

  factory AuthProvider() => _instance;

  AuthProvider._internal() {
    _auth = FirebaseAuth.instance;
    _usersRef =
        FirebaseDatabase.instance.ref("quizzes/quiz1/participatedUsers/");
    _listenAuthChanges();
  }

  late final FirebaseAuth _auth;
  late final DatabaseReference _usersRef;

  bool _isLoading = false;
  UserModel? _currentUser;
  bool _isAdmin = false;
  Map<String, UserModel> _users = {};

  bool get isLoading => _isLoading;
  bool get isAdmin => _isAdmin;
  Map<String, UserModel> get users => _users;
  UserModel? get currentUser => _currentUser;

  void toggleAdmin(bool value) {
    _isAdmin = value;
    notifyListeners();
  }

  void setUsers(Map<String, UserModel> dbUsers) {
    _users = {};
    _users = dbUsers;
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
      debugPrint("admin login start");
      UserModel? userModel = await _getUserByName(userName);
      debugPrint("admin login start ${userModel!.toJson()}");
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
        debugPrint("admin login1");
        if (userModel.isAdmin) {
          debugPrint("admin login2");
          _isAdmin = true;
          notifyListeners();
        } else {
          debugPrint("not admin login");
          _isAdmin = false;
          notifyListeners();
        }
        _currentUser = userModel;
        notifyListeners();
        debugPrint("admin login finished");
      }
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
      await _usersRef.child(_currentUser!.uid).update(_currentUser!.toJson());
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
    return _usersRef.orderByChild('highestScore').onValue.map((event) {
      final usersMap = event.snapshot.value as Map<dynamic, dynamic>;
      debugPrint("usersMap $usersMap");
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
      final userSnapshot = await _usersRef.child(user.uid).get();
      if (userSnapshot.exists) {
        final data = userSnapshot.value as Map<Object?, Object?>;
        _currentUser = UserModel.fromJson(Map<String, dynamic>.from(data));
      } else {
        _currentUser = null;
      }
    }
    notifyListeners();
  }

  Stream<List<UserModel>> getUsersStream() {
    return _usersRef.onValue.map((event) {
      Map<dynamic, dynamic>? usersMap =
          event.snapshot.value as Map<dynamic, dynamic>?;
      if (usersMap != null) {
        List<UserModel> users = usersMap.entries
            .map((entry) {
              debugPrint("getUsersStream ${entry.value["createdAt"]}");
              return UserModel.fromJson(Map<String, dynamic>.from(entry.value));
            })
            .toList()
            .where((element) => element.isAdmin == false)
            .toList();
        log("users.length ${users.length}");
        return users;
      }
      return [];
    });
  }

  Future<UserModel?> _getUserByName(String name) async {
    try {
      UserModel? userModel;
      final data = _usersRef.orderByChild('name');
      final data1 = await data.once();
      final usersSnapshot = data1.snapshot;

      if (usersSnapshot.exists && usersSnapshot.value != null) {
        final usersMap = usersSnapshot.value as Map<dynamic, dynamic>;
        _users.clear();
        usersMap.forEach((key, val) {
          _users[key] = UserModel.fromJson(
            Map<String, dynamic>.from(
              Map<dynamic, dynamic>.from(val as Map),
            ),
          );
        });
        notifyListeners();

        _users.forEach((uid, user) {
          if (user.name == name) {
            userModel = user;
          }
        });
        debugPrint("I'm at get user by name ${userModel!.toJson()}");
        return userModel;
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
      await _usersRef.child(userModel.uid).set(userModel.toJson());
    } catch (e) {
      debugPrint('Error saving user to database: $e');
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
