import 'package:flutter/material.dart';
import '../layouts/main_layout.dart';
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

  @override
  void initState() {
    super.initState();
    _fetchTopics();
  }

  Future<void> _fetchTopics() async {
    try {
      final topics = await ApiService.fetchTopics();
      setState(() {
        _topics = topics;
        _loading = false;
      });
    } catch (e) {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    // 🎯 MainLayout ашиглаж байгаа нь
    return MainLayout(
      title: 'Сэдвүүд',              // Header-д гарах гарчиг
      currentNavIndex: 0,            // Footer-д идэвхтэй tab (0 = Нүүр)
      showBottomNav: true,           // Footer харуулах эсэх
      showDrawer: true,              // Sidebar харуулах эсэх
      
      // 🟢 BODY хэсэг - зөвхөн content-ээ бичнэ
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _topics.isEmpty
              ? const Center(child: Text('Сэдэв байхгүй байна'))
              : GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.85,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                  ),
                  itemCount: _topics.length,
                  itemBuilder: (context, index) {
                    final topic = _topics[index];
                    return _TopicCard(
                      topic: topic,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => LessonPage(
                              topicId: topic.id,
                              topicTitle: topic.title,
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
    );
  }
}

// Topic card widget
class _TopicCard extends StatelessWidget {
  final Topic topic;
  final VoidCallback onTap;

  const _TopicCard({required this.topic, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.blue, Colors.blue.shade300],
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.book, color: Colors.white, size: 40),
              const Spacer(),
              Text(
                topic.title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}