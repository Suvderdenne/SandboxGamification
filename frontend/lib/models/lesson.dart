import 'quiz_question.dart';

class Lesson {
  final String id;
  final String title;
  final String category;
  final String description;
  final String content;
  final List<QuizQuestion> quiz;

  Lesson({
    required this.id,
    required this.title,
    required this.category,
    required this.description,
    required this.content,
    required this.quiz,
  });
}
