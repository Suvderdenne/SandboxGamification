import 'package:flutter/material.dart';
import '../models/lesson.dart';
import '../widgets/quiz_widget.dart';
import '../widgets/theme_switch.dart';

class LessonPage extends StatefulWidget {
  final List<Lesson> lessons;
  final VoidCallback onToggleTheme;

  const LessonPage({
    super.key,
    required this.lessons,
    required this.onToggleTheme,
  });

  @override
  State<LessonPage> createState() => _LessonPageState();
}

class _LessonPageState extends State<LessonPage> {
  Lesson? selectedLesson;

  @override
  void initState() {
    super.initState();
    selectedLesson = widget.lessons.first;
  }

  @override
  Widget build(BuildContext context) {
    final categories = widget.lessons.map((e) => e.category).toSet().toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text("W3School Clone (Flutter)"),
        actions: [
          ThemeSwitch(onToggleTheme: widget.onToggleTheme),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(color: Colors.blue),
              child: Text("Lessons", style: TextStyle(color: Colors.white)),
            ),
            for (var category in categories)
              ExpansionTile(
                title: Text(category),
                children: [
                  for (var lesson in widget.lessons
                      .where((l) => l.category == category))
                    ListTile(
                      title: Text(lesson.title),
                      onTap: () {
                        setState(() => selectedLesson = lesson);
                        Navigator.pop(context);
                      },
                    )
                ],
              ),
          ],
        ),
      ),
      body: selectedLesson == null
          ? const Center(child: Text("Select a lesson"))
          : Padding(
              padding: const EdgeInsets.all(16),
              child: ListView(
                children: [
                  Text(
                    selectedLesson!.title,
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    selectedLesson!.description,
                    style: const TextStyle(color: Colors.grey),
                  ),
                  const Divider(),
                  Text(selectedLesson!.content),
                  const SizedBox(height: 24),
                  QuizWidget(quiz: selectedLesson!.quiz),
                ],
              ),
            ),
    );
  }
}
