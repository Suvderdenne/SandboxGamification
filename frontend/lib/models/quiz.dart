class Quiz {
  final int id;
  final String title;
  final String? description;
  final int topicId;
  final int order;
  final List<Question> questions;

  Quiz({
    required this.id,
    required this.title,
    this.description,
    required this.topicId,
    required this.order,
    required this.questions,
  });

  factory Quiz.fromJson(Map<String, dynamic> json) {
    final questionsJson = (json['questions'] as List<dynamic>?) ?? [];
    return Quiz(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      topicId: json['topic_id'],
      order: json['order'],
      questions: questionsJson.map((q) => Question.fromJson(q)).toList(),
    );
  }
}

class Question {
  final int id;
  final String text;
  final int difficultyLevel;
  final int order;
  final List<Option> options;

  Question({
    required this.id,
    required this.text,
    required this.difficultyLevel,
    required this.order,
    required this.options,
  });

  factory Question.fromJson(Map<String, dynamic> json) {
    final optionsJson = (json['options'] as List<dynamic>?) ?? [];
    return Question(
      id: json['id'],
      text: json['text'],
      difficultyLevel: json['difficulty_level'],
      order: json['order'],
      options: optionsJson.map((o) => Option.fromJson(o)).toList(),
    );
  }
}

class Option {
  final int id;
  final String text;
  final bool isCorrect;

  Option({
    required this.id,
    required this.text,
    required this.isCorrect,
  });

  factory Option.fromJson(Map<String, dynamic> json) {
    return Option(
      id: json['id'],
      text: json['text'],
      isCorrect: json['is_correct'],
    );
  }
}
