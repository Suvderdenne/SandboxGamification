// pages/teacher_page.dart

import 'package:flutter/material.dart';
import 'quiz_management_page.dart';
import '../models/topic.dart';
import '../models/quiz.dart';
import '../services/api_service.dart';
import '../layouts/main_layout.dart';
import '../utils/constants.dart';

class TeacherPage extends StatefulWidget {
  const TeacherPage({super.key});

  @override
  State<TeacherPage> createState() => _TeacherPageState();
}

class _TeacherPageState extends State<TeacherPage> {
  List<Topic> _topics = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final topics = await ApiService.fetchTopics();
      setState(() {
        _topics = topics;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Алдаа гарлаа: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return MainLayout(
      title: 'Багшийн самбар',
      currentNavIndex: 0,
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _topics.length,
              itemBuilder: (context, index) {
                final topic = _topics[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 16),
                  child: ExpansionTile(
                    title: Text(topic.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text(topic.description ?? ''),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.add_circle_outline, color: Colors.green),
                          onPressed: () => _showAddQuizDialog(topic.id),
                        ),
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.blue),
                          onPressed: () => _showTopicDialog(topic: topic),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _deleteTopic(topic.id),
                        ),
                      ],
                    ),
                    children: [
                      _QuizList(topicId: topic.id, onUpdate: _loadData),
                    ],
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showTopicDialog(),
        backgroundColor: AppColors.secondary,
        child: const Icon(Icons.library_add, color: Colors.white),
      ),
    );
  }

  void _showTopicDialog({Topic? topic}) {
    final titleController = TextEditingController(text: topic?.title);
    final descController = TextEditingController(text: topic?.description);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(topic == null ? 'Шинэ хичээл/сэдэв' : 'Сэдэв засах'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: titleController, decoration: const InputDecoration(labelText: 'Гарчиг')),
            TextField(controller: descController, decoration: const InputDecoration(labelText: 'Тайлбар')),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Цуцлах')),
          ElevatedButton(
            onPressed: () async {
              final data = {'title': titleController.text, 'description': descController.text, 'order': topic?.order ?? 0};
              if (topic == null) {
                await ApiService.createTopic(data);
              } else {
                await ApiService.updateTopic(topic.id, data);
              }
              _loadData();
              if (context.mounted) Navigator.pop(context);
            },
            child: const Text('Хадгалах'),
          ),
        ],
      ),
    );
  }

  void _showAddQuizDialog(int topicId) {
    final titleController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Шинэ тест нэмэх'),
        content: TextField(controller: titleController, decoration: const InputDecoration(labelText: 'Тестийн гарчиг')),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Цуцлах')),
          ElevatedButton(
            onPressed: () async {
              await ApiService.createQuiz({
                'title': titleController.text,
                'topic_id': topicId,
                'order': 0,
              });
              _loadData();
              if (context.mounted) Navigator.pop(context);
            },
            child: const Text('Нэмэх'),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteTopic(int id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Устгах уу?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Үгүй')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Тийм')),
        ],
      ),
    );
    if (confirm == true) {
      await ApiService.deleteTopic(id);
      _loadData();
    }
  }
}

class _QuizList extends StatefulWidget {
  final int topicId;
  final VoidCallback onUpdate;
  const _QuizList({required this.topicId, required this.onUpdate});

  @override
  State<_QuizList> createState() => _QuizListState();
}

class _QuizListState extends State<_QuizList> {
  List<Quiz> _quizzes = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _fetchQuizzes();
  }

  Future<void> _fetchQuizzes() async {
    try {
      final allQuizzes = await ApiService.fetchQuizzes();
      setState(() {
        _quizzes = allQuizzes.where((q) => q.topicId == widget.topicId).toList();
        _loading = false;
      });
    } catch (e) {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const LinearProgressIndicator();
    if (_quizzes.isEmpty) return const Padding(padding: EdgeInsets.all(8.0), child: Text('Тест байхгүй'));

    return Column(
      children: _quizzes.map((quiz) => ListTile(
        title: Text(quiz.title),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.playlist_add_check, color: Colors.green),
              tooltip: 'Асуулт удирдах',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => QuizManagementPage(quizId: quiz.id),
                  ),
                );
              },
            ),
            IconButton(
              icon: const Icon(Icons.edit_note, color: Colors.blue),
              onPressed: () => _editQuiz(quiz),
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.red),
              onPressed: () => _deleteQuiz(quiz.id),
            ),
          ],
        ),
      )).toList(),
    );
  }

  Future<void> _editQuiz(Quiz quiz) async {
    final controller = TextEditingController(text: quiz.title);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Тест засах'),
        content: TextField(controller: controller),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Цуцлах')),
          ElevatedButton(
            onPressed: () async {
              await ApiService.updateQuiz(quiz.id, {
                'title': controller.text,
                'topic_id': quiz.topicId,
                'order': quiz.order,
              });
              _fetchQuizzes();
              if (context.mounted) Navigator.pop(context);
            },
            child: const Text('Хадгалах'),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteQuiz(int id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Тест устгах уу?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Үгүй')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Тийм')),
        ],
      ),
    );
    if (confirm == true) {
      await ApiService.deleteQuiz(id);
      _fetchQuizzes();
    }
  }
}
