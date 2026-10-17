import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_zh.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('zh'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Driver License Quiz'**
  String get appTitle;

  /// No description provided for @appSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Driver\'s License Written Test Question Bank'**
  String get appSubtitle;

  /// No description provided for @vehicleLabel.
  ///
  /// In en, this message translates to:
  /// **'Vehicle: '**
  String get vehicleLabel;

  /// No description provided for @vehicleMotorcycle.
  ///
  /// In en, this message translates to:
  /// **'Motorcycle'**
  String get vehicleMotorcycle;

  /// No description provided for @vehicleCar.
  ///
  /// In en, this message translates to:
  /// **'Car'**
  String get vehicleCar;

  /// No description provided for @languageLabel.
  ///
  /// In en, this message translates to:
  /// **'Language: '**
  String get languageLabel;

  /// No description provided for @languageChinese.
  ///
  /// In en, this message translates to:
  /// **'Traditional Chinese'**
  String get languageChinese;

  /// No description provided for @languageEnglish.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get languageEnglish;

  /// No description provided for @restartQuiz.
  ///
  /// In en, this message translates to:
  /// **'Restart Quiz'**
  String get restartQuiz;

  /// No description provided for @restart.
  ///
  /// In en, this message translates to:
  /// **'Restart'**
  String get restart;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @section1Title.
  ///
  /// In en, this message translates to:
  /// **'Section 1: Questions 1 - 10'**
  String get section1Title;

  /// No description provided for @section2Title.
  ///
  /// In en, this message translates to:
  /// **'Section 2: Questions 11 - 20'**
  String get section2Title;

  /// No description provided for @submitYourAnswer.
  ///
  /// In en, this message translates to:
  /// **'Submit Your Answer: '**
  String get submitYourAnswer;

  /// No description provided for @submit.
  ///
  /// In en, this message translates to:
  /// **'submit'**
  String get submit;

  /// No description provided for @scoreResult.
  ///
  /// In en, this message translates to:
  /// **'score: {correct}/{total} {status}'**
  String scoreResult(int correct, int total, String status);

  /// No description provided for @passed.
  ///
  /// In en, this message translates to:
  /// **'(Passed)'**
  String get passed;

  /// No description provided for @failed.
  ///
  /// In en, this message translates to:
  /// **'(Failed)'**
  String get failed;

  /// No description provided for @madeForQuiz.
  ///
  /// In en, this message translates to:
  /// **'Made for Driver License Quiz'**
  String get madeForQuiz;

  /// No description provided for @architecture.
  ///
  /// In en, this message translates to:
  /// **'Architecture: {arch}'**
  String architecture(String arch);

  /// No description provided for @questionInDatabase.
  ///
  /// In en, this message translates to:
  /// **'Question {num} in database'**
  String questionInDatabase(String num);

  /// No description provided for @failedToLoadImage.
  ///
  /// In en, this message translates to:
  /// **'Failed to load image: {path}'**
  String failedToLoadImage(String path);

  /// No description provided for @optionLabel.
  ///
  /// In en, this message translates to:
  /// **'Option {key}'**
  String optionLabel(String key);

  /// No description provided for @correctFeedback.
  ///
  /// In en, this message translates to:
  /// **'correct! answer: {answer}'**
  String correctFeedback(String answer);

  /// No description provided for @wrongFeedback.
  ///
  /// In en, this message translates to:
  /// **'wrong! answer: {answer}'**
  String wrongFeedback(String answer);

  /// No description provided for @submitFailedSection1.
  ///
  /// In en, this message translates to:
  /// **'Submit Failed! [Section 1] Question {qNum} is not answered'**
  String submitFailedSection1(int qNum);

  /// No description provided for @submitFailedSection2.
  ///
  /// In en, this message translates to:
  /// **'Submit Failed! [Section 2] Question {qNum} is not answered'**
  String submitFailedSection2(int qNum);

  /// No description provided for @failedToLoadDataset.
  ///
  /// In en, this message translates to:
  /// **'Failed to load question dataset ({path}): {error}'**
  String failedToLoadDataset(String path, String error);
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'zh'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'zh':
      return AppLocalizationsZh();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
