import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'l10n/app_localizations.dart';
import 'models/question.dart';
import 'models/quiz_state.dart';
import 'utils/question_parser.dart';

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
      title: '台灣駕照小測驗',
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
      home: QuizPage(
        currentLocale: _locale,
        onLocaleChanged: _setLocale,
      ),
    );
  }
}

class QuizPage extends StatefulWidget {
  final Locale? currentLocale;
  final ValueChanged<Locale>? onLocaleChanged;

  const QuizPage({
    super.key,
    this.currentLocale,
    this.onLocaleChanged,
  });

  @override
  State<QuizPage> createState() => _QuizPageState();
}

class _QuizPageState extends State<QuizPage> {
  String _selectedVehicle = 'motorcycle'; // 'car' or 'motorcycle'
  late String _selectedLang; // 'zh' or 'en'

  List<Question>? _allQuestions;
  QuizState? _quizState;
  bool _isLoading = true;
  String? _loadError;

  @override
  void initState() {
    super.initState();
    _selectedLang = widget.currentLocale?.languageCode ?? 'zh';
    _loadQuestionsAndInitQuiz();
  }

  @override
  void didUpdateWidget(covariant QuizPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.currentLocale != null &&
        widget.currentLocale!.languageCode != _selectedLang) {
      setState(() {
        _selectedLang = widget.currentLocale!.languageCode;
      });
      _loadQuestionsAndInitQuiz();
    }
  }

  Future<void> _loadQuestionsAndInitQuiz() async {
    setState(() {
      _isLoading = true;
      _loadError = null;
    });

    final assetPrefix = 'questions/v2/$_selectedVehicle/$_selectedLang';
    final jsonPath = '$assetPrefix/questions.json';

    try {
      final jsonString = await rootBundle.loadString(jsonPath);

      final questions = QuestionParser.parseJsonQuestions(
        jsonString,
        assetPrefix: assetPrefix,
      );

      setState(() {
        _allQuestions = questions;
        _quizState = QuizState.generateFromQuestions(questions);
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _loadError = '$jsonPath: $e';
        _isLoading = false;
      });
    }
  }

  void _resetQuiz() {
    if (_allQuestions != null && _allQuestions!.isNotEmpty) {
      setState(() {
        _quizState = QuizState.generateFromQuestions(_allQuestions!);
      });
    }
  }

  void _submitAnswers() {
    if (_quizState == null) return;
    final l10n = AppLocalizations.of(context);
    setState(() {
      _quizState!.submitAnswers(l10n);
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          l10n?.appTitle ?? 'Driver License Quiz',
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF337AB7),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            tooltip: l10n?.restartQuiz ?? 'Restart Quiz',
            onPressed: _resetQuiz,
          ),
        ],
      ),
      body: _buildBody(l10n),
    );
  }

  Widget _buildBody(AppLocalizations? l10n) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_loadError != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                l10n?.failedToLoadDataset(_loadError!, '') ?? _loadError!,
                style: const TextStyle(color: Colors.red, fontSize: 16),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _loadQuestionsAndInitQuiz,
                child: Text(l10n?.retry ?? 'Retry'),
              ),
            ],
          ),
        ),
      );
    }

    final state = _quizState!;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header & Dataset Selector
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(8.0),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n?.appTitle ?? 'Driver License Quiz',
                  style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  l10n?.appSubtitle ?? 'Driver\'s License Written Test Question Bank',
                  style: const TextStyle(fontSize: 14, color: Colors.black54),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 16,
                  runSpacing: 8,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          l10n?.vehicleLabel ?? 'Vehicle: ',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        DropdownButton<String>(
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
                            if (val != null && val != _selectedVehicle) {
                              setState(() {
                                _selectedVehicle = val;
                              });
                              _loadQuestionsAndInitQuiz();
                            }
                          },
                        ),
                      ],
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          l10n?.languageLabel ?? 'Language: ',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        DropdownButton<String>(
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
                            if (val != null && val != _selectedLang) {
                              setState(() {
                                _selectedLang = val;
                              });
                              widget.onLocaleChanged?.call(Locale(val));
                              _loadQuestionsAndInitQuiz();
                            }
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Section 1 Header
          Text(
            l10n?.section1Title ?? 'Section 1: Questions 1 - 10',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const Divider(thickness: 1.5),
          const SizedBox(height: 8),

          // Section 1 Questions
          ...List.generate(state.section1Questions.length, (index) {
            final q = state.section1Questions[index];
            final qIndex = index + 1;
            return _buildQuestionCard(q, 1, qIndex, state, l10n);
          }),

          const SizedBox(height: 20),

          // Section 2 Header
          Text(
            l10n?.section2Title ?? 'Section 2: Questions 11 - 20',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const Divider(thickness: 1.5),
          const SizedBox(height: 8),

          // Section 2 Questions
          ...List.generate(state.section2Questions.length, (index) {
            final q = state.section2Questions[index];
            final qIndex = index + 1;
            return _buildQuestionCard(q, 2, qIndex, state, l10n);
          }),

          const SizedBox(height: 20),

          // Submit controls & Error Alert
          if (state.errorMessage != null) ...[
            Container(
              key: const Key('error_msg_container'),
              width: double.infinity,
              padding: const EdgeInsets.all(12.0),
              decoration: BoxDecoration(
                color: const Color(0xFFF2DEDE),
                border: Border.all(color: const Color(0xFFEBCCD1)),
                borderRadius: BorderRadius.circular(4.0),
              ),
              child: Text(
                state.errorMessage!,
                key: const Key('error_msg'),
                style: const TextStyle(
                  color: Color(0xFFA94442),
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],

          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n?.submitYourAnswer ?? 'Submit Your Answer: ',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),

              Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: ElevatedButton(
                      onPressed: _submitAnswers,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF337AB7),
                        foregroundColor: Colors.white,
                      ),
                      child: Text(l10n?.submit ?? 'submit'),
                    ),
                  ),
                  OutlinedButton(
                    onPressed: _resetQuiz,
                    child: Text(l10n?.restart ?? 'Restart'),
                  ),
                ],
              ),
            ],
          ),

          // Score Result
          if (state.isSubmitted) ...[
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12.0),
              child: Text(
                l10n != null
                    ? l10n.scoreResult(
                        state.totalCorrect,
                        state.totalQuestions,
                        state.isPassed ? l10n.passed : l10n.failed,
                      )
                    : 'score: ${state.totalCorrect}/${state.totalQuestions} ${state.isPassed ? "(Passed)" : "(Failed)"}',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: state.isPassed
                      ? const Color(0xFF3C763D)
                      : const Color(0xFFA94442),
                ),
              ),
            ),
          ],

          const SizedBox(height: 40),

          // Footer
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16.0),
            color: const Color(0xFFD8D8D8),
            child: Text(
              l10n?.madeForQuiz ?? 'Made for Driver License Quiz',
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.black87),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionCard(
    Question q,
    int sectionNum,
    int qIndex,
    QuizState state,
    AppLocalizations? l10n,
  ) {
    final userAnswers = sectionNum == 1
        ? state.section1UserAnswers
        : state.section2UserAnswers;
    final selectedAnswer = userAnswers[qIndex];
    final isSubmitted = state.isSubmitted;
    final isCorrect = selectedAnswer == q.answer;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$qIndex. ',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Expanded(
                  child: Text(
                    q.text,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            if (q.architecture != null && q.architecture!.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                l10n?.architecture(q.architecture!) ?? 'Architecture: ${q.architecture}',
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.black54,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
            Text(
              l10n?.questionInDatabase(q.num) ?? 'Question ${q.num} in database',
              style: const TextStyle(fontSize: 12, color: Colors.black54),
            ),

            // Display Images if present
            if (q.images.isNotEmpty) ...[
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: q.images.map((imgPath) {
                  return ClipRRect(
                    borderRadius: BorderRadius.circular(4.0),
                    child: Image.asset(
                      imgPath,
                      height: 160,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) {
                        return Text(
                          l10n?.failedToLoadImage(imgPath) ?? 'Failed to load image: $imgPath',
                          style: const TextStyle(color: Colors.red),
                        );
                      },
                    ),
                  );
                }).toList(),
              ),
            ],

            const SizedBox(height: 8),

            // Options selector
            if (q.type == QuestionType.yesNo) ...[
              Row(
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Radio<String>(
                        value: 'O',
                        groupValue: selectedAnswer,
                        onChanged: (val) {
                          setState(() {
                            userAnswers[qIndex] = val!;
                          });
                        },
                      ),
                      const Text('O'),
                    ],
                  ),
                  const SizedBox(width: 16),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Radio<String>(
                        value: 'X',
                        groupValue: selectedAnswer,
                        onChanged: (val) {
                          setState(() {
                            userAnswers[qIndex] = val!;
                          });
                        },
                      ),
                      const Text('X'),
                    ],
                  ),
                ],
              ),
            ] else ...[
              // Multiple Choice Options (1, 2, 3)
              Column(
                children: ['1', '2', '3'].map((optKey) {
                  final optionText = q.options?[optKey];
                  return InkWell(
                    onTap: () {
                      setState(() {
                        userAnswers[qIndex] = optKey;
                      });
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 2.0),
                      child: Row(
                        children: [
                          Radio<String>(
                            value: optKey,
                            groupValue: selectedAnswer,
                            onChanged: (val) {
                              setState(() {
                                userAnswers[qIndex] = val!;
                              });
                            },
                          ),
                          Text(
                            '($optKey) ',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          if (optionText != null && optionText.isNotEmpty)
                            Expanded(
                              child: Text(
                                optionText,
                                style: const TextStyle(fontSize: 14),
                              ),
                            )
                          else
                            Text(l10n?.optionLabel(optKey) ?? 'Option $optKey'),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],

            if (isSubmitted) ...[
              const SizedBox(height: 6),
              Text(
                isCorrect
                    ? (l10n?.correctFeedback(q.answer) ?? 'correct! answer: ${q.answer}')
                    : (l10n?.wrongFeedback(q.answer) ?? 'wrong! answer: ${q.answer}'),
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: isCorrect
                      ? const Color(0xFF3C763D)
                      : const Color(0xFFA94442),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
