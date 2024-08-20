class UserModel {
  final String uid;
  final String name;
  final DateTime createdAt;
  DateTime lastQuizTime;
  int highestScore;
  bool isAdmin;

  UserModel({
    required this.uid,
    required this.name,
    required this.createdAt,
    required this.lastQuizTime,
    required this.highestScore,
    required this.isAdmin,
  });

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'name': name,
      'createdAt': createdAt.toIso8601String(),
      'lastQuizTime': lastQuizTime.toIso8601String(),
      'highestScore': highestScore,
      'isAdmin': isAdmin,
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
    );
  }

  UserModel copyWith({
    String? uid,
    String? name,
    DateTime? createdAt,
    DateTime? lastQuizTime,
    int? highestScore,
    bool? isAdmin,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      name: name ?? this.name,
      isAdmin: isAdmin ?? this.isAdmin,
      createdAt: createdAt ?? this.createdAt,
      lastQuizTime: lastQuizTime ?? this.lastQuizTime,
      highestScore: highestScore ?? this.highestScore,
    );
  }
}
