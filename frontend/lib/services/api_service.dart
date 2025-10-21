import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/topic.dart';
import '../models/quiz.dart';
import '../models/question.dart';

class ApiService {
  static const String baseUrl = "http://127.0.0.1:8000/api/quiz";

  // Fetch topics
  static Future<List<Topic>> fetchTopics() async {
    final response = await http.get(Uri.parse('$baseUrl/topics/'));
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => Topic.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load topics');
    }
  }

  // Fetch quizzes
  static Future<List<Quiz>> fetchQuizzes() async {
    final response = await http.get(Uri.parse('$baseUrl/quizzes/'));
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => Quiz.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load quizzes');
    }
  }

  // Fetch questions with options
  static Future<List<Question>> fetchQuestions(int quizId) async {
    final response = await http.get(Uri.parse('$baseUrl/questions/?quiz=$quizId'));
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => Question.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load questions');
    }
  }
}
