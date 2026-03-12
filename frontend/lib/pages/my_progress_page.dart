// pages/my_progress_page.dart

import 'package:flutter/material.dart';
import '../layouts/main_layout.dart';
import '../services/api_service.dart';
import '../utils/constants.dart';
import '../models/quiz.dart';

class MyProgressPage extends StatefulWidget {
  const MyProgressPage({super.key});

  @override
  State<MyProgressPage> createState() => _MyProgressPageState();
}

class _MyProgressPageState extends State<MyProgressPage> {
  List<Map<String, dynamic>> _progress = [];
  List<Quiz> _allQuizzes = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _loading = true);
    try {
      if (ApiService.userId != null) {
        final progressData = await ApiService.fetchUserProgress(ApiService.userId!);
        final quizData = await ApiService.fetchQuizzes();
        
        if (mounted) {
          setState(() {
            _progress = progressData;
            _allQuizzes = quizData;
            _loading = false;
          });
        }
      }
    } catch (e) {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return MainLayout(
      title: 'Миний явц',
      currentNavIndex: 2, // My Progress tab
      showBottomNav: true,
      showDrawer: true,
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadData,
              child: _progress.isEmpty
                  ? const Center(child: Text('Та одоогоор ямар нэгэн тест өгөөгүй байна.'))
                  : ListView.builder(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      itemCount: _progress.length,
                      itemBuilder: (context, index) {
                        final p = _progress[index];
                        final quizId = p['test_id'];
                        final quiz = _allQuizzes.firstWhere(
                          (q) => q.id == quizId,
                          orElse: () => Quiz(id: 0, title: 'Тодорхойгүй тест', topicId: 0, order: 0, questions: []),
                        );
                        
                        final achievedScore = double.tryParse(p['achieved_score'].toString()) ?? 0.0;
                        final isPassed = achievedScore >= 70.0;

                        return Card(
                          margin: const EdgeInsets.only(bottom: AppSpacing.md),
                          child: Padding(
                            padding: const EdgeInsets.all(AppSpacing.md),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        quiz.title,
                                        style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: (isPassed ? AppColors.success : AppColors.error).withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Text(
                                        isPassed ? 'Тэнцсэн' : 'Тэнцээгүй',
                                        style: TextStyle(
                                          color: isPassed ? AppColors.success : AppColors.error,
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: AppSpacing.md),
                                LinearProgressIndicator(
                                  value: achievedScore / 100,
                                  backgroundColor: Colors.grey[200],
                                  color: isPassed ? AppColors.success : AppColors.warning,
                                  minHeight: 8,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                const SizedBox(height: AppSpacing.sm),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text('Оноо: ${achievedScore.toStringAsFixed(1)}%'),
                                    Text('Хугацаа: ${p['completion_time']}с'),
                                  ],
                                ),
                                if (p['created_at'] != null)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 4),
                                    child: Text(
                                      'Огноо: ${p['created_at'].toString().substring(0, 10)}',
                                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
    );
  }
}
