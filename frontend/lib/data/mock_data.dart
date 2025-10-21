// lib/data/mock_data.dart
import '../models/lesson.dart';
import '../models/quiz_question.dart';

final mockLessons = [
  Lesson(
    id: 1,
    title: "Intro to Python",
    description: "Learn basic syntax and data types in Python.",
    category: "Python Basics",
    quiz: [
      QuizQuestion(
        id: 1,
        question: "What is the output of print(2 + 3)?",
        options: ["5", "23", "Error", "None"],
        answer: 0,
      ),
      QuizQuestion(
        id: 2,
        question: "Which of these is a valid variable name?",
        options: ["1var", "_var", "var!", "None"],
        answer: 1,
      ),
    ],
  ),
  Lesson(
    id: 2,
    title: "Control Flow",
    description: "If statements, loops, and more.",
    category: "Python Basics",
    quiz: [
      QuizQuestion(
        id: 3,
        question: "What keyword starts a loop?",
        options: ["if", "while", "loop", "repeat"],
        answer: 1,
      ),
      QuizQuestion(
        id: 4,
        question: "What does 'break' do?",
        options: ["Exits loop", "Restarts loop", "Skips iteration", "None"],
        answer: 0,
      ),
    ],
  ),
];
