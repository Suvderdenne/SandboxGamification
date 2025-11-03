import 'package:flutter/material.dart';
import '../models/quiz.dart';
import '../services/api_service.dart';
import 'quiz_page.dart';

class LessonPage extends StatefulWidget {
  final int topicId;
  final String topicTitle;

  const LessonPage({super.key, required this.topicId, required this.topicTitle});

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
      print("❌ Error loading quizzes: $e");
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.topicTitle)),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _quizzes.isEmpty
              ? const Center(child: Text("No quizzes available"))
              : ListView.builder(
                  itemCount: _quizzes.length,
                  itemBuilder: (context, index) {
                    final quiz = _quizzes[index];
                    return Card(
                      child: ListTile(
                        title: Text(quiz.title),
                        subtitle: Text(quiz.description ?? ""),
                        trailing: const Icon(Icons.arrow_forward_ios),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => QuizPage(
                                quizId: quiz.id,
                                quizTitle: quiz.title,
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
