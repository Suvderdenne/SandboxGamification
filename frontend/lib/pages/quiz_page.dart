import 'package:flutter/material.dart';
import '../models/question.dart';
import '../services/api_service.dart';

class QuizPage extends StatefulWidget {
  final int quizId;
  final String quizTitle;

  const QuizPage({super.key, required this.quizId, required this.quizTitle});

  @override
  State<QuizPage> createState() => _QuizPageState();
}

class _QuizPageState extends State<QuizPage> {
  List<Question> questions = [];
  int currentIndex = 0;
  int score = 0;
  bool loading = true;
  bool answered = false;
  int? selectedAnswer;

  @override
  void initState() {
    super.initState();
    _loadQuestions();
  }

  Future<void> _loadQuestions() async {
    try {
      final fetched = await ApiService.fetchQuestions(widget.quizId);
      setState(() {
        questions = fetched;
        loading = false;
      });
    } catch (e) {
      print("❌ Failed to load questions: $e");
      setState(() => loading = false);
    }
  }

  void _submitAnswer(int choiceIndex) {
    final correctIndex = questions[currentIndex].correctAnswerIndex;
    if (choiceIndex == correctIndex) score++;

    setState(() {
      answered = true;
      selectedAnswer = choiceIndex;
    });

    Future.delayed(const Duration(seconds: 1), () {
      if (currentIndex < questions.length - 1) {
        setState(() {
          currentIndex++;
          answered = false;
          selectedAnswer = null;
        });
      } else {
        _showResultDialog();
      }
    });
  }

  void _showResultDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Quiz Complete!'),
        content: Text('Your score: $score / ${questions.length}'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // close dialog
              Navigator.pop(context); // back to quiz list
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (questions.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: Text(widget.quizTitle)),
        body: const Center(child: Text("No questions found.")),
      );
    }

    final question = questions[currentIndex];
    return Scaffold(
      appBar: AppBar(title: Text(widget.quizTitle)),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              "Question ${currentIndex + 1}/${questions.length}",
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Text(question.text, style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 20),
            ...List.generate(question.choices.length, (i) {
              final choice = question.choices[i];
              final isCorrect = i == question.correctAnswerIndex;
              final isSelected = i == selectedAnswer;
              Color color = Colors.grey.shade200;

              if (answered && isSelected) {
                color = isCorrect ? Colors.green.shade300 : Colors.red.shade300;
              }

              return GestureDetector(
                onTap: answered ? null : () => _submitAnswer(i),
                child: Container(
                  width: double.infinity,
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade400),
                  ),
                  child: Text(choice, style: const TextStyle(fontSize: 16)),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}
