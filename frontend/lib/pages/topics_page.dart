// lib/pages/topics_page.dart
import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/topic.dart';
import 'lesson_page.dart';

class TopicsPage extends StatefulWidget {
  const TopicsPage({super.key});

  @override
  State<TopicsPage> createState() => _TopicsPageState();
}

class _TopicsPageState extends State<TopicsPage> {
  List<Topic> _topics = [];
  bool _loading = true;
  int _userId = 0;

  @override
  void initState() {
    super.initState();
    _fetchTopics();
    _fetchUserProfile();
  }

  Future<void> _fetchUserProfile() async {
    try {
      final profile = await ApiService.getProfile();
      if (profile != null && mounted) {
        setState(() {
          _userId = profile['id'] ?? 0;
        });
      }
    } catch (e) {
      print("❌ Error fetching profile: $e");
    }
  }

  Future<void> _fetchTopics() async {
    try {
      final topics = await ApiService.fetchTopics();
      setState(() {
        _topics = topics;
        _loading = false;
      });
    } catch (e) {
      print("❌ Error fetching topics: $e");
      setState(() => _loading = false);
    }
  }

  final List<Color> _topicColors = [
    const Color(0xFF6366F1),
    const Color(0xFF8B5CF6),
    const Color(0xFFEC4899),
    const Color(0xFF10B981),
    const Color(0xFFF59E0B),
    const Color(0xFF3B82F6),
  ];

  final List<IconData> _topicIcons = [
    Icons.code,
    Icons.data_object,
    Icons.terminal,
    Icons.web,
    Icons.memory,
    Icons.developer_board,
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar.large(
            floating: true,
            title: const Text("Сэдвүүд"),
            actions: [
              IconButton(
                icon: const Icon(Icons.logout),
                onPressed: _logout,
              ),
            ],
          ),
          _loading
              ? const SliverFillRemaining(
                  child: Center(child: CircularProgressIndicator()),
                )
              : _topics.isEmpty
                  ? const SliverFillRemaining(
                      child: Center(
                        child: Text("Одоогоор сэдэв байхгүй байна"),
                      ),
                    )
                  : SliverPadding(
                      padding: const EdgeInsets.all(16),
                      sliver: SliverGrid(
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 0.85,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                        ),
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            final topic = _topics[index];
                            final color =
                                _topicColors[index % _topicColors.length];
                            final icon =
                                _topicIcons[index % _topicIcons.length];

                            return _TopicCard(
                              topic: topic,
                              color: color,
                              icon: icon,
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => LessonPage(
                                      topicId: topic.id,
                                      topicTitle: topic.title,
                                      userId: _userId,
                                    ),
                                  ),
                                );
                              },
                            );
                          },
                          childCount: _topics.length,
                        ),
                      ),
                    ),
        ],
      ),
    );
  }

  Future<void> _logout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Гарах"),
        content: const Text("Үнэхээр гарахыг хүсэж байна уу?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Болих"),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Гарах"),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      try {
        await ApiService.logout();
        if (mounted) {
          Navigator.pushReplacementNamed(context, '/');
        }
      } catch (e) {
        print("❌ Logout error: $e");
      }
    }
  }
}

class _TopicCard extends StatelessWidget {
  final Topic topic;
  final Color color;
  final IconData icon;
  final VoidCallback onTap;

  const _TopicCard({
    required this.topic,
    required this.color,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                color,
                color.withValues(alpha: 0.7),
              ],
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: Colors.white, size: 32),
                ),
                const Spacer(),
                Text(
                  topic.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                if (topic.description != null &&
                    topic.description!.isNotEmpty)
                  Text(
                    topic.description!,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.9),
                      fontSize: 12,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
