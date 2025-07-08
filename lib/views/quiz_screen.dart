import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';

class QuizScreen extends StatefulWidget {
  const QuizScreen({super.key});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  List<Map<String, dynamic>> _questions = [];
  int _currentIndex = 0;
  int _score = 0;
  bool _quizFinished = false;
  bool _answered = false;
  String? _selectedOption;
  int _answerTimeLeft = 10;
  int _nextQuestionTimeLeft = 5;
  Timer? _answerTimer;
  Timer? _nextTimer;

  @override
  void initState() {
    super.initState();
    _generateQuestions();
    _startAnswerTimer();
  }

  void _generateQuestions() {
    final random = Random();
    final ops = ['+', '-', '×', '÷'];
    _questions = List.generate(15, (_) {
      final op = ops[random.nextInt(4)];
      int a = random.nextInt(50) + 1;
      int b = random.nextInt(50) + 1;

      double correct;
      switch (op) {
        case '+':
          correct = (a + b).toDouble();
          break;
        case '-':
          correct = (a - b).toDouble();
          break;
        case '×':
          correct = (a * b).toDouble();
          break;
        case '÷':
          b = random.nextInt(9) + 1;
          a = b * (random.nextInt(10) + 1);
          correct = a / b;
          break;
        default:
          correct = 0;
      }

      final correctStr = correct % 1 == 0 ? correct.toInt().toString() : correct.toStringAsFixed(2);
      final correctIndex = random.nextInt(4);
      final options = List.generate(4, (i) {
        if (i == correctIndex) return correctStr;
        int offset = random.nextInt(5) + 1;
        return (correct + offset * (random.nextBool() ? 1 : -1)).round().toString();
      });

      return {
        'question': '$a $op $b = ?',
        'options': options,
        'correct': correctStr,
      };
    });
  }

  void _startAnswerTimer() {
    _answerTimer?.cancel();
    _answerTimeLeft = 10;

    _answerTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_answerTimeLeft <= 1) {
        timer.cancel();
        _checkAnswer(null); // No respondió
      } else {
        setState(() {
          _answerTimeLeft--;
        });
      }
    });
  }

  void _checkAnswer(String? option) {
    if (_answered) return;

    _answerTimer?.cancel();
    _answered = true;
    _selectedOption = option;

    if (option != null && option == _questions[_currentIndex]['correct']) {
      _score++;
    }

    _nextTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_nextQuestionTimeLeft <= 1) {
        timer.cancel();
        _goToNextQuestion();
      } else {
        setState(() {
          _nextQuestionTimeLeft--;
        });
      }
    });

    setState(() {});
  }

  void _goToNextQuestion() {
    _nextTimer?.cancel();
    setState(() {
      _answered = false;
      _selectedOption = null;
      _nextQuestionTimeLeft = 5;
      _answerTimeLeft = 10;

      if (_currentIndex < _questions.length - 1) {
        _currentIndex++;
        _startAnswerTimer();
      } else {
        _quizFinished = true;
      }
    });
  }

  void _restartQuiz() {
    _answerTimer?.cancel();
    _nextTimer?.cancel();
    setState(() {
      _score = 0;
      _currentIndex = 0;
      _quizFinished = false;
      _answered = false;
      _selectedOption = null;
      _answerTimeLeft = 10;
      _nextQuestionTimeLeft = 5;
      _generateQuestions();
      _startAnswerTimer();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    if (_quizFinished) {
      return Scaffold(
        appBar: AppBar(title: const Text('Resultados')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.emoji_events, size: 80, color: colorScheme.primary),
              const SizedBox(height: 20),
              Text(
                '¡Has terminado!',
                style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Text(
                'Puntaje: $_score de ${_questions.length}',
                style: theme.textTheme.titleMedium,
              ),
              const SizedBox(height: 30),
              ElevatedButton.icon(
                onPressed: _restartQuiz,
                icon: const Icon(Icons.restart_alt),
                label: const Text('Reiniciar Quiz'),
              )
            ],
          ),
        ),
      );
    }

    final current = _questions[_currentIndex];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Quiz de Matemáticas'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Barra de progreso
            LinearProgressIndicator(
              value: (_currentIndex + 1) / _questions.length,
              backgroundColor: theme.dividerColor,
              valueColor: AlwaysStoppedAnimation(colorScheme.primary),
            ),
            const SizedBox(height: 16),
            Text(
              'Pregunta ${_currentIndex + 1} de ${_questions.length}',
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'Tiempo restante: $_answerTimeLeft segundos',
              style: theme.textTheme.bodySmall?.copyWith(color: Colors.orange),
            ),
            const SizedBox(height: 20),
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Text(
                  current['question'],
                  style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            const SizedBox(height: 20),
            ...List.generate(4, (i) {
              final option = current['options'][i];
              Color? bg;

              if (_answered) {
                if (option == current['correct']) {
                  bg = Colors.green;
                } else if (option == _selectedOption) {
                  bg = Colors.red;
                } else {
                  bg = theme.colorScheme.surface;
                }
              }

              return Container(
                margin: const EdgeInsets.symmetric(vertical: 6),
                child: ElevatedButton(
                  onPressed: () {
                    if (!_answered) _checkAnswer(option);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: bg ?? theme.colorScheme.primaryContainer,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: bg ?? theme.disabledColor,
                    disabledForegroundColor: Colors.white,
                  ),
                  child: Text(option, style: const TextStyle(fontSize: 18)),
                ),
              );
            }),
            const Spacer(),
            if (_answered) ...[
              Text(
                'Siguiente pregunta en $_nextQuestionTimeLeft segundos...',
                style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey),
              ),
              const SizedBox(height: 10),
              OutlinedButton.icon(
                onPressed: _goToNextQuestion,
                icon: const Icon(Icons.skip_next),
                label: const Text('Siguiente ahora'),
              ),
            ],
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _answerTimer?.cancel();
    _nextTimer?.cancel();
    super.dispose();
  }
}
