import 'package:flutter/material.dart';
import '../models/lesson.dart';

class LessonList extends StatelessWidget {
  final List<Lesson> lessons;
  final Function(Lesson) onSelect;

  const LessonList({
    super.key,
    required this.lessons,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    final categories = lessons.map((e) => e.category).toSet().toList();

    return ListView(
      children: [
        for (var category in categories)
          ExpansionTile(
            title: Text(category),
            children: [
              for (var lesson
                  in lessons.where((l) => l.category == category).toList())
                ListTile(
                  title: Text(lesson.title),
                  onTap: () => onSelect(lesson),
                ),
            ],
          ),
      ],
    );
  }
}
