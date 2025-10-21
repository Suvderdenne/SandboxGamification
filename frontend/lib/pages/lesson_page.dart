import 'package:flutter/material.dart';
import '../models/topic.dart';
import '../services/api_service.dart';
import '../widgets/lesson_list.dart';

class LessonPage extends StatefulWidget {
  const LessonPage({super.key});

  @override
  State<LessonPage> createState() => _LessonPageState();
}

class _LessonPageState extends State<LessonPage> {
  late Future<List<Topic>> topicsFuture;

  @override
  void initState() {
    super.initState();
    topicsFuture = ApiService.fetchTopics();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Topics")),
      body: FutureBuilder<List<Topic>>(
        future: topicsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No topics available'));
          } else {
            return LessonList(topics: snapshot.data!);
          }
        },
      ),
    );
  }
}
