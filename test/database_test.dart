import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:scooter_driver_license_quiz/models/question.dart';
import 'package:scooter_driver_license_quiz/utils/database_helper.dart';

void main() {
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  setUp(() async {
    // Reset database helper with a fresh in-memory database
    await DatabaseHelper.instance.closeDatabase();
    final db = await openDatabase(
      inMemoryDatabasePath,
      version: 1,
      onCreate: (db, version) async {
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
      },
    );
    DatabaseHelper.instance.setDatabase(db);
  });

  tearDown(() async {
    await DatabaseHelper.instance.closeDatabase();
  });

  group('DatabaseHelper tests', () {
    test('Initial wrong questions count is 0', () async {
      final count = await DatabaseHelper.instance.getWrongQuestionCount();
      expect(count, equals(0));
      final records = await DatabaseHelper.instance.getWrongQuestions();
      expect(records, isEmpty);
    });

    test('Saves wrong questions and retrieves them correctly', () async {
      final q1 = Question(
        num: '1',
        answer: '2',
        rawAnswer: '(2)',
        page: 1,
        architecture: 'Arch 1',
        text: 'Sample question 1',
        options: {'1': 'Opt A', '2': 'Opt B', '3': 'Opt C'},
        images: ['images/1.png'],
        type: QuestionType.multipleChoice,
      );

      final q2 = Question(
        num: '2',
        answer: 'O',
        text: 'Sample yes/no question',
        type: QuestionType.yesNo,
      );

      await DatabaseHelper.instance.saveWrongQuestions(
        [q1, q2],
        vehicle: 'car',
        lang: 'zh',
        userAnswers: {q1: '1', q2: 'X'},
      );

      final count = await DatabaseHelper.instance.getWrongQuestionCount();
      expect(count, equals(2));

      final records = await DatabaseHelper.instance.getWrongQuestions();
      expect(records.length, equals(2));

      final rec1 = records.firstWhere((r) => r.question.num == '1');
      expect(rec1.vehicle, equals('car'));
      expect(rec1.lang, equals('zh'));
      expect(rec1.userAnswer, equals('1'));
      expect(rec1.question.answer, equals('2'));
      expect(rec1.question.text, equals('Sample question 1'));
      expect(rec1.question.options?['1'], equals('Opt A'));
      expect(rec1.question.images, equals(['images/1.png']));

      final rec2 = records.firstWhere((r) => r.question.num == '2');
      expect(rec2.userAnswer, equals('X'));
      expect(rec2.question.type, equals(QuestionType.yesNo));
    });

    test('Clears wrong questions successfully', () async {
      final q1 = Question(
        num: '10',
        answer: '1',
        text: 'Sample question 10',
        type: QuestionType.multipleChoice,
      );

      await DatabaseHelper.instance.saveWrongQuestions(
        [q1],
        vehicle: 'motorcycle',
        lang: 'en',
        userAnswers: {q1: '3'},
      );

      expect(await DatabaseHelper.instance.getWrongQuestionCount(), equals(1));

      await DatabaseHelper.instance.clearWrongQuestions();

      expect(await DatabaseHelper.instance.getWrongQuestionCount(), equals(0));
      expect(await DatabaseHelper.instance.getWrongQuestions(), isEmpty);
    });
  });
}
