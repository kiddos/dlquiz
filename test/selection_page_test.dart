import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:scooter_driver_license_quiz/l10n/app_localizations.dart';
import 'package:scooter_driver_license_quiz/pages/selection_page.dart';
import 'package:scooter_driver_license_quiz/pages/quiz_page.dart';
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

  testWidgets('SelectionPage allows selecting vehicle and language', (
    WidgetTester tester,
  ) async {
    String selectedLangCode = 'zh';

    await tester.runAsync(() async {
      await tester.pumpWidget(
        MaterialApp(
          locale: const Locale('zh'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: SelectionPage(
            currentLocale: const Locale('zh'),
            onLocaleChanged: (locale) {
              selectedLangCode = locale.languageCode;
            },
          ),
        ),
      );
      await Future.delayed(const Duration(milliseconds: 100));
    });
    await tester.pump();

    expect(find.text('機車'), findsOneWidget);
    expect(find.text('繁體中文'), findsOneWidget);

    // Switch vehicle to car
    final vehicleDropdown = find.byKey(const Key('vehicle_dropdown'));
    await tester.ensureVisible(vehicleDropdown);
    await tester.tap(vehicleDropdown);
    await tester.pumpAndSettle();
    await tester.tap(find.text('汽車').last);
    await tester.pumpAndSettle();

    expect(find.text('汽車'), findsOneWidget);

    // Switch language to English
    final languageDropdown = find.byKey(const Key('language_dropdown'));
    await tester.ensureVisible(languageDropdown);
    await tester.tap(languageDropdown);
    await tester.pumpAndSettle();
    await tester.tap(find.text('English').last);
    await tester.pumpAndSettle();

    expect(selectedLangCode, equals('en'));
  });

  testWidgets('SelectionPage responds to Enter key and opens QuizPage', (
    WidgetTester tester,
  ) async {
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

    expect(find.byType(SelectionPage), findsOneWidget);

    await tester.sendKeyEvent(LogicalKeyboardKey.enter);

    await tester.runAsync(() async {
      await tester.pump();
      await Future.delayed(const Duration(milliseconds: 500));
    });
    await tester.pump();

    expect(find.byType(QuizPage), findsOneWidget);
  });
}
