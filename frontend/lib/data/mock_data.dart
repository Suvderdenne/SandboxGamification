import '../models/lesson.dart';
import '../models/quiz_question.dart';

final mockLessons = [
  Lesson(
    id: "python-intro",
    title: "Introduction to Python",
    category: "Python Basics",
    description: "Learn the basics of Python programming language.",
    content: """
Python is a popular programming language known for its simplicity and readability.
You can use it for web development, data analysis, and much more.
""",
    quiz: [
      QuizQuestion(
        question: "What is the correct file extension for Python files?",
        options: [".pyth", ".pt", ".pyt", ".py"],
        answer: 3,
      ),
      QuizQuestion(
        question: "How do you print something in Python?",
        options: ["print()", "echo()", "say()", "printf()"],
        answer: 0,
      ),
    ],
  ),
  Lesson(
    id: "python-variables",
    title: "Python Variables",
    category: "Python Basics",
    description: "Learn how to declare and use variables in Python.",
    content: """
Variables in Python are created when you assign a value to them:

x = 10
name = "Alice"

You don't need to declare variable types in Python.
""",
    quiz: [
      QuizQuestion(
        question: "Which of the following is a valid variable name?",
        options: ["2name", "my_name", "my-name", "class"],
        answer: 1,
      ),
      QuizQuestion(
        question: "Which keyword is used to declare a variable in Python?",
        options: ["var", "let", "const", "None of the above"],
        answer: 3,
      ),
    ],
  ),
  Lesson(
    id: "python-zzzz",
    title: "Python Variableszzzzz",
    category: "Python Basics",
    description: "Learn how to declare and use variables in Python.",
    content: """
Variables in Python are created when you assign a value to them:

x = 10
name = "Alice"

You don't need to declare variable types in Python.
""",
    quiz: [
      QuizQuestion(
        question: "Which of the following is a valid variable name?",
        options: ["2name", "my_name", "my-name", "class"],
        answer: 1,
      ),
      QuizQuestion(
        question: "Which keyword is used to declare a variable in Python?",
        options: ["var", "let", "const", "None of the above"],
        answer: 3,
      ),
    ],
  ),
];
