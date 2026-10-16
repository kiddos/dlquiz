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

    test('Parses v2 JSON question format with options and images correctly', () {
      const sampleJson = '''
[
  {
    "num": 1,
    "answer": "2",
    "raw_answer": "(2)",
    "page": 1,
    "architecture": "架構一 正確觀念與態度",
    "text": "(2) （１）禁止任何車輛進入。（２）禁止四輪以上汽車及機車進入。（３）禁止 行人通行。",
    "options": {
      "2": "禁止四輪以上汽車及機車進入。",
      "1": "禁止任何車輛進入。",
      "3": "禁止 行人通行。"
    },
    "images": [
      "images/1.png"
    ]
  },
  {
    "num": 4,
    "answer": "3",
    "raw_answer": "(3)",
    "page": 1,
    "architecture": "架構一 正確觀念與態度",
    "text": "(3) 當開車進入...",
    "options": {
      "3": "提早變換...",
      "1": "在施工...",
      "2": "開啟駕駛..."
    },
    "images": []
  }
]
''';

      final questions = QuestionParser.parseJsonQuestions(
        sampleJson,
        assetPrefix: 'questions/v2/car/zh',
      );

      expect(questions.length, 2);
      expect(questions[0].num, '1');
      expect(questions[0].answer, '2');
      expect(questions[0].rawAnswer, '(2)');
      expect(questions[0].page, 1);
      expect(questions[0].architecture, '架構一 正確觀念與態度');
      expect(questions[0].options?['2'], '禁止四輪以上汽車及機車進入。');
      expect(questions[0].images, ['questions/v2/car/zh/images/1.png']);

      expect(questions[1].num, '4');
      expect(questions[1].answer, '3');
      expect(questions[1].images, isEmpty);
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

    test('Generates quiz from single list of json questions', () {
      final questions = List.generate(
        25,
        (i) => Question(
          num: '${i + 1}',
          answer: '2',
          text: 'Question ${i + 1}',
          options: {'1': 'A', '2': 'B', '3': 'C'},
          images: i % 2 == 0 ? ['questions/v2/car/zh/images/${i + 1}.png'] : [],
        ),
      );

      final state = QuizState.generateFromQuestions(questions);
      expect(state.section1Questions.length, 10);
      expect(state.section2Questions.length, 10);
      expect(state.totalQuestions, 20);
    });
  });
}
