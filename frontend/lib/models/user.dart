// lib/models/user.dart
class UserProfile {
  final int id;
  final String username;
  final String email;  // ✅ gmail → email

  UserProfile({
    required this.id,
    required this.username,
    required this.email,  // ✅ gmail → email
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'] ?? 0,
      username: json['username'] ?? '',
      email: json['email'] ?? '',  // ✅ 'gmail' хэрэггүй
    );
  }
}

class QuizProgressModel {
  final int id;
  final int testId;
  final int userId;
  final double requiredScore;
  final double achievedScore;

  QuizProgressModel({
    required this.id,
    required this.testId,
    required this.userId,
    required this.requiredScore,
    required this.achievedScore,
  });

  factory QuizProgressModel.fromJson(Map<String, dynamic> json) {
    return QuizProgressModel(
      id: json['id'],
      testId: json['test_id'],
      userId: json['user_id'],
      requiredScore: double.parse(json['required_score'].toString()),
      achievedScore: double.parse(json['achieved_score'].toString()),
    );
  }
}

class UserScore {
  final int id;
  final int userId;
  final int quizProgressId;
  final double totalScore;

  UserScore({
    required this.id,
    required this.userId,
    required this.quizProgressId,
    required this.totalScore,
  });

  factory UserScore.fromJson(Map<String, dynamic> json) {
    return UserScore(
      id: json['id'],
      userId: json['user_id'],
      quizProgressId: json['quiz_progress_id'],
      totalScore: double.parse(json['total_score'].toString()),
    );
  }
}
