// lib/models/quiz_question.dart
class QuizQuestion {
  final int id;
  final String question;
  final List<String> options;
  final int answer;

  QuizQuestion({
    required this.id,
    required this.question,
    required this.options,
    required this.answer,
  });

  factory QuizQuestion.fromJson(Map<String, dynamic> json) {
    return QuizQuestion(
      id: json['id'],
      question: json['question'],
      options: List<String>.from(json['options']),
      answer: json['answer'],
    );
  }
}
