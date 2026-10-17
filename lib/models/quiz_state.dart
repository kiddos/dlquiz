import 'dart:math';
import '../l10n/app_localizations.dart';
import '../models/question.dart';

class QuizState {
  final List<Question> section1Questions;
  final List<Question> section2Questions;

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

  factory QuizState.generateFromQuestions(List<Question> allQuestions, {Random? random}) {
    final rng = random ?? Random();
    final list = List<Question>.from(allQuestions)..shuffle(rng);
    final count = min(20, list.length);
    final selected = list.take(count).toList();
    final half = (count / 2).ceil();

    final sec1 = selected.sublist(0, half);
    final sec2 = selected.sublist(half);

    for (int i = 0; i < sec1.length; i++) {
      sec1[i].assignedIndex = i + 1;
    }
    for (int i = 0; i < sec2.length; i++) {
      sec2[i].assignedIndex = i + 1;
    }

    return QuizState(
      section1Questions: sec1,
      section2Questions: sec2,
    );
  }

  factory QuizState.generateQuiz(List<Question> allYesNo, List<Question> allMultiple, {Random? random}) {
    if (allYesNo.isNotEmpty && allMultiple.isNotEmpty) {
      final rng = random ?? Random();

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
        section1Questions: selectRandom(allYesNo, min(10, allYesNo.length)),
        section2Questions: selectRandom(allMultiple, min(10, allMultiple.length)),
      );
    } else {
      final combined = [...allYesNo, ...allMultiple];
      return QuizState.generateFromQuestions(combined, random: random);
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

  bool submitAnswers([AppLocalizations? l10n]) {
    int status1 = checkSectionDone(1);
    int status2 = checkSectionDone(2);

    if (status1 != 0) {
      errorMessage = l10n != null
          ? l10n.submitFailedSection1(status1)
          : "Submit Failed! [Section 1] Question $status1 is not answered";
      isSubmitted = false;
      return false;
    }

    if (status2 != 0) {
      errorMessage = l10n != null
          ? l10n.submitFailedSection2(status2)
          : "Submit Failed! [Section 2] Question $status2 is not answered";
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
