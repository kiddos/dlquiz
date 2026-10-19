// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class AppLocalizationsZh extends AppLocalizations {
  AppLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get appTitle => '駕照筆試題庫';

  @override
  String get appSubtitle => '機車與汽車考照測驗';

  @override
  String get vehicleLabel => '車型：';

  @override
  String get vehicleMotorcycle => '機車';

  @override
  String get vehicleCar => '汽車';

  @override
  String get languageLabel => '語言：';

  @override
  String get languageChinese => '繁體中文';

  @override
  String get languageEnglish => 'English';

  @override
  String get restartQuiz => '重新開始測驗';

  @override
  String get restart => '重新開始';

  @override
  String get retry => '重試';

  @override
  String get section1Title => '第一部分：第 1 - 10 題';

  @override
  String get section2Title => '第二部分：第 11 - 20 題';

  @override
  String get submitYourAnswer => '提交您的答案：';

  @override
  String get submit => '提交';

  @override
  String scoreResult(int correct, int total, String status) {
    return '得分：$correct/$total $status';
  }

  @override
  String get passed => '(及格)';

  @override
  String get failed => '(不及格)';

  @override
  String get madeForQuiz => '為駕駛執照測驗而製作';

  @override
  String architecture(String arch) {
    return '架構：$arch';
  }

  @override
  String questionInDatabase(String num) {
    return '題庫編號 $num';
  }

  @override
  String failedToLoadImage(String path) {
    return '載入圖片失敗：$path';
  }

  @override
  String optionLabel(String key) {
    return '選項 $key';
  }

  @override
  String correctFeedback(String answer) {
    return '正確！答案：$answer';
  }

  @override
  String wrongFeedback(String answer) {
    return '錯誤！答案：$answer';
  }

  @override
  String submitFailedSection1(int qNum) {
    return '提交失敗！[第一部分] 第 $qNum 題未回答';
  }

  @override
  String submitFailedSection2(int qNum) {
    return '提交失敗！[第二部分] 第 $qNum 題未回答';
  }

  @override
  String failedToLoadDataset(String path, String error) {
    return '載入題目資料集失敗 ($path): $error';
  }

  @override
  String get startQuiz => '開始測驗';

  @override
  String get reviewWrongQuestions => '複習錯題';

  @override
  String get reviewPageTitle => '錯題複習';

  @override
  String get selectVehicleAndLanguage => '選擇車型與語言';

  @override
  String get pressEnterToStart => '按下 Enter 或點擊下方按鈕開始測驗';

  @override
  String userAnswerLabel(String answer) {
    return '您的錯誤答案：$answer';
  }

  @override
  String get clearWrongQuestions => '清除錯題紀錄';

  @override
  String get noWrongQuestionsFound => '尚無錯題紀錄。';

  @override
  String get backToSelection => '返回選擇頁';

  @override
  String get backToQuiz => '返回測驗';
}
