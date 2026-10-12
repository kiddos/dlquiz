import 'package:flutter_test/flutter_test.dart';
import 'package:scooter_driver_license_quiz/models/question.dart';
import 'package:scooter_driver_license_quiz/utils/question_parser.dart';
import 'package:scooter_driver_license_quiz/models/quiz_state.dart';

void main() {
  group('QuestionParser tests', () {
    test('Parses yes/no raw text correctly', () {
      const sample = '''
001 O 超速行駛是肇事最大原因之一。 11
002 X 睡眠不足神志不清，只要小心駕駛仍然可以開車。 11
009 X
夜間行車，如來車不變換近光燈，可以用遠光燈來報復增加
安全。 11
''';
      final questions = QuestionParser.parseQuestions(sample, QuestionType.yesNo);
      expect(questions.length, 3);
      expect(questions[0].num, '001');
      expect(questions[0].answer, 'O');
      expect(questions[0].text, '超速行駛是肇事最大原因之一。');

      expect(questions[1].num, '002');
      expect(questions[1].answer, 'X');
      expect(questions[1].text, '睡眠不足神志不清，只要小心駕駛仍然可以開車。');

      expect(questions[2].num, '009');
      expect(questions[2].answer, 'X');
      expect(questions[2].text, '夜間行車，如來車不變換近光燈，可以用遠光燈來報復增加安全。');
    });

    test('Parses multiple choice raw text correctly', () {
      const sample = '''
001 3 為了趕時間，(1)可以超速行駛(2)不必遵守交通規則(3)仍要依
規定駕駛。
11
002 1 防衛駕駛就是(1)能儘力採取合理謹慎行為加以防止車禍發生
(2)優良駕駛技術(3)良好生活習慣。
11
''';
      final questions = QuestionParser.parseQuestions(sample, QuestionType.multipleChoice);
      expect(questions.length, 2);
      expect(questions[0].num, '001');
      expect(questions[0].answer, '3');
      expect(questions[0].text, '為了趕時間，(1)可以超速行駛(2)不必遵守交通規則(3)仍要依規定駕駛。');

      expect(questions[1].num, '002');
      expect(questions[1].answer, '1');
      expect(questions[1].text, '防衛駕駛就是(1)能儘力採取合理謹慎行為加以防止車禍發生(2)優良駕駛技術(3)良好生活習慣。');
    });
  });

  group('QuizState tests', () {
    test('Handles uncompleted questions and calculates scores correctly', () {
      final yesNoList = List.generate(
        15,
        (i) => Question(num: '${i + 1}', answer: 'O', text: 'Q${i + 1}', type: QuestionType.yesNo),
      );
      final multipleList = List.generate(
        15,
        (i) => Question(num: '${i + 1}', answer: '1', text: 'MQ${i + 1}', type: QuestionType.multipleChoice),
      );

      final state = QuizState.generateQuiz(yesNoList, multipleList);
      expect(state.section1Questions.length, 10);
      expect(state.section2Questions.length, 10);

      // Attempt submit without answers
      bool success = state.submitAnswers();
      expect(success, false);
      expect(state.errorMessage, contains('[Section 1] Question 1 is not answered'));

      // Fill section 1 answers
      for (int i = 1; i <= 10; i++) {
        state.section1UserAnswers[i] = 'O';
      }

      success = state.submitAnswers();
      expect(success, false);
      expect(state.errorMessage, contains('[Section 2] Question 1 is not answered'));

      // Fill section 2 answers (8 correct, 2 wrong)
      for (int i = 1; i <= 8; i++) {
        state.section2UserAnswers[i] = '1';
      }
      state.section2UserAnswers[9] = '2';
      state.section2UserAnswers[10] = '2';

      success = state.submitAnswers();
      expect(success, true);
      expect(state.errorMessage, isNull);
      expect(state.totalCorrect, 18); // 10 + 8
      expect(state.totalQuestions, 20);
      expect(state.isPassed, true); // 18/20 = 90% >= 80%
    });
  });
}
