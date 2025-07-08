import 'package:flutter/material.dart';
import 'quiz_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> quizzes = [
      {
        'title': 'Quiz de Matemáticas',
        'subtitle': 'Suma, resta, multiplicación y división',
        'icon': Icons.calculate,
        'screen': const QuizScreen(),
        'color': Colors.indigo,
      },
      // Puedes agregar más quizzes aquí
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Quizzes Educativos'),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: quizzes.length,
        itemBuilder: (context, index) {
          final quiz = quizzes[index];
          final String title = quiz['title'] as String;
          final String subtitle = quiz['subtitle'] as String;
          final IconData icon = quiz['icon'] as IconData;
          final Widget screen = quiz['screen'] as Widget;
          final Color color = quiz['color'] as Color;

          return Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            margin: const EdgeInsets.only(bottom: 16),
            color: color.withOpacity(0.1),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              leading: CircleAvatar(
                backgroundColor: color,
                child: Icon(icon, color: Colors.white),
              ),
              title: Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              subtitle: Text(subtitle),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => screen),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
