// lib/widgets/quiz_widget.dart
import 'package:flutter/material.dart';
import '../models/quiz.dart';
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
  late Future<Quiz> quizFuture;  // ✅ QuizQuestion-с Quiz болгоно уу

  @override
  void initState() {
    super.initState();
    // ✅ fetchQuiz() нь 1 параметр л авдаг
    quizFuture = ApiService.fetchQuiz(widget.lessonId);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Quiz>(  // ✅ List<QuizQuestion>-с Quiz болгоно уу
      future: quizFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (!snapshot.hasData) {
          return const Text('No quiz available');
        } else {
          final quiz = snapshot.data!;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: quiz.questions.map((question) {  // ✅ questions-ыг ашиглана уу
              return Card(
                margin: const EdgeInsets.all(8),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        question.text,  // ✅ question нь Question object
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 8),
                      ...question.options.map((option) {  // ✅ index ашиглахгүй
                        return ListTile(
                          leading: const Icon(Icons.circle_outlined, size: 16),
                          title: Text(option.text),
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
