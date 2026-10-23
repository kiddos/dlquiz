import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:scooter_driver_license_quiz/l10n/app_localizations.dart';
import 'package:scooter_driver_license_quiz/pages/quiz_page.dart';
import 'package:scooter_driver_license_quiz/pages/review_page.dart';
import 'package:scooter_driver_license_quiz/pages/selection_page.dart';
import 'package:scooter_driver_license_quiz/utils/database_helper.dart';
import 'package:scooter_driver_license_quiz/widgets/ad_banner.dart';

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

  testWidgets('AdBanner renders properly in traditional Chinese and English', (
    WidgetTester tester,
  ) async {
    // Chinese locale
    await tester.pumpWidget(
      const MaterialApp(
        locale: Locale('zh'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(body: AdBanner()),
      ),
    );
    await tester.pump();

    expect(find.byKey(const Key('ad_banner')), findsOneWidget);
    expect(find.text('廣告'), findsOneWidget);
    expect(find.text('駕照大師 APP - 筆試一次高分過關！'), findsOneWidget);
    expect(find.text('了解更多'), findsOneWidget);

    // Tap CTA button
    await tester.tap(find.text('了解更多'));
    await tester.pump();
    expect(find.text('感謝您支持廣告！'), findsOneWidget);

    // English locale
    await tester.pumpWidget(
      const MaterialApp(
        locale: Locale('en'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(body: AdBanner()),
      ),
    );
    await tester.pump();

    expect(find.byKey(const Key('ad_banner')), findsOneWidget);
    expect(find.text('AD'), findsOneWidget);
    expect(
      find.text('Driver Master App - Ace Your License Exam!'),
      findsOneWidget,
    );
    expect(find.text('Learn More'), findsOneWidget);
  });

  testWidgets('AdBanner is displayed on SelectionPage', (
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

    expect(find.byKey(const Key('ad_banner')), findsOneWidget);
  });

  testWidgets('AdBanner is displayed on QuizPage', (WidgetTester tester) async {
    await tester.runAsync(() async {
      await tester.pumpWidget(
        const MaterialApp(
          locale: Locale('zh'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: QuizPage(selectedVehicle: 'motorcycle', selectedLang: 'zh'),
        ),
      );
      await Future.delayed(const Duration(milliseconds: 100));
    });
    await tester.pump();

    expect(find.byKey(const Key('ad_banner')), findsOneWidget);
  });

  testWidgets('AdBanner is displayed on ReviewPage', (
    WidgetTester tester,
  ) async {
    await tester.runAsync(() async {
      await tester.pumpWidget(
        const MaterialApp(
          locale: Locale('zh'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: ReviewPage(),
        ),
      );
      await Future.delayed(const Duration(milliseconds: 100));
    });
    await tester.pump();

    expect(find.byKey(const Key('ad_banner')), findsOneWidget);
  });
}
