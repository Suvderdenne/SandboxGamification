// lib/services/api_service.dart
import 'dart:convert' as json;
import 'package:http/http.dart' as http;
import '../models/topic.dart';
import '../models/quiz.dart';

class ApiService {
  static const String baseUrl = "http://127.0.0.1:8000/api";
  // static const String baseUrl = "https://mandakhcmsbackend-production.up.railway.app/api";

  static String? csrfToken;
  static String? jwtToken;
  static int? userId;

  // ========================
  // CSRF TOKEN
  // ========================
  static Future<void> getCsrfToken() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/get_csrf/'));
      if (response.statusCode == 200) {
        final data = json.jsonDecode(response.body);
        csrfToken = data['csrfToken'];
      } else {
        throw Exception("Failed to get CSRF token: ${response.statusCode}");
      }
    } catch (e) {
      rethrow;
    }
  }
  // ========================
  // REGISTRATION
  // ========================
    static Future<bool> register(
      String username,
      String email,
      String password,
    ) async {
      try {
        if (csrfToken == null) await getCsrfToken();

        final response = await http.post(
          Uri.parse('$baseUrl/register/'),
          headers: {
            'Content-Type': 'application/json',
            'X-CSRFToken': csrfToken!,
          },
          body: json.jsonEncode({
            'username': username,
            'email': email,  
            'password': password,
          }),
        );


        if (response.statusCode == 201) {
          return true;
        } else {
          return false;
        }
      } catch (e) {
        return false;
      }
    }


  // ========================
  // LOGIN
  // ========================
  static Future<bool> login(String username, String password) async {
    try {
      if (csrfToken == null) await getCsrfToken();

      final response = await http.post(
        Uri.parse('$baseUrl/login/'),
        headers: {
          'Content-Type': 'application/json',
          'X-CSRFToken': csrfToken!,
          'Cookie': 'csrftoken=$csrfToken',
        },
        body: json.jsonEncode({
          'username': username,
          'password': password,
        }),
      );

      if (response.statusCode == 200) {
        final data = json.jsonDecode(response.body);
        jwtToken = data['token'];
        userId = data['user_id'];
        return true;
      } else {
        return false;
      }
    } catch (e) {
      return false;
    }
  }

  // ========================
  // LOGOUT
  // ========================
  static Future<bool> logout() async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/logout/'),
        headers: _authHeaders(),
      );

      if (response.statusCode == 200) {
        jwtToken = null;
        csrfToken = null;
        userId = null;
        return true;
      } else {
        return false;
      }
    } catch (e) {
      return false;
    }
  }

  // ========================
  // PROFILE
  // ========================
  static Future<Map<String, dynamic>?> getProfile() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/profile/'),
        headers: _authHeaders(),
      );

      if (response.statusCode == 200) {
        final data = json.jsonDecode(response.body);
        userId = data["id"];
        return data;
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }

  // ========================
  // AUTH HEADERS
  // ========================
  static Map<String, String> _authHeaders() {
    if (jwtToken == null || csrfToken == null) {
      throw Exception("Not authenticated");
    }
    return {
      'Authorization': 'Bearer $jwtToken',
      'Cookie': 'csrftoken=$csrfToken',
      'Content-Type': 'application/json',
    };
  }

  // ========================
  // TOPICS
  // ========================
  static Future<List<Topic>> fetchTopics() async {
    print("🟡 Fetching topics...");
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/quiz/topics/'),
        headers: _authHeaders(),
      );

      print("Topics response: ${response.statusCode}");

      if (response.statusCode == 200) {
        final decoded = json.jsonDecode(response.body);
        final List<dynamic> data = decoded['data'];
        return data.map((e) => Topic.fromJson(e)).toList();
      } else {
        throw Exception('Failed to fetch topics');
      }
    } catch (e) {
      print("❌ Topics error: $e");
      rethrow;
    }
  }

  // ========================
  // QUIZZES
  // ========================
  static Future<List<Quiz>> fetchQuizzes() async {
    print("🟡 Fetching quizzes...");
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/quiz/quizzes/'),
        headers: _authHeaders(),
      );

      print("Quizzes response: ${response.statusCode}");

      if (response.statusCode == 200) {
        final decoded = json.jsonDecode(response.body);
        final List<dynamic> data = decoded['data'];
        return data.map((e) => Quiz.fromJson(e)).toList();
      } else {
        throw Exception('Failed to fetch quizzes');
      }
    } catch (e) {
      print("❌ Quizzes error: $e");
      rethrow;
    }
  }

  // ========================
  // QUIZ DETAIL
  // ========================
  static Future<Quiz> fetchQuiz(int id) async {
    print("🟡 Fetching quiz $id...");
    try {
      final response = await http.get(
        Uri.parse("$baseUrl/quiz/quizzes/$id/"),
        headers: _authHeaders(),
      );

      print("Quiz response: ${response.statusCode}");

      if (response.statusCode == 200) {
        final jsonData = json.jsonDecode(response.body);
        return Quiz.fromJson(jsonData);
      } else {
        throw Exception("Failed to load quiz");
      }
    } catch (e) {
      print("❌ Quiz error: $e");
      rethrow;
    }
  }

  // ========================
  // QUIZ PROGRESS
  // ========================
  static Future<bool> submitQuizProgress({
    required int quizId,
    required int userId,
    required double requiredScore,
    required double achievedScore,
  }) async {
    print("🟡 Submitting quiz progress...");
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/test/progress/'),
        headers: _authHeaders(),
        body: json.jsonEncode({
          'test_id': quizId,
          'user_id': userId,
          'required_score': requiredScore,
          'achieved_score': achievedScore,
        }),
      );

      print("Progress response: ${response.statusCode}");

      if (response.statusCode == 201) {
        print("✅ Progress saved");
        return true;
      } else {
        print("❌ Failed to save progress: ${response.body}");
        return false;
      }
    } catch (e) {
      print("❌ Progress error: $e");
      return false;
    }
  }

  // ========================
  // QUIZ DETAILS (Answers)
  // ========================
  static Future<bool> submitQuizDetails({
    required int quizId,
    required int userId,
    required List<int> selectedOptions,
  }) async {
    print("🟡 Submitting quiz details...");
    try {
      final List<Map<String, dynamic>> details = selectedOptions
          .map((optionId) => {
                'test_id': quizId,
                'user_id': userId,
                'option_id': optionId,
              })
          .toList();

      final response = await http.post(
        Uri.parse('$baseUrl/test/details/'),
        headers: _authHeaders(),
        body: json.jsonEncode(details),
      );

      print("Details response: ${response.statusCode}");

      if (response.statusCode == 201) {
        print("✅ Quiz details saved");
        return true;
      } else {
        print("❌ Failed to save details: ${response.body}");
        return false;
      }
    } catch (e) {
      print("❌ Details error: $e");
      return false;
    }
  }

  // ========================
  // TOPICS CRUD
  // ========================
  static Future<bool> createTopic(Map<String, dynamic> data) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/quiz/topics/'),
        headers: _authHeaders(),
        body: json.jsonEncode(data),
      );
      return response.statusCode == 201;
    } catch (e) {
      return false;
    }
  }

  static Future<bool> updateTopic(int id, Map<String, dynamic> data) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/quiz/topics/$id/'),
        headers: _authHeaders(),
        body: json.jsonEncode(data),
      );
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  static Future<bool> deleteTopic(int id) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/quiz/topics/$id/'),
        headers: _authHeaders(),
      );
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  // ========================
  // QUIZZES CRUD
  // ========================
  static Future<bool> createQuiz(Map<String, dynamic> data) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/quiz/quizzes/'),
        headers: _authHeaders(),
        body: json.jsonEncode(data),
      );
      return response.statusCode == 201;
    } catch (e) {
      return false;
    }
  }

  static Future<bool> updateQuiz(int id, Map<String, dynamic> data) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/quiz/quizzes/$id/'),
        headers: _authHeaders(),
        body: json.jsonEncode(data),
      );
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  static Future<bool> deleteQuiz(int id) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/quiz/quizzes/$id/'),
        headers: _authHeaders(),
      );
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  // ========================
  // QUESTIONS CRUD
  // ========================
  static Future<bool> createQuestion(Map<String, dynamic> data) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/quiz/questions/'),
        headers: _authHeaders(),
        body: json.jsonEncode(data),
      );
      return response.statusCode == 201;
    } catch (e) {
      return false;
    }
  }

  static Future<bool> updateQuestion(int id, Map<String, dynamic> data) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/quiz/questions/$id/'),
        headers: _authHeaders(),
        body: json.jsonEncode(data),
      );
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  static Future<bool> deleteQuestion(int id) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/quiz/questions/$id/'),
        headers: _authHeaders(),
      );
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  // ========================
  // OPTIONS CRUD
  // ========================
  static Future<bool> createOption(dynamic data) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/quiz/options/'),
        headers: _authHeaders(),
        body: json.jsonEncode(data),
      );
      return response.statusCode == 201;
    } catch (e) {
      return false;
    }
  }

  static Future<bool> updateOption(int id, Map<String, dynamic> data) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/quiz/options/$id/'),
        headers: _authHeaders(),
        body: json.jsonEncode(data),
      );
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  static Future<bool> deleteOption(int id) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/quiz/options/$id/'),
        headers: _authHeaders(),
      );
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  // ========================
  // USER SCORES
  // ========================
  static Future<bool> submitUserScore({
    required int userId,
    required int quizProgressId,
    required double totalScore,
  }) async {
    print("🟡 Submitting user score...");
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/test/scores/'),
        headers: _authHeaders(),
        body: json.jsonEncode({
          'user_id': userId,
          'quiz_progress_id': quizProgressId,
          'total_score': totalScore,
        }),
      );

      print("Score response: ${response.statusCode}");

      if (response.statusCode == 201) {
        print("✅ Score saved");
        return true;
      } else {
        print("❌ Failed to save score: ${response.body}");
        return false;
      }
    } catch (e) {
      print("❌ Score error: $e");
      return false;
    }
  }

  // ========================
  // FETCH USER SCORES
  // ========================
  static Future<List<Map<String, dynamic>>> fetchUserScores(int userId) async {
    print("🟡 Fetching user scores...");
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/test/scores/'),
        headers: _authHeaders(),
      );

      print("User scores response: ${response.statusCode}");

      if (response.statusCode == 200) {
        final decoded = json.jsonDecode(response.body);
        final List<dynamic> data = decoded['data'];
        return data
            .cast<Map<String, dynamic>>()
            .where((score) => score['user_id'] == userId)
            .toList();
      } else {
        return [];
      }
    } catch (e) {
      print("❌ User scores error: $e");
      return [];
    }
  }
}
