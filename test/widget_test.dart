import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:scooter_driver_license_quiz/l10n/app_localizations.dart';
import 'package:scooter_driver_license_quiz/main.dart';
import 'package:scooter_driver_license_quiz/models/question.dart';
import 'package:scooter_driver_license_quiz/utils/database_helper.dart';

void main() {
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  setUp(() async {
    await DatabaseHelper.instance.closeDatabase();
    final db = await databaseFactoryFfi.openDatabase(
      inMemoryDatabasePath,
      options: OpenDatabaseOptions(
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
      ),
    );
    DatabaseHelper.instance.setDatabase(db);
  });

  tearDown(() async {
    await DatabaseHelper.instance.closeDatabase();
  });

  testWidgets(
    'SelectionPage does not show review button when no wrong questions exist',
    (WidgetTester tester) async {
      await tester.runAsync(() async {
        await tester.pumpWidget(
          MaterialApp(
            locale: const Locale('zh'),
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: SelectionPage(
              currentLocale: const Locale('zh'),
              onLocaleChanged: (_) {},
            ),
          ),
        );
        await Future.delayed(const Duration(milliseconds: 100));
      });
      await tester.pump();

      expect(find.byKey(const Key('start_quiz_button')), findsOneWidget);
      expect(find.byKey(const Key('review_button')), findsNothing);
    },
  );

  testWidgets(
    'SelectionPage shows review button when wrong questions exist in DB',
    (WidgetTester tester) async {
      final sampleQ = Question(
        num: '1',
        answer: 'O',
        text: 'Test question',
        type: QuestionType.yesNo,
      );

      await tester.runAsync(() async {
        await DatabaseHelper.instance.saveWrongQuestions(
          [sampleQ],
          vehicle: 'motorcycle',
          lang: 'zh',
          userAnswers: {sampleQ: 'X'},
        );

        await tester.pumpWidget(
          MaterialApp(
            locale: const Locale('zh'),
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: SelectionPage(
              currentLocale: const Locale('zh'),
              onLocaleChanged: (_) {},
            ),
          ),
        );
        await Future.delayed(const Duration(milliseconds: 100));
      });
      await tester.pump();

      expect(find.byKey(const Key('review_button')), findsOneWidget);
    },
  );

  testWidgets(
    'Pressing Enter key or Start Quiz button in SelectionPage navigates to QuizPage',
    (WidgetTester tester) async {
      await tester.runAsync(() async {
        await tester.pumpWidget(
          const DriverLicenseQuizApp(initialLocale: Locale('zh')),
        );
        await Future.delayed(const Duration(milliseconds: 100));
      });
      await tester.pump();

      expect(find.byType(SelectionPage), findsOneWidget);

      // Tap start quiz button
      final startButton = find.byKey(const Key('start_quiz_button'));
      expect(startButton, findsOneWidget);
      await tester.ensureVisible(startButton);
      await tester.pumpAndSettle();

      await tester.runAsync(() async {
        await tester.tap(startButton);
        await tester.pump();
        await Future.delayed(const Duration(milliseconds: 500));
      });
      await tester.pump();

      expect(find.byType(QuizPage), findsOneWidget);
    },
  );

  testWidgets('ReviewPage renders wrong questions and allows clearing them', (
    WidgetTester tester,
  ) async {
    final wrongQ = Question(
      num: '5',
      answer: '2',
      text: 'Sample wrong question in DB',
      options: {'1': 'Opt 1', '2': 'Opt 2', '3': 'Opt 3'},
      type: QuestionType.multipleChoice,
    );

    await tester.runAsync(() async {
      await DatabaseHelper.instance.saveWrongQuestions(
        [wrongQ],
        vehicle: 'motorcycle',
        lang: 'zh',
        userAnswers: {wrongQ: '1'},
      );

      await tester.pumpWidget(
        MaterialApp(
          locale: const Locale('zh'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const ReviewPage(),
        ),
      );
      await Future.delayed(const Duration(milliseconds: 100));
    });
    await tester.pump();

    expect(find.textContaining('Sample wrong question in DB'), findsOneWidget);
    expect(find.textContaining('您的錯誤答案：1'), findsOneWidget);
    expect(find.textContaining('正確！答案：2'), findsOneWidget);

    // Clear wrong questions
    final deleteIcon = find.byIcon(Icons.delete_outline);
    expect(deleteIcon, findsOneWidget);

    await tester.runAsync(() async {
      await tester.tap(deleteIcon);
      await tester.pump();
      await Future.delayed(const Duration(milliseconds: 100));
    });
    await tester.pump();

    // Confirm dialog
    final clearConfirmBtn = find.text('清除錯題紀錄');
    expect(clearConfirmBtn, findsWidgets);

    await tester.runAsync(() async {
      await tester.tap(clearConfirmBtn.last);
      await tester.pump();
      await Future.delayed(const Duration(milliseconds: 200));
    });
    await tester.pump();

    // Verify empty state
    expect(find.text('尚無錯題紀錄。'), findsOneWidget);
  });
}
