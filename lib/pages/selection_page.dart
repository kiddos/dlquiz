import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../l10n/app_localizations.dart';
import '../utils/database_helper.dart';
import 'quiz_page.dart';
import 'review_page.dart';

class SelectionPage extends StatefulWidget {
  final Locale currentLocale;
  final ValueChanged<Locale> onLocaleChanged;

  const SelectionPage({
    super.key,
    required this.currentLocale,
    required this.onLocaleChanged,
  });

  @override
  State<SelectionPage> createState() => _SelectionPageState();
}

class _SelectionPageState extends State<SelectionPage> {
  late FocusNode _focusNode;
  late String _selectedVehicle; // 'motorcycle' or 'car'
  late String _selectedLang; // 'zh' or 'en'
  int _wrongQuestionCount = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
    _selectedVehicle = 'motorcycle';
    _selectedLang = widget.currentLocale.languageCode;
    _checkWrongQuestionCount();
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant SelectionPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.currentLocale.languageCode != _selectedLang) {
      setState(() {
        _selectedLang = widget.currentLocale.languageCode;
      });
    }
  }

  Future<void> _checkWrongQuestionCount() async {
    setState(() {
      _isLoading = true;
    });
    final count = await DatabaseHelper.instance.getWrongQuestionCount();
    if (mounted) {
      setState(() {
        _wrongQuestionCount = count;
        _isLoading = false;
      });
    }
  }

  void _startQuiz() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => QuizPage(
          selectedVehicle: _selectedVehicle,
          selectedLang: _selectedLang,
          currentLocale: Locale(_selectedLang),
          onLocaleChanged: widget.onLocaleChanged,
        ),
      ),
    );
    _checkWrongQuestionCount();
  }

  void _openReviewPage() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ReviewPage(
          currentLocale: Locale(_selectedLang),
          onLocaleChanged: widget.onLocaleChanged,
        ),
      ),
    );
    _checkWrongQuestionCount();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return CallbackShortcuts(
      bindings: {
        const SingleActivator(LogicalKeyboardKey.enter): _startQuiz,
        const SingleActivator(LogicalKeyboardKey.numpadEnter): _startQuiz,
      },
      child: Focus(
        focusNode: _focusNode,
        autofocus: true,
        child: Scaffold(
          appBar: AppBar(
            title: Text(
              l10n?.appTitle ?? 'Driver License Quiz',
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
            backgroundColor: const Color(0xFF337AB7),
          ),
          body: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Card(
                elevation: 4,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.assignment,
                        size: 64,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        l10n?.appTitle ?? 'Driver License Quiz',
                        style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        l10n?.appSubtitle ?? 'Driver\'s License Written Test Question Bank',
                        style: const TextStyle(fontSize: 14, color: Colors.black54),
                        textAlign: TextAlign.center,
                      ),
                      const Divider(height: 32, thickness: 1),

                      Text(
                        l10n?.selectVehicleAndLanguage ?? 'Select Vehicle and Language',
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 16),

                      // Vehicle Selection
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            l10n?.vehicleLabel ?? 'Vehicle: ',
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(width: 8),
                          DropdownButton<String>(
                            key: const Key('vehicle_dropdown'),
                            value: _selectedVehicle,
                            items: [
                              DropdownMenuItem(
                                value: 'motorcycle',
                                child: Text(l10n?.vehicleMotorcycle ?? 'Motorcycle'),
                              ),
                              DropdownMenuItem(
                                value: 'car',
                                child: Text(l10n?.vehicleCar ?? 'Car'),
                              ),
                            ],
                            onChanged: (val) {
                              if (val != null) {
                                setState(() {
                                  _selectedVehicle = val;
                                });
                              }
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // Language Selection
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            l10n?.languageLabel ?? 'Language: ',
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(width: 8),
                          DropdownButton<String>(
                            key: const Key('language_dropdown'),
                            value: _selectedLang,
                            items: [
                              DropdownMenuItem(
                                value: 'zh',
                                child: Text(l10n?.languageChinese ?? 'Traditional Chinese'),
                              ),
                              DropdownMenuItem(
                                value: 'en',
                                child: Text(l10n?.languageEnglish ?? 'English'),
                              ),
                            ],
                            onChanged: (val) {
                              if (val != null) {
                                setState(() {
                                  _selectedLang = val;
                                });
                                widget.onLocaleChanged(Locale(val));
                              }
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // Hint
                      Text(
                        l10n?.pressEnterToStart ?? 'Press Enter or click below to start quiz',
                        style: const TextStyle(fontSize: 12, color: Colors.grey),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),

                      // Start Quiz Button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          key: const Key('start_quiz_button'),
                          onPressed: _startQuiz,
                          icon: const Icon(Icons.play_arrow),
                          label: Text(
                            l10n?.startQuiz ?? 'Start Quiz',
                            style: const TextStyle(fontSize: 18),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF337AB7),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ),

                      // Review Wrong Questions Button (Conditional: only shown if wrong questions exist)
                      if (!_isLoading && _wrongQuestionCount > 0) ...[
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton.icon(
                            key: const Key('review_button'),
                            onPressed: _openReviewPage,
                            icon: const Icon(Icons.history, color: Colors.redAccent),
                            label: Text(
                              '${l10n?.reviewWrongQuestions ?? "Review Wrong Questions"} ($_wrongQuestionCount)',
                              style: const TextStyle(fontSize: 16, color: Colors.redAccent),
                            ),
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: Colors.redAccent),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
