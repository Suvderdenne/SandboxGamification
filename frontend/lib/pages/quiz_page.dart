// pages/quiz_page.dart

import 'package:flutter/material.dart';
import '../layouts/main_layout.dart';
import '../models/quiz.dart';
import '../services/api_service.dart';
import '../utils/constants.dart';
import '../widgets/loading_widget.dart';
import '../widgets/empty_display.dart';
import '../widgets/error_display.dart';

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
  
  DateTime? _startTime;
  Duration _elapsedTime = Duration.zero;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _startTime = DateTime.now();
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
      print("**** quiz data: ");
      print(quiz);
      print("**** end quiz data ****\n\n");
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
      
      if (selectedId == correctOption.id) {
        score++;
      }
    }
    return score;
  }

  Future<void> _submitQuiz() async {
    _elapsedTime = DateTime.now().difference(_startTime!);
    
    setState(() => _submitted = true);
    
    final score = _calculateScore();
    final totalQuestions = _quiz!.questions.length;
    final percentage = (score / totalQuestions * 100).round();
    final selectedOptionIds = _selectedAnswers.values.toList();

    try {
      await ApiService.submitQuizProgress(
        quizId: widget.quizId,
        userId: widget.userId,
        requiredScore: 70,
        achievedScore: percentage.toDouble(),
      );

      await ApiService.submitQuizDetails(
        quizId: widget.quizId,
        userId: widget.userId,
        selectedOptions: selectedOptionIds,
      );

      await ApiService.submitUserScore(
        userId: widget.userId,
        quizProgressId: 1,
        totalScore: score.toDouble(),
      );

      if (mounted) {
        _showResultDialog(score, totalQuestions, percentage);
      }
    } catch (e) {
      print("❌ Error submitting quiz: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Үр дүн хадгалахад алдаа: $e"),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  void _showResultDialog(int score, int total, int percentage) {
    final passed = percentage >= 70;
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Column(
          children: [
            Icon(
              passed ? Icons.celebration : Icons.emoji_events_outlined,
              size: 64,
              color: passed ? AppColors.success : AppColors.warning,
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              passed ? "Баяр хүргэе! 🎉" : "Сайн байна! 👍",
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
              style: TextStyle(
                fontSize: 16,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              "$score / $total",
              style: const TextStyle(
                fontSize: 48,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              "$percentage%",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: passed ? AppColors.success : AppColors.warning,
              ),
            ),
            
            const Divider(height: AppSpacing.xl),
            
            _buildResultInfo(
              icon: Icons.timer,
              label: 'Хугацаа',
              value: _formatDuration(_elapsedTime),
            ),
            const SizedBox(height: AppSpacing.sm),
            _buildResultInfo(
              icon: Icons.check_circle,
              label: 'Зөв хариулт',
              value: '$score/$total',
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text('Буцах'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                _selectedAnswers.clear();
                _submitted = false;
                _currentQuestionIndex = 0;
                _startTime = DateTime.now();
              });
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
            child: const Text('Дахин оролдох'),
          ),
        ],
      ),
    );
  }

  Widget _buildResultInfo({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Icon(icon, size: 20, color: AppColors.textSecondary),
            const SizedBox(width: AppSpacing.sm),
            Text(
              label,
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ],
        ),
        Text(
          value,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    return '${minutes}м ${seconds}с';
  }

  @override
  Widget build(BuildContext context) {
    // Loading state
    if (_loading) {
      return MainLayout(
        title: 'Ачааллаж байна...',
        showBottomNav: false,
        showBackButton: true,
        body: LoadingWidget(
          message: 'Quiz мэдээлэл бэлтгэж байна',
          logoAsset: 'assets/logo.png',  // ✅ Өөрийн лого байвал
          spinColor: AppColors.primary,       // ✅ Төслийн өнгөтэй нийцүүлэх
          delayDuration: const Duration(seconds: 2),
          showPulse: true,
        ),
      );
    }

    // Error state - quiz байхгүй
    if (_quiz == null) {
      return MainLayout(
        title: widget.quizTitle,
        showBottomNav: false,
        showBackButton: true,
        body: ErrorDisplay(
          title: 'Алдаа гарлаа',
          message: 'Quiz ачааллахад алдаа гарлаа.',
          actionButton: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              OutlinedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Буцах'),
              ),
              const SizedBox(width: 16),
              ElevatedButton(
                onPressed: () => _loadQuiz(),
                child: const Text('Дахин оролдох'),
              ),
            ],
          ),
        ),
      );
    }

    // Empty state - асуулт байхгүй
    if (_quiz!.questions.isEmpty) {
      return MainLayout(
        title: _quiz!.title,
        showBottomNav: false,
        showBackButton: true,
        body: EmptyDisplay(
          title: 'Мэдээлэл олдсонгүй',
          message: '${_quiz!.title} тестэд асуулт ороогүй байна.',
          actionButton: ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Буцах'),
          ),
        ),
      );
    }

    // Success state - асуулт байгаа
    final question = _quiz!.questions[_currentQuestionIndex];
    final progress = (_currentQuestionIndex + 1) / _quiz!.questions.length;

    return MainLayout(
      title: _quiz!.title,
      showBottomNav: false,
      showBackButton: true,
      showDrawer: false,
      
      body: Column(
        children: [
          LinearProgressIndicator(
            value: progress,
            backgroundColor: Colors.grey[200],
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
          ),
          
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            color: AppColors.background,
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
                    horizontal: AppSpacing.md,
                    vertical: AppSpacing.xs,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.check_circle,
                        size: 16,
                        color: AppColors.primary,
                      ),
                      const SizedBox(width: AppSpacing.xs),
                      Text(
                        "${_selectedAnswers.length}/${_quiz!.questions.length}",
                        style: TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Card(
                    elevation: 2,
                    child: Padding(
                      padding: const EdgeInsets.all(AppSpacing.lg),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.sm,
                              vertical: AppSpacing.xs,
                            ),
                            decoration: BoxDecoration(
                              color: _getDifficultyColor(question.difficultyLevel).withOpacity(0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              _getDifficultyText(question.difficultyLevel),
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: _getDifficultyColor(question.difficultyLevel),
                              ),
                            ),
                          ),
                          
                          const SizedBox(height: AppSpacing.md),
                          
                          Text(
                            question.text,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          
                          const SizedBox(height: AppSpacing.lg),
                          
                          ...question.options.asMap().entries.map((entry) {
                            final index = entry.key;
                            final option = entry.value;
                            final selected = _selectedAnswers[question.id] == option.id;
                            final correct = _submitted && option.isCorrect;
                            final wrong = _submitted && selected && !option.isCorrect;

                            Color? borderColor;
                            Color? backgroundColor;
                            IconData? icon;

                            if (correct) {
                              borderColor = AppColors.success;
                              backgroundColor = AppColors.success.withOpacity(0.1);
                              icon = Icons.check_circle;
                            } else if (wrong) {
                              borderColor = AppColors.error;
                              backgroundColor = AppColors.error.withOpacity(0.1);
                              icon = Icons.cancel;
                            } else if (selected) {
                              borderColor = AppColors.primary;
                              backgroundColor = AppColors.primary.withOpacity(0.1);
                            }

                            return Padding(
                              padding: const EdgeInsets.only(bottom: AppSpacing.md),
                              child: InkWell(
                                onTap: _submitted
                                    ? null
                                    : () => _selectAnswer(question.id, option.id),
                                borderRadius: BorderRadius.circular(12),
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  padding: const EdgeInsets.all(AppSpacing.md),
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
                                        Icon(icon, color: borderColor, size: 24)
                                      else
                                        Container(
                                          width: 24,
                                          height: 24,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            border: Border.all(
                                              color: selected
                                                  ? AppColors.primary
                                                  : Colors.grey[400]!,
                                              width: 2,
                                            ),
                                            color: selected
                                                ? AppColors.primary
                                                : Colors.transparent,
                                          ),
                                          child: selected
                                              ? const Icon(
                                                  Icons.check,
                                                  color: Colors.white,
                                                  size: 12,
                                                )
                                              : null,
                                        ),
                                      
                                      const SizedBox(width: AppSpacing.md),
                                      
                                      Container(
                                        width: 26,
                                        height: 26,
                                        decoration: BoxDecoration(
                                          color: selected || correct || wrong
                                              ? (borderColor ?? AppColors.primary).withOpacity(0.2)
                                              : Colors.grey[200],
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: Center(
                                          child: Text(
                                            String.fromCharCode(65 + index),
                                            style: TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold,
                                              color: selected || correct || wrong
                                                  ? borderColor
                                                  : AppColors.textPrimary,
                                            ),
                                          ),
                                        ),
                                      ),
                                      
                                      const SizedBox(width: AppSpacing.md),
                                      
                                      Expanded(
                                        child: Text(
                                          option.text,
                                          style: TextStyle(
                                            fontSize: 12,
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
          
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -5),
                ),
              ],
            ),
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
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                      ),
                    ),
                  ),
                
                if (_currentQuestionIndex > 0)
                  const SizedBox(width: AppSpacing.md),
                
                Expanded(
                  flex: 2,
                  child: ElevatedButton(
                    onPressed: () {
                      if (_currentQuestionIndex < _quiz!.questions.length - 1) {
                        setState(() => _currentQuestionIndex++);
                      } else {
                        if (_selectedAnswers.length == _quiz!.questions.length) {
                          _submitQuiz();
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("Бүх асуултад хариулна уу"),
                              backgroundColor: AppColors.warning,
                            ),
                          );
                        }
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          _currentQuestionIndex < _quiz!.questions.length - 1
                              ? "Дараагийн"
                              : "Дуусгах",
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Icon(
                          _currentQuestionIndex < _quiz!.questions.length - 1
                              ? Icons.arrow_forward
                              : Icons.check,
                        ),
                      ],
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

  Color _getDifficultyColor(int level) {
    if (level < 30) return AppColors.success;
    if (level < 70) return AppColors.warning;
    return AppColors.error;
  }

  String _getDifficultyText(int level) {
    if (level < 30) return 'Хялбар';
    if (level < 70) return 'Дунд';
    return 'Хүнд';
  }
}