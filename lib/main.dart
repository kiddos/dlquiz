import 'package:flutter/material.dart';
import 'l10n/app_localizations.dart';
import 'pages/selection_page.dart';

export 'pages/selection_page.dart';
export 'pages/quiz_page.dart';
export 'pages/review_page.dart';

void main() {
  runApp(const DriverLicenseQuizApp());
}

class DriverLicenseQuizApp extends StatefulWidget {
  final Locale? initialLocale;

  const DriverLicenseQuizApp({super.key, this.initialLocale});

  @override
  State<DriverLicenseQuizApp> createState() => _DriverLicenseQuizAppState();
}

class _DriverLicenseQuizAppState extends State<DriverLicenseQuizApp> {
  late Locale _locale;

  @override
  void initState() {
    super.initState();
    _locale = widget.initialLocale ?? const Locale('zh');
  }

  void _setLocale(Locale locale) {
    setState(() {
      _locale = locale;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      onGenerateTitle: (context) =>
          AppLocalizations.of(context)?.appTitle ?? '駕照筆試題庫',
      debugShowCheckedModeBanner: false,
      locale: _locale,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF337AB7),
          primary: const Color(0xFF337AB7),
        ),
        useMaterial3: true,
      ),
      home: SelectionPage(
        currentLocale: _locale,
        onLocaleChanged: _setLocale,
      ),
    );
  }
}
