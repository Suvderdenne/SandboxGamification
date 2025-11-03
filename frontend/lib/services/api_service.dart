import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/topic.dart';
import '../models/quiz.dart';

class ApiService {
  static const String baseUrl = "http://127.0.0.1:8000/api";

  static String? csrfToken;
  static String? jwtToken;

  // -----------------------------
  //  AUTH SECTION
  // -----------------------------

  /// Step 1: Get CSRF token
  static Future<void> getCsrfToken() async {
    print("🟡 Getting CSRF token...");
    final response = await http.get(Uri.parse('$baseUrl/get_csrf/'));

    print("CSRF response: ${response.statusCode}, body: ${response.body}");

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      csrfToken = data['csrfToken'];
      print("✅ CSRF token = $csrfToken");
    } else {
      throw Exception("Failed to get CSRF token: ${response.statusCode}");
    }
  }

  /// Step 2: Login and get user token
  static Future<bool> login(String username, String password) async {
    if (csrfToken == null) await getCsrfToken();

    print("🟡 Logging in with username=$username, csrfToken=$csrfToken");

    final response = await http.post(
      Uri.parse('$baseUrl/login/'),
      headers: {
        'Content-Type': 'application/json',
        'X-CSRFToken': csrfToken!,
        'Cookie': 'csrftoken=$csrfToken',
      },
      body: jsonEncode({'username': username, 'password': password}),
    );

    print("🔵 Login response: ${response.statusCode}, body: ${response.body}");

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      jwtToken = data['token'];
      print("✅ Logged in successfully, token = $jwtToken");
      return jwtToken != null;
    } else {
      print("❌ Login failed: ${response.body}");
      return false;
    }
  }

  // Helper to build headers for authenticated requests
  static Map<String, String> _authHeaders() {
    if (jwtToken == null || csrfToken == null) {
      throw Exception("Not authenticated — login required");
    }
    return {
      'Authorization': 'Bearer $jwtToken',
      'Cookie': 'csrftoken=$csrfToken',
      'Content-Type': 'application/json',
    };
  }

  // -----------------------------
  //  DATA FETCHING SECTION
  // -----------------------------

  /// Fetch Topics
  static Future<List<Topic>> fetchTopics() async {
    print("🟡 Fetching topics...");
    final response = await http.get(
      Uri.parse('$baseUrl/quiz/topics/'),
      headers: _authHeaders(),
    );

    print("📦 Topics response: ${response.statusCode}, body: ${response.body}");

    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);
      final List<dynamic> data = decoded['data']; // ✅ Corrected structure
      return data.map((e) => Topic.fromJson(e)).toList();
    } else {
      throw Exception('Failed to fetch topics: ${response.body}');
    }
  }

  /// Fetch Quizzes
  static Future<List<Quiz>> fetchQuizzes() async {
    print("🟡 Fetching quizzes...");
    final response = await http.get(
      Uri.parse('$baseUrl/quiz/quizzes/'),
      headers: _authHeaders(),
    );

    print(
      "📦 Quizzes response: ${response.statusCode}, body: ${response.body}",
    );

    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);
      final List<dynamic> data = decoded['data']; // ✅ Handle wrapped response
      return data.map((e) => Quiz.fromJson(e)).toList();
    } else {
      throw Exception('Failed to fetch quizzes: ${response.body}');
    }
  }

  /// Fetch Questions for a quiz
  static Future<List<Question>> fetchQuestions(int quizId) async {
    print("🟡 Fetching questions for quiz $quizId...");
    final response = await http.get(
      Uri.parse('$baseUrl/quiz/questions/?quiz=$quizId'),
      headers: _authHeaders(),
    );

    print(
      "📦 Questions response: ${response.statusCode}, body: ${response.body}",
    );

    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);
      final List<dynamic> data = decoded['data']; // ✅ Adjusted for wrapped API
      return data.map((e) => Question.fromJson(e)).toList();
    } else {
      throw Exception('Failed to fetch questions: ${response.body}');
    }
  }

  /// Create new quiz (POST)
  static Future<List<Quiz>> createQuiz(
    List<Map<String, dynamic>> newQuizzes,
  ) async {
    print("🟢 Creating quizzes...");
    final response = await http.post(
      Uri.parse('$baseUrl/quiz/quizzes/'),
      headers: _authHeaders(),
      body: jsonEncode(newQuizzes),
    );

    print(
      "📦 Create quiz response: ${response.statusCode}, body: ${response.body}",
    );

    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);
      final List<dynamic> data = decoded['data'];
      return data.map((e) => Quiz.fromJson(e)).toList();
    } else {
      throw Exception('Failed to create quiz: ${response.body}');
    }
  }

  /// quizs
  static Future<Quiz> fetchQuiz(int id) async {
    final response = await http.get( 
    Uri.parse("$baseUrl/quiz/quizzes/$id"),
    headers: _authHeaders());

    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);
      return Quiz.fromJson(jsonData);
    } else {
      throw Exception("Failed to load quiz");
    }
  }
}
