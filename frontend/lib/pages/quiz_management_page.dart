// pages/quiz_management_page.dart

import 'package:flutter/material.dart';
import '../models/quiz.dart';
import '../services/api_service.dart';
import '../utils/constants.dart';

class QuizManagementPage extends StatefulWidget {
  final int quizId;
  const QuizManagementPage({super.key, required this.quizId});

  @override
  State<QuizManagementPage> createState() => _QuizManagementPageState();
}

class _QuizManagementPageState extends State<QuizManagementPage> {
  Quiz? _quiz;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadQuiz();
  }

  Future<void> _loadQuiz() async {
    setState(() => _isLoading = true);
    try {
      final quiz = await ApiService.fetchQuiz(widget.quizId);
      setState(() {
        _quiz = quiz;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_quiz?.title ?? 'Тест удирдах'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _quiz?.questions.length ?? 0,
              itemBuilder: (context, index) {
                final question = _quiz!.questions[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 16),
                  child: ExpansionTile(
                    title: Text(question.text),
                    subtitle: Text('Хүндрэл: ${question.difficultyLevel}'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.blue),
                          onPressed: () => _showQuestionDialog(question: question),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _deleteQuestion(question.id),
                        ),
                      ],
                    ),
                    children: [
                      ...question.options.map((opt) => ListTile(
                            title: Text(opt.text),
                            trailing: opt.isCorrect
                                ? const Icon(Icons.check_circle, color: Colors.green)
                                : null,
                            onTap: () => _showOptionDialog(question.id, option: opt),
                          )),
                      ListTile(
                        leading: const Icon(Icons.add),
                        title: const Text('Сонголт нэмэх'),
                        onTap: () => _showOptionDialog(question.id),
                      ),
                    ],
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showQuestionDialog(),
        child: const Icon(Icons.add_comment),
      ),
    );
  }

  void _showQuestionDialog({Question? question}) {
    final textController = TextEditingController(text: question?.text);
    final difficultyController = TextEditingController(text: question?.difficultyLevel.toString() ?? '50');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(question == null ? 'Асуулт нэмэх' : 'Асуулт засах'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: textController, decoration: const InputDecoration(labelText: 'Асуулт')),
            TextField(
              controller: difficultyController,
              decoration: const InputDecoration(labelText: 'Хүндрэл (1-100)'),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Цуцлах')),
          ElevatedButton(
            onPressed: () async {
              final data = {
                'quiz_id': widget.quizId,
                'text': textController.text,
                'difficulty_level': int.tryParse(difficultyController.text) ?? 50,
                'order': question?.order ?? 0,
              };
              if (question == null) {
                await ApiService.createQuestion(data);
              } else {
                await ApiService.updateQuestion(question.id, data);
              }
              _loadQuiz();
              if (context.mounted) Navigator.pop(context);
            },
            child: const Text('Хадгалах'),
          ),
        ],
      ),
    );
  }

  void _showOptionDialog(int questionId, {Option? option}) {
    final textController = TextEditingController(text: option?.text);
    bool isCorrect = option?.isCorrect ?? false;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text(option == null ? 'Сонголт нэмэх' : 'Сонголт засах'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: textController, decoration: const InputDecoration(labelText: 'Сонголт')),
              CheckboxListTile(
                title: const Text('Зөв хариулт уу?'),
                value: isCorrect,
                onChanged: (val) => setState(() => isCorrect = val ?? false),
              ),
            ],
          ),
          actions: [
            if (option != null)
              TextButton(
                onPressed: () async {
                  await ApiService.deleteOption(option.id);
                  _loadQuiz();
                  if (context.mounted) Navigator.pop(context);
                },
                child: const Text('Устгах', style: TextStyle(color: Colors.red)),
              ),
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Цуцлах')),
            ElevatedButton(
              onPressed: () async {
                final data = {
                  'question_id': questionId,
                  'text': textController.text,
                  'is_correct': isCorrect,
                };
                if (option == null) {
                  await ApiService.createOption(data);
                } else {
                  await ApiService.updateOption(option.id, data);
                }
                _loadQuiz();
                if (context.mounted) Navigator.pop(context);
              },
              child: const Text('Хадгалах'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _deleteQuestion(int id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Асуулт устгах уу?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Үгүй')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Тийм')),
        ],
      ),
    );
    if (confirm == true) {
      await ApiService.deleteQuestion(id);
      _loadQuiz();
    }
  }
}
