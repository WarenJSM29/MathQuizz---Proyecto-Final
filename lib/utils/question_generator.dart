import 'dart:math';
import '../models/question.dart';

class QuestionGenerator {
  final Random _random = Random();

  List<Question> generateQuiz(int total) {
    return List.generate(total, (_) => _generateQuestion());
  }

  Question _generateQuestion() {
    final operators = ['+', '-', '×', '÷'];
    final op = operators[_random.nextInt(operators.length)];

    int a, b, result;

    switch (op) {
      case '+':
        a = _random.nextInt(30) + 1;
        b = _random.nextInt(30) + 1;
        result = a + b;
        break;
      case '-':
        a = _random.nextInt(30) + 10;
        b = _random.nextInt(a); // para evitar negativos
        result = a - b;
        break;
      case '×':
        a = _random.nextInt(10) + 1;
        b = _random.nextInt(10) + 1;
        result = a * b;
        break;
      case '÷':
        b = _random.nextInt(11) + 1;
        result = _random.nextInt(12) + 1;
        a = b * result;
        break;
      default:
        a = b = result = 0;
    }

    final questionText = '¿Cuánto es $a $op $b?';
    final correctIndex = _random.nextInt(4);
    final correctLabel = ['A', 'B', 'C', 'D'][correctIndex];
    final options = <String, String>{};

    for (int i = 0; i < 4; i++) {
      String label = ['A', 'B', 'C', 'D'][i];
      if (i == correctIndex) {
        options[label] = result.toString();
      } else {
        int fake;
        do {
          fake = result + _random.nextInt(9) - 4;
        } while (fake == result || fake < 0 || options.containsValue(fake.toString()));
        options[label] = fake.toString();
      }
    }

    return Question(
      question: questionText,
      optionA: options['A']!,
      optionB: options['B']!,
      optionC: options['C']!,
      optionD: options['D']!,
      correctOption: correctLabel,
    );
  }
}
