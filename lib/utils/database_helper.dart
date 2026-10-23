import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import '../models/question.dart';
import '../models/wrong_question_record.dart';

class DatabaseHelper {
  static DatabaseHelper instance = DatabaseHelper._internal();

  DatabaseHelper._internal();

  Database? _db;

  /// Allows setting an existing database instance (useful for unit/widget tests).
  void setDatabase(Database? db) {
    _db = db;
  }

  Future<Database> get database async {
    if (_db != null && _db!.isOpen) return _db!;
    _db = await _initDatabase();
    return _db!;
  }

  Future<Database> _initDatabase({String? customPath}) async {
    if (!kIsWeb &&
        (Platform.isLinux || Platform.isWindows || Platform.isMacOS)) {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    }

    final dbPath =
        customPath ?? join(await getDatabasesPath(), 'scooter_driver_quiz.db');

    return await openDatabase(dbPath, version: 1, onCreate: _onCreate);
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE wrong_questions (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        vehicle TEXT,
        lang TEXT,
        num TEXT,
        answer TEXT,
        raw_answer TEXT,
        page INTEGER,
        architecture TEXT,
        text TEXT,
        options TEXT,
        images TEXT,
        type TEXT,
        user_answer TEXT,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        UNIQUE(vehicle, lang, num) ON CONFLICT REPLACE
      )
    ''');
  }

  Future<void> saveWrongQuestions(
    List<Question> questions, {
    required String vehicle,
    required String lang,
    Map<Question, String>? userAnswers,
  }) async {
    if (questions.isEmpty) return;
    final db = await database;
    final batch = db.batch();

    for (var q in questions) {
      final uAns = userAnswers?[q];
      batch.insert(
        'wrong_questions',
        q.toDbMap(vehicle: vehicle, lang: lang, userAnswer: uAns),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }

    await batch.commit(noResult: true);
  }

  Future<int> getWrongQuestionCount() async {
    final db = await database;
    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM wrong_questions',
    );
    if (result.isNotEmpty) {
      final val = result.first['count'];
      if (val is int) return val;
      if (val != null) return int.tryParse(val.toString()) ?? 0;
    }
    return 0;
  }

  Future<List<WrongQuestionRecord>> getWrongQuestions() async {
    final db = await database;
    final maps = await db.query('wrong_questions', orderBy: 'id DESC');
    return maps.map((map) => WrongQuestionRecord.fromDbMap(map)).toList();
  }

  Future<void> clearWrongQuestions() async {
    final db = await database;
    await db.delete('wrong_questions');
  }

  Future<void> closeDatabase() async {
    if (_db != null && _db!.isOpen) {
      await _db!.close();
      _db = null;
    }
  }
}
