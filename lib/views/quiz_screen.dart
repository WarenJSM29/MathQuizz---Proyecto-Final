import 'dart:async';
import 'package:flutter/material.dart';
import '../models/question.dart';
import '../utils/question_generator.dart';

class QuizScreen extends StatefulWidget {
  const QuizScreen({super.key});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  final _generator = QuestionGenerator();
  List<Question> _questions = [];
  int _currentIndex = 0;
  int _score = 0;
  bool _quizFinished = false;

  int _secondsLeft = 10;
  Timer? _timer;
  Timer? _delayTimer;

  bool _answered = false;
  String? _selectedOption;

  int _nextSecondsLeft = 5;

  @override
  void initState() {
    super.initState();
    _generateQuestions();
  }

  void _generateQuestions() {
    _questions = _generator.generateQuiz(15);
    _currentIndex = 0;
    _score = 0;
    _quizFinished = false;
    _answered = false;
    _selectedOption = null;
    _startTimer();
  }

  void _startTimer() {
    _secondsLeft = 10;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsLeft == 0) {
        timer.cancel();
        _handleTimeout();
      } else {
        setState(() {
          _secondsLeft--;
        });
      }
    });
  }

  void _handleTimeout() {
    setState(() {
      _answered = true;
      _selectedOption = null;
    });

    _delayTimer = Timer(const Duration(seconds: 5), _goToNextQuestion);
  }

  void checkAnswer(String selectedOption) {
    if (_answered) return;

    _timer?.cancel();
    final current = _questions[_currentIndex];

    setState(() {
      _answered = true;
      _selectedOption = selectedOption;
      _nextSecondsLeft = 5;
    });

    _delayTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_nextSecondsLeft == 1) {
        timer.cancel();
        _goToNextQuestion();
      } else {
        setState(() {
          _nextSecondsLeft--;
        });
      }
    });
  }

  void _goToNextQuestion() {
    setState(() {
      if (_currentIndex < _questions.length - 1) {
        _currentIndex++;
        _answered = false;
        _selectedOption = null;
        _nextSecondsLeft = 5;
        _startTimer();
      } else {
        _quizFinished = true;
      }
    });
  }

  void restartQuiz() {
    _timer?.cancel();
    _delayTimer?.cancel();
    _generateQuestions();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _delayTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_questions.isEmpty) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (_quizFinished) {
      return Scaffold(
        appBar: AppBar(title: const Text('Resultados')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                '¡Has terminado el quiz!',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              Text(
                'Puntaje: $_score de ${_questions.length}',
                style: const TextStyle(fontSize: 20),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: restartQuiz,
                child: const Text('Reiniciar'),
              ),
            ],
          ),
        ),
      );
    }

    final question = _questions[_currentIndex];

    return Scaffold(
      appBar: AppBar(title: const Text('Quiz de Matemáticas')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Pregunta ${_currentIndex + 1}/${_questions.length}',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 10),

            Text(
              'Tiempo restante: $_secondsLeft s',
              style: const TextStyle(fontSize: 16, color: Colors.red),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 5),

            LinearProgressIndicator(
              value: _secondsLeft / 10,
              color: Colors.red,
              backgroundColor: Colors.grey[300],
              minHeight: 10,
            ),
            const SizedBox(height: 30),

            Text(
              question.question,
              style: const TextStyle(fontSize: 22),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 30),

            ...['A', 'B', 'C', 'D'].map((label) {
              String text = {
                'A': question.optionA,
                'B': question.optionB,
                'C': question.optionC,
                'D': question.optionD,
              }[label]!;

              Color? color;
              if (_answered) {
                if (label == question.correctOption) {
                  color = Colors.green;
                } else if (label == _selectedOption) {
                  color = Colors.red;
                }
              }

              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: ElevatedButton(
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.resolveWith<Color?>((states) {
                      if (_answered) {
                        if (label == question.correctOption) return Colors.green;
                        if (label == _selectedOption) return Colors.red;
                      }
                      return null; // usa color por defecto
                    }),
                    minimumSize: MaterialStateProperty.all(const Size(double.infinity, 50)),
                  ),
                  onPressed: _answered ? null : () => checkAnswer(label),
                  child: Text('$label. $text', style: const TextStyle(fontSize: 18)),
                ),
              );
            }).toList(),

            if (_answered) ...[
              const SizedBox(height: 20),
              Text(
                'Siguiente pregunta en: $_nextSecondsLeft s',
                style: const TextStyle(fontSize: 16, color: Colors.grey),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              Center(
                child: ElevatedButton.icon(
                  onPressed: () {
                    _delayTimer?.cancel();
                    _goToNextQuestion();
                  },
                  icon: const Icon(Icons.skip_next),
                  label: const Text('Siguiente'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
