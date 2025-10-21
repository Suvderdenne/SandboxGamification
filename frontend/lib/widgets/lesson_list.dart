import 'package:flutter/material.dart';
import '../models/topic.dart';

class LessonList extends StatelessWidget {
  final List<Topic> topics;
  const LessonList({super.key, required this.topics});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: topics.length,
      itemBuilder: (context, index) {
        final topic = topics[index];
        return Card(
          margin: const EdgeInsets.all(8),
          child: ListTile(
            title: Text(topic.title),
            subtitle: Text(topic.description ?? "No description"),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () {
              // Navigate to quiz page later
            },
          ),
        );
      },
    );
  }
}
