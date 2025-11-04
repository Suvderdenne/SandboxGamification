// models/user_progress.dart
class UserProgress {
  final int totalPoints;
  final int level;
  final int streakDays;
  final List<String> achievements;

  UserProgress({
    required this.totalPoints,
    required this.level,
    required this.streakDays,
    required this.achievements,
  });

  factory UserProgress.fromJson(Map<String, dynamic> json) {
    return UserProgress(
      totalPoints: json['total_points'] ?? 0,
      level: json['level'] ?? 1,
      streakDays: json['streak_days'] ?? 0,
      achievements: List<String>.from(json['achievements'] ?? []),
    );
  }
}
