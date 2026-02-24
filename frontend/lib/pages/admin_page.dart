import 'package:flutter/material.dart';
import 'quiz_management_page.dart';
import '../models/topic.dart';
import '../models/quiz.dart';
import '../services/api_service.dart';
import '../layouts/main_layout.dart';
import '../utils/constants.dart';

class AdminPage extends StatefulWidget {
  const AdminPage({super.key});

  @override
  State<AdminPage> createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<Topic> _topics = [];
  List<Quiz> _quizzes = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final topics = await ApiService.fetchTopics();
      final quizzes = await ApiService.fetchQuizzes();
      setState(() {
        _topics = topics;
        _quizzes = quizzes;
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
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MainLayout(
      title: 'Админ самбар',
      currentNavIndex: 0,
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                TabBar(
                  controller: _tabController,
                  tabs: const [
                    Tab(text: 'Сэдвүүд'),
                    Tab(text: 'Тестүүд'),
                  ],
                  labelColor: AppColors.primary,
                  unselectedLabelColor: Colors.grey,
                  indicatorColor: AppColors.primary,
                ),
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildTopicList(),
                      _buildQuizList(),
                    ],
                  ),
                ),
              ],
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if (_tabController.index == 0) {
            _showTopicDialog();
          } else {
            _showQuizDialog();
          }
        },
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildTopicList() {
    return ListView.builder(
      itemCount: _topics.length,
      itemBuilder: (context, index) {
        final topic = _topics[index];
        return ListTile(
          title: Text(topic.title),
          subtitle: Text(topic.description ?? 'Тайлбаргүй'),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
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
        );
      },
    );
  }

  Widget _buildQuizList() {
    return ListView.builder(
      itemCount: _quizzes.length,
      itemBuilder: (context, index) {
        final quiz = _quizzes[index];
        return ListTile(
          title: Text(quiz.title),
          subtitle: Text('ID: ${quiz.id} | Topic: ${quiz.topicId}'),
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
                icon: const Icon(Icons.edit, color: Colors.blue),
                onPressed: () => _showQuizDialog(quiz: quiz),
              ),
              IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: () => _deleteQuiz(quiz.id),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showTopicDialog({Topic? topic}) {
    final titleController = TextEditingController(text: topic?.title);
    final descController = TextEditingController(text: topic?.description);
    final orderController = TextEditingController(text: topic?.order.toString() ?? '0');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(topic == null ? 'Сэдэв нэмэх' : 'Сэдэв засах'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(labelText: 'Гарчиг'),
              ),
              TextField(
                controller: descController,
                decoration: const InputDecoration(labelText: 'Тайлбар'),
              ),
              TextField(
                controller: orderController,
                decoration: const InputDecoration(labelText: 'Дараалал'),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Цуцлах'),
          ),
          ElevatedButton(
            onPressed: () async {
              final data = {
                'title': titleController.text,
                'description': descController.text,
                'order': int.tryParse(orderController.text) ?? 0,
              };

              bool success;
              if (topic == null) {
                success = await ApiService.createTopic(data);
              } else {
                success = await ApiService.updateTopic(topic.id, data);
              }

              if (success) {
                _loadData();
                if (context.mounted) Navigator.pop(context);
              }
            },
            child: const Text('Хадгалах'),
          ),
        ],
      ),
    );
  }

  void _showQuizDialog({Quiz? quiz}) {
    final titleController = TextEditingController(text: quiz?.title);
    final descController = TextEditingController(text: quiz?.description);
    final topicIdController = TextEditingController(text: quiz?.topicId.toString());
    final orderController = TextEditingController(text: quiz?.order.toString() ?? '0');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(quiz == null ? 'Тест нэмэх' : 'Тест засах'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(labelText: 'Гарчиг'),
              ),
              TextField(
                controller: descController,
                decoration: const InputDecoration(labelText: 'Тайлбар'),
              ),
              TextField(
                controller: topicIdController,
                decoration: const InputDecoration(labelText: 'Сэдэв ID'),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: orderController,
                decoration: const InputDecoration(labelText: 'Дараалал'),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Цуцлах'),
          ),
          ElevatedButton(
            onPressed: () async {
              final data = {
                'title': titleController.text,
                'description': descController.text,
                'topic_id': int.tryParse(topicIdController.text) ?? 0,
                'order': int.tryParse(orderController.text) ?? 0,
              };

              bool success;
              if (quiz == null) {
                success = await ApiService.createQuiz(data);
              } else {
                success = await ApiService.updateQuiz(quiz.id, data);
              }

              if (success) {
                _loadData();
                if (context.mounted) Navigator.pop(context);
              }
            },
            child: const Text('Хадгалах'),
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
        content: const Text('Энэ сэдвийг устгахдаа итгэлтэй байна уу?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Үгүй')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Тийм')),
        ],
      ),
    );

    if (confirm == true) {
      final success = await ApiService.deleteTopic(id);
      if (success) _loadData();
    }
  }

  Future<void> _deleteQuiz(int id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Устгах уу?'),
        content: const Text('Энэ тестийг устгахдаа итгэлтэй байна уу?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Үгүй')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Тийм')),
        ],
      ),
    );

    if (confirm == true) {
      final success = await ApiService.deleteQuiz(id);
      if (success) _loadData();
    }
  }
}
