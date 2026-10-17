// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Driver License Quiz';

  @override
  String get appSubtitle => 'Driver\'s License Written Test Question Bank';

  @override
  String get vehicleLabel => 'Vehicle: ';

  @override
  String get vehicleMotorcycle => 'Motorcycle';

  @override
  String get vehicleCar => 'Car';

  @override
  String get languageLabel => 'Language: ';

  @override
  String get languageChinese => 'Traditional Chinese';

  @override
  String get languageEnglish => 'English';

  @override
  String get restartQuiz => 'Restart Quiz';

  @override
  String get restart => 'Restart';

  @override
  String get retry => 'Retry';

  @override
  String get section1Title => 'Section 1: Questions 1 - 10';

  @override
  String get section2Title => 'Section 2: Questions 11 - 20';

  @override
  String get submitYourAnswer => 'Submit Your Answer: ';

  @override
  String get submit => 'submit';

  @override
  String scoreResult(int correct, int total, String status) {
    return 'score: $correct/$total $status';
  }

  @override
  String get passed => '(Passed)';

  @override
  String get failed => '(Failed)';

  @override
  String get madeForQuiz => 'Made for Driver License Quiz';

  @override
  String architecture(String arch) {
    return 'Architecture: $arch';
  }

  @override
  String questionInDatabase(String num) {
    return 'Question $num in database';
  }

  @override
  String failedToLoadImage(String path) {
    return 'Failed to load image: $path';
  }

  @override
  String optionLabel(String key) {
    return 'Option $key';
  }

  @override
  String correctFeedback(String answer) {
    return 'correct! answer: $answer';
  }

  @override
  String wrongFeedback(String answer) {
    return 'wrong! answer: $answer';
  }

  @override
  String submitFailedSection1(int qNum) {
    return 'Submit Failed! [Section 1] Question $qNum is not answered';
  }

  @override
  String submitFailedSection2(int qNum) {
    return 'Submit Failed! [Section 2] Question $qNum is not answered';
  }

  @override
  String failedToLoadDataset(String path, String error) {
    return 'Failed to load question dataset ($path): $error';
  }

  @override
  String get startQuiz => 'Start Quiz';

  @override
  String get reviewWrongQuestions => 'Review Wrong Questions';

  @override
  String get reviewPageTitle => 'Review Wrong Questions';

  @override
  String get selectVehicleAndLanguage => 'Select Vehicle and Language';

  @override
  String get pressEnterToStart => 'Press Enter or click below to start quiz';

  @override
  String userAnswerLabel(String answer) {
    return 'Your wrong answer: $answer';
  }

  @override
  String get clearWrongQuestions => 'Clear Wrong Questions';

  @override
  String get noWrongQuestionsFound => 'No wrong questions found.';

  @override
  String get backToSelection => 'Back to Selection';

  @override
  String get backToQuiz => 'Back to Quiz';
}
