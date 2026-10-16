import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'models/question.dart';
import 'models/quiz_state.dart';
import 'utils/question_parser.dart';

void main() {
  runApp(const DriverLicenseQuizApp());
}

class DriverLicenseQuizApp extends StatelessWidget {
  const DriverLicenseQuizApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Driver License Quiz',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF337AB7),
          primary: const Color(0xFF337AB7),
        ),
        useMaterial3: true,
      ),
      home: const QuizPage(),
    );
  }
}

class QuizPage extends StatefulWidget {
  const QuizPage({super.key});

  @override
  State<QuizPage> createState() => _QuizPageState();
}

class _QuizPageState extends State<QuizPage> {
  String _selectedVehicle = 'motorcycle'; // 'car' or 'motorcycle'
  String _selectedLang = 'zh'; // 'zh' or 'en'

  List<Question>? _allQuestions;
  QuizState? _quizState;
  bool _isLoading = true;
  String? _loadError;

  @override
  void initState() {
    super.initState();
    _loadQuestionsAndInitQuiz();
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
        _loadError = 'Failed to load question dataset ($jsonPath): $e';
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
    setState(() {
      _quizState!.submitAnswers();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Driver License Quiz',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF337AB7),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            tooltip: 'Restart Quiz',
            onPressed: _resetQuiz,
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
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
                _loadError!,
                style: const TextStyle(color: Colors.red, fontSize: 16),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _loadQuestionsAndInitQuiz,
                child: const Text('Retry'),
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
                const Text(
                  'Driver License Quiz',
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Driver\'s License Written Test Question Bank',
                  style: TextStyle(fontSize: 14, color: Colors.black54),
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
                        const Text(
                          'Vehicle: ',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        DropdownButton<String>(
                          value: _selectedVehicle,
                          items: const [
                            DropdownMenuItem(
                              value: 'motorcycle',
                              child: Text('Motorcycle (機車)'),
                            ),
                            DropdownMenuItem(
                              value: 'car',
                              child: Text('Car (汽車)'),
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
                        const Text(
                          'Language: ',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        DropdownButton<String>(
                          value: _selectedLang,
                          items: const [
                            DropdownMenuItem(
                              value: 'zh',
                              child: Text('Chinese (中文)'),
                            ),
                            DropdownMenuItem(
                              value: 'en',
                              child: Text('English'),
                            ),
                          ],
                          onChanged: (val) {
                            if (val != null && val != _selectedLang) {
                              setState(() {
                                _selectedLang = val;
                              });
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
          const Text(
            'Section 1: Questions 1 - 10',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const Divider(thickness: 1.5),
          const SizedBox(height: 8),

          // Section 1 Questions
          ...List.generate(state.section1Questions.length, (index) {
            final q = state.section1Questions[index];
            final qIndex = index + 1;
            return _buildQuestionCard(q, 1, qIndex, state);
          }),

          const SizedBox(height: 20),

          // Section 2 Header
          const Text(
            'Section 2: Questions 11 - 20',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const Divider(thickness: 1.5),
          const SizedBox(height: 8),

          // Section 2 Questions
          ...List.generate(state.section2Questions.length, (index) {
            final q = state.section2Questions[index];
            final qIndex = index + 1;
            return _buildQuestionCard(q, 2, qIndex, state);
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
              const Text(
                'Submit Your Answer: ',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
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
                      child: const Text('submit'),
                    ),
                  ),
                  OutlinedButton(
                    onPressed: _resetQuiz,
                    child: const Text('Restart'),
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
                'score: ${state.totalCorrect}/${state.totalQuestions} ${state.isPassed ? "(Passed)" : "(Failed)"}',
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
            child: const Text(
              'Made for Driver License Quiz',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.black87),
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
                'Architecture: ${q.architecture}',
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.black54,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
            Text(
              'Question ${q.num} in database',
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
                          'Failed to load image: $imgPath',
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
                            Text('Option $optKey'),
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
                    ? 'correct! answer: ${q.answer}'
                    : 'wrong! answer: ${q.answer}',
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
