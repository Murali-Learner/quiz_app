class UserModel {
  final String uid;
  final String name;
  final DateTime createdAt;
  DateTime lastQuizTime;
  int highestScore;
  bool isAdmin;
  // List<int> scoreList;

  UserModel({
    required this.uid,
    required this.name,
    required this.createdAt,
    required this.lastQuizTime,
    required this.highestScore,
    required this.isAdmin,
    // required this.scoreList,
  });

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'name': name,
      'createdAt': createdAt.toIso8601String(),
      'lastQuizTime': lastQuizTime.toIso8601String(),
      'highestScore': highestScore,
      'isAdmin': isAdmin,
      // 'scoreList': scoreList,
    };
  }

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      uid: json['uid'] ?? '',
      isAdmin: json['isAdmin'] ?? false,
      name: json['name'] ?? '',
      createdAt: DateTime.parse(json['createdAt']),
      lastQuizTime: DateTime.parse(json['lastQuizTime']),
      highestScore: json['highestScore'] ?? 0,
      // scoreList: json['scoreList'] ?? [],
    );
  }

  UserModel copyWith({
    String? uid,
    String? name,
    DateTime? createdAt,
    DateTime? lastQuizTime,
    int? highestScore,
    bool? isAdmin,
    // List<int>? scoreList,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      name: name ?? this.name,
      isAdmin: isAdmin ?? this.isAdmin,
      createdAt: createdAt ?? this.createdAt,
      lastQuizTime: lastQuizTime ?? this.lastQuizTime,
      highestScore: highestScore ?? this.highestScore,
      // scoreList: scoreList ?? this.scoreList,
    );
  }
}
