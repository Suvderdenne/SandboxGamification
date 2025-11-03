import 'package:flutter/material.dart';
import '../models/quiz.dart';
import '../services/api_service.dart';

class QuizPage extends StatefulWidget {
  final int quizId;
  final String quizTitle;

  const QuizPage({super.key, required this.quizId, required this.quizTitle});

  @override
  State<QuizPage> createState() => _QuizPageState();
}

class _QuizPageState extends State<QuizPage> {
  Quiz? _quiz;
  Map<int, int> _selectedAnswers = {}; // questionId -> optionId
  bool _loading = true;
  bool _submitted = false;

  @override
  void initState() {
    super.initState();
    _loadQuiz();
  }

  Future<void> _loadQuiz() async {
    try {
      final quiz = await ApiService.fetchQuiz(widget.quizId);
      setState(() {
        _quiz = quiz;
        _loading = false;
      });
    } catch (e) {
      print("❌ Error fetching quiz: $e");
      setState(() => _loading = false);
    }
  }

  void _selectAnswer(int questionId, int optionId) {
    setState(() {
      _selectedAnswers[questionId] = optionId;
    });
  }

  int _calculateScore() {
    int score = 0;
    for (var question in _quiz!.questions) {
      final selectedId = _selectedAnswers[question.id];
      final correctOption = question.options.firstWhere((o) => o.isCorrect);
      if (selectedId == correctOption.id) score++;
    }
    return score;
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        appBar: null,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_quiz == null) {
      return Scaffold(
        appBar: AppBar(title: Text(widget.quizTitle)),
        body: const Center(child: Text("Failed to load quiz.")),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text(_quiz!.title)),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            if (_quiz!.description != null && _quiz!.description!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: Text(_quiz!.description!, style: const TextStyle(fontSize: 16)),
              ),
            Expanded(
              child: ListView.builder(
                itemCount: _quiz!.questions.length,
                itemBuilder: (context, index) {
                  final question = _quiz!.questions[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("${index + 1}. ${question.text}", style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 8),
                          Column(
                            children: question.options.map((option) {
                              final selected = _selectedAnswers[question.id] == option.id;
                              final correct = _submitted && option.isCorrect;
                              final wrong = _submitted && selected && !option.isCorrect;

                              Color? bgColor;
                              if (correct) bgColor = Colors.green[300];
                              if (wrong) bgColor = Colors.red[300];

                              return Container(
                                margin: const EdgeInsets.symmetric(vertical: 4),
                                color: bgColor,
                                child: ListTile(
                                  title: Text(option.text),
                                  leading: Radio<int>(
                                    value: option.id,
                                    groupValue: _selectedAnswers[question.id],
                                    onChanged: _submitted ? null : (val) => _selectAnswer(question.id, val!),
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            ElevatedButton(
              onPressed: _submitted
                  ? null
                  : () {
                      setState(() {
                        _submitted = true;
                      });
                      final score = _calculateScore();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("Таны оноо: $score/${_quiz!.questions.length}")),
                      );
                    },
              child: const Text("Submit"),
            ),
          ],
        ),
      ),
    );
  }
}
