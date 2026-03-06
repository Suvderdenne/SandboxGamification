// pages/lesson_page.dart

import 'package:flutter/material.dart';
import '../layouts/main_layout.dart';
import '../services/api_service.dart';
import '../models/quiz.dart';
import 'quiz_page.dart';

class LessonPage extends StatefulWidget {
  final int topicId;
  final String topicTitle;

  const LessonPage({
    super.key,
    required this.topicId,
    required this.topicTitle,
  });

  @override
  State<LessonPage> createState() => _LessonPageState();
}

class _LessonPageState extends State<LessonPage> {
  List<Quiz> _quizzes = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadQuizzes();
  }

  Future<void> _loadQuizzes() async {
    try {
      final all = await ApiService.fetchQuizzes();
      setState(() {
        _quizzes = all.where((q) => q.topicId == widget.topicId).toList();
        _loading = false;
      });
    } catch (e) {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return MainLayout(
      title: widget.topicTitle,
      currentNavIndex: 0,
      showBottomNav: false,      // ⚠️ Footer харуулахгүй (детайл хуудас учраас)
      showDrawer: false,         // ⚠️ Drawer харуулахгүй
      showBackButton: true,      // ✅ Back button харуулах
      
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _quizzes.length,
              itemBuilder: (context, index) {
                final quiz = _quizzes[index];
                return Card(
                  child: ListTile(
                    leading: CircleAvatar(child: Text('${index + 1}')),
                    title: Text(quiz.title),
                    subtitle: Text(quiz.description ?? ''),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => QuizPage(
                            quizId: quiz.id,
                            quizTitle: quiz.title,
                            userId: ApiService.userId ?? 0,
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
    );
  }
}