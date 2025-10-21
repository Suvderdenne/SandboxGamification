class Quiz {
  final int id;
  final String title;
  final String? description;
  final int order;
  final int topicId;

  Quiz({
    required this.id,
    required this.title,
    this.description,
    required this.order,
    required this.topicId,
  });

  factory Quiz.fromJson(Map<String, dynamic> json) {
    return Quiz(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      order: json['order'],
      topicId: json['topic'],
    );
  }
}
