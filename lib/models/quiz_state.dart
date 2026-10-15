import 'dart:math';
import '../models/question.dart';

class QuizState {
  final List<Question> section1Questions; // 10 yes/no questions
  final List<Question> section2Questions; // 10 multiple choice questions

  // Maps assigned question index (1-based) to user selected answer
  final Map<int, String> section1UserAnswers = {};
  final Map<int, String> section2UserAnswers = {};

  bool isSubmitted = false;
  String? errorMessage;
  int section1Correct = 0;
  int section2Correct = 0;

  QuizState({
    required this.section1Questions,
    required this.section2Questions,
  });

  factory QuizState.generateQuiz(List<Question> allQuestions, [List<Question>? allMultiple, Random? random]) {
    final rng = random ?? Random();

    if (allMultiple != null) {
      List<Question> selectRandom(List<Question> source, int count) {
        final list = List<Question>.from(source);
        list.shuffle(rng);
        final selected = list.take(count).toList();
        for (int i = 0; i < selected.length; i++) {
          selected[i].assignedIndex = i + 1;
        }
        return selected;
      }

      return QuizState(
        section1Questions: selectRandom(allQuestions, 10),
        section2Questions: selectRandom(allMultiple, 10),
      );
    } else {
      final list = List<Question>.from(allQuestions);
      list.shuffle(rng);
      final count1 = list.length >= 10 ? 10 : list.length ~/ 2;
      final selected1 = list.take(count1).toList();
      for (int i = 0; i < selected1.length; i++) {
        selected1[i].assignedIndex = i + 1;
      }
      final count2 = (list.length - count1) >= 10 ? 10 : (list.length - count1);
      final selected2 = list.skip(count1).take(count2).toList();
      for (int i = 0; i < selected2.length; i++) {
        selected2[i].assignedIndex = i + 1;
      }
      return QuizState(
        section1Questions: selected1,
        section2Questions: selected2,
      );
    }
  }

  /// Returns 0 if all answered in section, or index of first unanswered question (1-based).
  int checkSectionDone(int section) {
    final questions = section == 1 ? section1Questions : section2Questions;
    final userAnswers = section == 1 ? section1UserAnswers : section2UserAnswers;

    for (int i = 0; i < questions.length; i++) {
      int qNum = i + 1;
      if (!userAnswers.containsKey(qNum) || userAnswers[qNum] == null || userAnswers[qNum]!.isEmpty) {
        return qNum;
      }
    }
    return 0;
  }

  bool submitAnswers() {
    int status1 = checkSectionDone(1);
    int status2 = checkSectionDone(2);

    if (status1 != 0) {
      errorMessage = "Submit Failed! [Section 1] Question $status1 is not answered";
      isSubmitted = false;
      return false;
    }

    if (status2 != 0) {
      errorMessage = "Submit Failed! [Section 2] Question $status2 is not answered";
      isSubmitted = false;
      return false;
    }

    errorMessage = null;
    isSubmitted = true;

    // Calculate score
    section1Correct = 0;
    for (int i = 0; i < section1Questions.length; i++) {
      int qNum = i + 1;
      if (section1UserAnswers[qNum] == section1Questions[i].answer) {
        section1Correct++;
      }
    }

    section2Correct = 0;
    for (int i = 0; i < section2Questions.length; i++) {
      int qNum = i + 1;
      if (section2UserAnswers[qNum] == section2Questions[i].answer) {
        section2Correct++;
      }
    }

    return true;
  }

  int get totalCorrect => section1Correct + section2Correct;
  int get totalQuestions => section1Questions.length + section2Questions.length;
  double get scorePercentage => totalQuestions > 0 ? (totalCorrect / totalQuestions) : 0.0;
  bool get isPassed => scorePercentage >= 0.80;
}
