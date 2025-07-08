import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/question.dart';

class QuizDatabase {
  static final QuizDatabase instance = QuizDatabase._init();
  static Database? _database;

  QuizDatabase._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('quiz.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE questions (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        question TEXT,
        optionA TEXT,
        optionB TEXT,
        optionC TEXT,
        optionD TEXT,
        correctOption TEXT
      )
    ''');

    // Insertamos 3 preguntas básicas de matemáticas
    await db.insert('questions', {
      'question': '¿Cuánto es 5 + 3?',
      'optionA': '6',
      'optionB': '7',
      'optionC': '8',
      'optionD': '9',
      'correctOption': 'C',
    });
    await db.insert('questions', {
      'question': '¿Cuánto es 7 x 6?',
      'optionA': '42',
      'optionB': '36',
      'optionC': '48',
      'optionD': '40',
      'correctOption': 'A',
    });
    await db.insert('questions', {
      'question': '¿Cuánto es 100 ÷ 25?',
      'optionA': '2',
      'optionB': '4',
      'optionC': '5',
      'optionD': '10',
      'correctOption': 'C',
    });
  }

  Future<List<Question>> getQuestions() async {
    final db = await instance.database;
    final result = await db.query('questions');
    return result.map((map) => Question.fromMap(map)).toList();
  }

  Future close() async {
    final db = await instance.database;
    db.close();
  }
}