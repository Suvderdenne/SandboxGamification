// lib/widgets/quiz_widget.dart
import 'package:flutter/material.dart';
import '../models/quiz_question.dart';
import '../services/api_service.dart';

class QuizWidget extends StatefulWidget {
  final String jwtToken;
  final int lessonId;

  const QuizWidget({
    super.key,
    required this.jwtToken,
    required this.lessonId,
  });

  @override
  State<QuizWidget> createState() => _QuizWidgetState();
}

class _QuizWidgetState extends State<QuizWidget> {
  late Future<List<QuizQuestion>> quizFuture;

  @override
  void initState() {
    super.initState();
    quizFuture = ApiService.fetchQuiz(widget.lessonId, widget.jwtToken);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<QuizQuestion>>(
      future: quizFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Text('No quiz available');
        } else {
          final quiz = snapshot.data!;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: quiz.map((q) {
              return Card(
                margin: const EdgeInsets.all(8),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(q.question,
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16)),
                      const SizedBox(height: 8),
                      ...q.options.asMap().entries.map((entry) {
                        final index = entry.key;
                        final option = entry.value;
                        return ListTile(
                          leading: const Icon(Icons.circle_outlined, size: 16),
                          title: Text(option),
                        );
                      }),
                    ],
                  ),
                ),
              );
            }).toList(),
          );
        }
      },
    );
  }
}
