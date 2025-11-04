// lib/pages/quiz_page.dart
import 'package:flutter/material.dart';
import '../models/quiz.dart';
import '../services/api_service.dart';

class QuizPage extends StatefulWidget {
  final int quizId;
  final String quizTitle;
  final int userId;

  const QuizPage({
    super.key,
    required this.quizId,
    required this.quizTitle,
    required this.userId,
  });

  @override
  State<QuizPage> createState() => _QuizPageState();
}

class _QuizPageState extends State<QuizPage> with SingleTickerProviderStateMixin {
  Quiz? _quiz;
  Map<int, int> _selectedAnswers = {};
  bool _loading = true;
  bool _submitted = false;
  int _currentQuestionIndex = 0;
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _loadQuiz();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
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
    if (_submitted) return;
    setState(() {
      _selectedAnswers[questionId] = optionId;
    });
    _animationController.forward(from: 0);
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

  Future<void> _submitQuiz() async {
    setState(() => _submitted = true);
    final score = _calculateScore();
    final totalQuestions = _quiz!.questions.length;
    final percentage = (score / totalQuestions * 100).round();
    final selectedOptionIds = _selectedAnswers.values.toList();

    try {
      // Save quiz progress
      await ApiService.submitQuizProgress(
        quizId: widget.quizId,
        userId: widget.userId,
        requiredScore: 70,
        achievedScore: percentage.toDouble(),
      );

      // Save quiz details (selected answers)
      await ApiService.submitQuizDetails(
        quizId: widget.quizId,
        userId: widget.userId,
        selectedOptions: selectedOptionIds,
      );

      // Save user score
      await ApiService.submitUserScore(
        userId: widget.userId,
        quizProgressId: 1, // This should be returned from progress endpoint
        totalScore: score.toDouble(),
      );

      if (mounted) {
        _showResultDialog(score, totalQuestions, percentage);
      }
    } catch (e) {
      print("❌ Error submitting quiz: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Үр дүнг хадгалахад алдаа гарлаа: $e")),
        );
      }
    }
  }

  void _showResultDialog(int score, int total, int percentage) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Column(
          children: [
            Icon(
              percentage >= 70 ? Icons.celebration : Icons.emoji_events_outlined,
              size: 64,
              color: percentage >= 70 ? Colors.green : Colors.orange,
            ),
            const SizedBox(height: 16),
            Text(
              percentage >= 70 ? "Баяр хүргэе! 🎉" : "Сайн байна! 👍",
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "Таны оноо:",
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
            const SizedBox(height: 8),
            Text(
              "$score / $total",
              style: const TextStyle(
                fontSize: 48,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "$percentage%",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: percentage >= 70 ? Colors.green : Colors.orange,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text("Буцах"),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                _selectedAnswers.clear();
                _submitted = false;
                _currentQuestionIndex = 0;
              });
            },
            child: const Text("Дахин оролдох"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return Scaffold(
        appBar: AppBar(title: const Text("Quiz ачааллаж байна...")),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_quiz == null) {
      return Scaffold(
        appBar: AppBar(title: Text(widget.quizTitle)),
        body: const Center(child: Text("Quiz ачааллахад алдаа гарлаа")),
      );
    }

    final question = _quiz!.questions[_currentQuestionIndex];
    final progress = (_currentQuestionIndex + 1) / _quiz!.questions.length;

    return Scaffold(
      appBar: AppBar(
        title: Text(_quiz!.title),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(8),
          child: LinearProgressIndicator(
            value: progress,
            backgroundColor: Colors.grey[200],
          ),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Асуулт ${_currentQuestionIndex + 1}/${_quiz!.questions.length}",
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    "${(_selectedAnswers.length / _quiz!.questions.length * 100).round()}%",
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            question.text,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 24),
                          ...question.options.map((option) {
                            final selected =
                                _selectedAnswers[question.id] == option.id;
                            final correct = _submitted && option.isCorrect;
                            final wrong = _submitted &&
                                selected &&
                                !option.isCorrect;

                            Color? borderColor;
                            Color? backgroundColor;
                            IconData? icon;

                            if (correct) {
                              borderColor = Colors.green;
                              backgroundColor = Colors.green[50];
                              icon = Icons.check_circle;
                            } else if (wrong) {
                              borderColor = Colors.red;
                              backgroundColor = Colors.red[50];
                              icon = Icons.cancel;
                            } else if (selected) {
                              borderColor =
                                  Theme.of(context).colorScheme.primary;
                              backgroundColor = Theme.of(context)
                                  .colorScheme
                                  .primaryContainer;
                            }

                            return Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: InkWell(
                                onTap: _submitted
                                    ? null
                                    : () =>
                                        _selectAnswer(question.id, option.id),
                                borderRadius: BorderRadius.circular(12),
                                child: Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: backgroundColor,
                                    border: Border.all(
                                      color: borderColor ?? Colors.grey[300]!,
                                      width: 2,
                                    ),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Row(
                                    children: [
                                      if (icon != null)
                                        Icon(icon, color: borderColor)
                                      else
                                        Container(
                                          width: 24,
                                          height: 24,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            border: Border.all(
                                              color: selected
                                                  ? Theme.of(context)
                                                      .colorScheme
                                                      .primary
                                                  : Colors.grey[400]!,
                                              width: 2,
                                            ),
                                            color: selected
                                                ? Theme.of(context)
                                                    .colorScheme
                                                    .primary
                                                : null,
                                          ),
                                        ),
                                      const SizedBox(width: 16),
                                      Expanded(
                                        child: Text(
                                          option.text,
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: selected
                                                ? FontWeight.bold
                                                : FontWeight.normal,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          }),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                if (_currentQuestionIndex > 0)
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        setState(() => _currentQuestionIndex--);
                      },
                      icon: const Icon(Icons.arrow_back),
                      label: const Text("Өмнөх"),
                    ),
                  ),
                if (_currentQuestionIndex > 0) const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: ElevatedButton(
                    onPressed: () {
                      if (_currentQuestionIndex <
                          _quiz!.questions.length - 1) {
                        setState(() => _currentQuestionIndex++);
                      } else if (_selectedAnswers.length ==
                          _quiz!.questions.length) {
                        _submitQuiz();
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("Бүх асуултад хариулна уу"),
                          ),
                        );
                      }
                    },
                    child: Text(
                      _currentQuestionIndex < _quiz!.questions.length - 1
                          ? "Дараагийн"
                          : "Дуусгах",
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
