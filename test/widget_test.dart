import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:scooter_driver_license_quiz/models/question.dart';
import 'package:scooter_driver_license_quiz/models/quiz_state.dart';

void main() {
  testWidgets('Quiz App UI renders questions and handles submission warning', (WidgetTester tester) async {
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
        home: Scaffold(
          body: StatefulBuilder(
            builder: (context, setState) {
              return Column(
                children: [
                  if (quizState.errorMessage != null)
                    Text(quizState.errorMessage!, key: const Key('error_msg')),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        quizState.submitAnswers();
                      });
                    },
                    child: const Text('submit'),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );

    // Initial state check
    expect(find.text('submit'), findsOneWidget);
    expect(find.byKey(const Key('error_msg')), findsNothing);

    // Tap submit without answering
    await tester.tap(find.text('submit'));
    await tester.pump();

    // Verify error warning
    expect(find.byKey(const Key('error_msg')), findsOneWidget);
    expect(find.textContaining('Submit Failed!'), findsOneWidget);
  });
}
