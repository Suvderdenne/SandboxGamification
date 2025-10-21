
class Topic {
  final int id;
  final String title;
  final String? description;
  final int order;

  Topic({
    required this.id,
    required this.title,
    this.description,
    required this.order,
  });

  factory Topic.fromJson(Map<String, dynamic> json) {
    return Topic(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      order: json['order'],
    );
  }
}
