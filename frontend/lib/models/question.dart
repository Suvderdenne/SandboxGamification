class Question {
  final int id;
  final String text;
  final List<String> choices;
  final int correctAnswerIndex;

  Question({
    required this.id,
    required this.text,
    required this.choices,
    required this.correctAnswerIndex,
  });

  factory Question.fromJson(Map<String, dynamic> json) {
    return Question(
      id: json['id'],
      text: json['text'],
      choices: List<String>.from(json['choices']),
      correctAnswerIndex: json['correct_answer_index'],
    );
  }
}
