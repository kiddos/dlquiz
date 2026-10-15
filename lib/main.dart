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

    try {
      final jsonString = await rootBundle.loadString('questions/v2/questions.json');
      final questions = QuestionParser.parseJsonQuestions(jsonString);

      setState(() {
        _allQuestions = questions;
        _quizState = QuizState.generateQuiz(questions);
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _loadError = 'Failed to load question datasets: $e';
        _isLoading = false;
      });
    }
  }

  void _resetQuiz() {
    if (_allQuestions != null) {
      setState(() {
        _quizState = QuizState.generateQuiz(_allQuestions!);
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
          )
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_loadError != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(_loadError!, style: const TextStyle(color: Colors.red, fontSize: 16)),
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
          // Jumbotron style Header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(8.0),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  'Driver License Quiz',
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 4),
                Text(
                  'Updated July 2015',
                  style: TextStyle(fontSize: 16, color: Colors.black54),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Section 1 Header
          const Text(
            'Section 1: Multiple Choice Questions',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const Divider(thickness: 1.5),
          const SizedBox(height: 8),

          // Section 1 Questions
          ...List.generate(state.section1Questions.length, (index) {
            final q = state.section1Questions[index];
            final qIndex = index + 1;
            return _buildMultipleChoiceQuestionCard(q, qIndex, state, isSection1: true);
          }),

          const SizedBox(height: 20),

          // Section 2 Header
          const Text(
            'Section 2: Multiple Choice Questions',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const Divider(thickness: 1.5),
          const SizedBox(height: 8),

          // Section 2 Questions
          ...List.generate(state.section2Questions.length, (index) {
            final q = state.section2Questions[index];
            final qIndex = index + 1;
            return _buildMultipleChoiceQuestionCard(q, qIndex, state, isSection1: false);
          }),

          const SizedBox(height: 20),

          // Submit controls & Error Alert
          if (state.errorMessage != null) ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12.0),
              decoration: BoxDecoration(
                color: const Color(0xFFF2DEDE),
                border: Border.all(color: const Color(0xFFEBCCD1)),
                borderRadius: BorderRadius.circular(4.0),
              ),
              child: Text(
                state.errorMessage!,
                style: const TextStyle(
                  color: Color(0xFFA94442),
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],

          Row(
            children: [
              const Text(
                'Submit Your Answer: ',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: _submitAnswers,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF337AB7),
                  foregroundColor: Colors.white,
                ),
                child: const Text('submit'),
              ),
              const SizedBox(width: 12),
              OutlinedButton(
                onPressed: _resetQuiz,
                child: const Text('Restart'),
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
                  color: state.isPassed ? const Color(0xFF3C763D) : const Color(0xFFA94442),
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
              'Made by Joseph Yu (2015/8/9)',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.black87),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMultipleChoiceQuestionCard(Question q, int qIndex, QuizState state, {required bool isSection1}) {
    final userAnswers = isSection1 ? state.section1UserAnswers : state.section2UserAnswers;
    final selectedAnswer = userAnswers[qIndex];
    final isSubmitted = state.isSubmitted;
    final isCorrect = selectedAnswer == q.answer;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Options column
          SizedBox(
            width: 170,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '$qIndex. ',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontStyle: FontStyle.italic),
                ),
                Radio<String>(
                  value: '1',
                  groupValue: selectedAnswer,
                  visualDensity: VisualDensity.compact,
                  onChanged: (val) {
                    setState(() {
                      userAnswers[qIndex] = val!;
                    });
                  },
                ),
                const Text('1'),
                Radio<String>(
                  value: '2',
                  groupValue: selectedAnswer,
                  visualDensity: VisualDensity.compact,
                  onChanged: (val) {
                    setState(() {
                      userAnswers[qIndex] = val!;
                    });
                  },
                ),
                const Text('2'),
                Radio<String>(
                  value: '3',
                  groupValue: selectedAnswer,
                  visualDensity: VisualDensity.compact,
                  onChanged: (val) {
                    setState(() {
                      userAnswers[qIndex] = val!;
                    });
                  },
                ),
                const Text('3'),
              ],
            ),
          ),
          const SizedBox(width: 8),
          // Question text, images and status
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (q.images.isNotEmpty) ...[
                  ...q.images.map((imgPath) {
                    final assetPath = imgPath.startsWith('questions/v2/')
                        ? imgPath
                        : 'questions/v2/$imgPath';
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: Image.asset(
                        assetPath,
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) =>
                            Text('[Image failed to load: $assetPath]', style: const TextStyle(color: Colors.red)),
                      ),
                    );
                  }),
                ],
                Text(
                  q.text,
                  style: const TextStyle(fontSize: 15),
                ),
                Text(
                  'Question ${q.num} in database',
                  style: const TextStyle(fontSize: 12, color: Colors.black54),
                ),
                if (isSubmitted)
                  Padding(
                    padding: const EdgeInsets.only(top: 2.0),
                    child: Text(
                      isCorrect ? 'correct! answer: ${q.answer}' : 'wrong! answer: ${q.answer}',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: isCorrect ? const Color(0xFF3C763D) : const Color(0xFFA94442),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
