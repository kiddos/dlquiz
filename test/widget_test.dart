import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:scooter_driver_license_quiz/l10n/app_localizations.dart';
import 'package:scooter_driver_license_quiz/main.dart';
import 'package:scooter_driver_license_quiz/models/question.dart';
import 'package:scooter_driver_license_quiz/models/quiz_state.dart';

void main() {
  testWidgets('Quiz App UI renders questions and handles submission warning (EN & ZH)', (WidgetTester tester) async {
    final yesNoQuestions = List.generate(
      10,
      (i) => Question(num: '00${i + 1}', answer: 'O', text: 'YesNo Question ${i + 1}', type: QuestionType.yesNo),
    );
    final multipleQuestions = List.generate(
      10,
      (i) => Question(num: '00${i + 1}', answer: '1', text: 'Multiple Question ${i + 1}', type: QuestionType.multipleChoice),
    );

    final quizState = QuizState.generateQuiz(yesNoQuestions, multipleQuestions);

    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('en'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: StatefulBuilder(
            builder: (context, setState) {
              final l10n = AppLocalizations.of(context);
              return Column(
                children: [
                  if (quizState.errorMessage != null)
                    Text(quizState.errorMessage!, key: const Key('error_msg')),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        quizState.submitAnswers(l10n);
                      });
                    },
                    child: Text(l10n?.submit ?? 'submit'),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );

    // Initial state check in English
    expect(find.text('submit'), findsOneWidget);
    expect(find.byKey(const Key('error_msg')), findsNothing);

    // Tap submit without answering
    await tester.tap(find.text('submit'));
    await tester.pump();

    // Verify English error warning
    expect(find.byKey(const Key('error_msg')), findsOneWidget);
    expect(find.textContaining('Submit Failed!'), findsOneWidget);

    // Test in Traditional Chinese
    final quizStateZh = QuizState.generateQuiz(yesNoQuestions, multipleQuestions);
    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('zh'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: StatefulBuilder(
            builder: (context, setState) {
              final l10n = AppLocalizations.of(context);
              return Column(
                children: [
                  if (quizStateZh.errorMessage != null)
                    Text(quizStateZh.errorMessage!, key: const Key('error_msg')),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        quizStateZh.submitAnswers(l10n);
                      });
                    },
                    child: Text(l10n?.submit ?? 'submit'),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );

    expect(find.text('提交'), findsOneWidget);
    await tester.tap(find.text('提交'));
    await tester.pump();

    expect(find.byKey(const Key('error_msg')), findsOneWidget);
    expect(find.textContaining('提交失敗！'), findsOneWidget);
  });

  testWidgets('DriverLicenseQuizApp loads and supports language switching', (WidgetTester tester) async {
    await tester.pumpWidget(
      const DriverLicenseQuizApp(
        initialLocale: Locale('zh'),
      ),
    );
    await tester.runAsync(() async {
      await Future.delayed(const Duration(milliseconds: 500));
    });
    await tester.pump();

    // Check initial Chinese titles
    expect(find.text('駕駛執照測驗'), findsWidgets);
    expect(find.text('繁體中文'), findsOneWidget);

    // Switch to English dropdown
    await tester.tap(find.text('繁體中文'));
    await tester.pump();

    await tester.tap(find.text('English').last);
    await tester.runAsync(() async {
      await Future.delayed(const Duration(milliseconds: 500));
    });
    await tester.pump();

    // Check English titles after language switch
    expect(find.text('Driver License Quiz'), findsWidgets);
  });
}
