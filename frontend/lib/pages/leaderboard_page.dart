// pages/leaderboard_page.dart

import 'package:flutter/material.dart';
import '../layouts/main_layout.dart';
import '../services/api_service.dart';
import '../utils/constants.dart';

class LeaderboardPage extends StatefulWidget {
  const LeaderboardPage({super.key});

  @override
  State<LeaderboardPage> createState() => _LeaderboardPageState();
}

class _LeaderboardPageState extends State<LeaderboardPage> {
  List<Map<String, dynamic>> _leaderboard = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadLeaderboard();
  }

  Future<void> _loadLeaderboard() async {
    setState(() => _loading = true);
    try {
      final data = await ApiService.fetchLeaderboard();
      if (mounted) {
        setState(() {
          _leaderboard = data;
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return MainLayout(
      title: 'Тэргүүлэгчид',
      currentNavIndex: 1, // Leaderboard tab
      showBottomNav: true,
      showDrawer: true,
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadLeaderboard,
              child: _leaderboard.isEmpty
                  ? const Center(child: Text('Одоогоор өгөгдөл алга'))
                  : ListView.builder(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      itemCount: _leaderboard.length,
                      itemBuilder: (context, index) {
                        final item = _leaderboard[index];
                        final isMe = item['user_id'] == ApiService.userId;
                        
                        // Top 3 decorations
                        Color? bgColor;
                        Widget? leadingIcon;
                        if (index == 0) {
                          bgColor = Colors.amber.withOpacity(0.1);
                          leadingIcon = const Icon(Icons.emoji_events, color: Colors.amber);
                        } else if (index == 1) {
                          bgColor = Colors.grey[300]!.withOpacity(0.3);
                          leadingIcon = const Icon(Icons.emoji_events, color: Colors.grey);
                        } else if (index == 2) {
                          bgColor = Colors.orange[300]!.withOpacity(0.2);
                          leadingIcon = const Icon(Icons.emoji_events, color: Colors.orange);
                        }

                        return Card(
                          color: isMe ? AppColors.primary.withOpacity(0.05) : null,
                          elevation: isMe ? 4 : 1,
                          margin: const EdgeInsets.only(bottom: AppSpacing.sm),
                          child: ListTile(
                            leading: Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: bgColor ?? Colors.grey[200],
                                shape: BoxShape.circle,
                              ),
                              child: Center(
                                child: leadingIcon ?? Text('${index + 1}', style: const TextStyle(fontWeight: FontWeight.bold)),
                              ),
                            ),
                            title: Text(
                              item['username'],
                              style: TextStyle(
                                fontWeight: isMe ? FontWeight.bold : FontWeight.normal,
                                color: isMe ? AppColors.primary : null,
                              ),
                            ),
                            subtitle: Text('${item['completed_quizzes']} тест дуусгасан'),
                            trailing: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  '${item['total_points']} оноо',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.primary,
                                    fontSize: 16,
                                  ),
                                ),
                                Text(
                                  '${item['total_time']}с',
                                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
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
