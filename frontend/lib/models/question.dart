class Option {
  final int id;
  final String text;
  final bool isCorrect;

  Option({required this.id, required this.text, required this.isCorrect});

  factory Option.fromJson(Map<String, dynamic> json) {
    return Option(
      id: json['id'],
      text: json['text'],
      isCorrect: json['is_correct'],
    );
  }
}

class Question {
  final int id;
  final String text;
  final int difficultyLevel;
  final int order;
  final int quizId;
  final List<Option> options;

  Question({
    required this.id,
    required this.text,
    required this.difficultyLevel,
    required this.order,
    required this.quizId,
    required this.options,
  });

  factory Question.fromJson(Map<String, dynamic> json) {
    return Question(
      id: json['id'],
      text: json['text'],
      difficultyLevel: json['difficulty_level'],
      order: json['order'],
      quizId: json['quiz'],
      options: (json['options'] as List<dynamic>)
          .map((opt) => Option.fromJson(opt))
          .toList(),
    );
  }
}
