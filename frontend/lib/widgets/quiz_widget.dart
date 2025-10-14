import 'package:flutter/material.dart';
import '../models/quiz_question.dart';

class QuizWidget extends StatefulWidget {
  final List<QuizQuestion> quiz;

  const QuizWidget({super.key, required this.quiz});

  @override
  State<QuizWidget> createState() => _QuizWidgetState();
}

class _QuizWidgetState extends State<QuizWidget> {
  final Map<int, int> _answers = {};
  bool _submitted = false;

  void _submit() {
    setState(() {
      _submitted = true;
    });
    int score = 0;
    for (var i = 0; i < widget.quiz.length; i++) {
      if (_answers[i] == widget.quiz[i].answer) score++;
    }
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Quiz Result"),
        content: Text("Score: $score / ${widget.quiz.length}"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("OK"))
        ],
      ),
    );
  }

  void _reset() {
    setState(() {
      _answers.clear();
      _submitted = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (widget.quiz.isEmpty) {
      return const Text("No quiz available for this lesson.");
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Quiz", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        for (var i = 0; i < widget.quiz.length; i++) ...[
          Text("${i + 1}. ${widget.quiz[i].question}",
              style: const TextStyle(fontWeight: FontWeight.w600)),
          for (var j = 0; j < widget.quiz[i].options.length; j++)
            RadioListTile<int>(
              title: Text(widget.quiz[i].options[j]),
              value: j,
              groupValue: _answers[i],
              onChanged: _submitted
                  ? null
                  : (v) => setState(() => _answers[i] = v!),
              tileColor: _submitted
                  ? (widget.quiz[i].answer == j
                      ? Colors.green.withOpacity(0.1)
                      : (_answers[i] == j ? Colors.red.withOpacity(0.1) : null))
                  : null,
            ),
          const Divider(),
        ],
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(onPressed: _submitted ? _reset : _submit, child: Text(_submitted ? "Reset" : "Submit")),
          ],
        )
      ],
    );
  }
}
