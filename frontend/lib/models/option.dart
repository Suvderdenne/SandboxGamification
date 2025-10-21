class Option {
  final int id;
  final String text;
  final bool isCorrect;
  final int questionId;

  Option({
    required this.id,
    required this.text,
    required this.isCorrect,
    required this.questionId,
  });

  factory Option.fromJson(Map<String, dynamic> json) {
    return Option(
      id: json['id'],
      text: json['text'] ?? '',
      isCorrect: json['is_correct'] ?? false,
      questionId: json['question_id'],
    );
  }
}
