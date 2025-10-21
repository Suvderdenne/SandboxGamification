// lib/models/lesson.dart
import 'quiz_question.dart';

class Lesson {
  final int id;
  final String title;
  final String description;
  final String category;
  final List<QuizQuestion> quiz;

  Lesson({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.quiz,
  });

  factory Lesson.fromJson(Map<String, dynamic> json) {
    return Lesson(
      id: json['id'],
      title: json['title'],
      description: json['description'] ?? '',
      category: json['category'] ?? '',
      quiz: (json['quiz'] as List<dynamic>?)
              ?.map((e) => QuizQuestion.fromJson(e))
              .toList() ??
          [],
    );
  }
}
