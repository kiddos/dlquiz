import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';
import '../models/question.dart';
import '../models/wrong_question_record.dart';
import '../utils/database_helper.dart';
import '../widgets/ad_banner.dart';

class ReviewPage extends StatefulWidget {
  final Locale? currentLocale;
  final ValueChanged<Locale>? onLocaleChanged;

  const ReviewPage({super.key, this.currentLocale, this.onLocaleChanged});

  @override
  State<ReviewPage> createState() => _ReviewPageState();
}

class _ReviewPageState extends State<ReviewPage> {
  List<WrongQuestionRecord> _records = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadWrongQuestions();
  }

  Future<void> _loadWrongQuestions() async {
    setState(() {
      _isLoading = true;
    });
    final records = await DatabaseHelper.instance.getWrongQuestions();
    if (mounted) {
      setState(() {
        _records = records;
        _isLoading = false;
      });
    }
  }

  Future<void> _clearWrongQuestions() async {
    final l10n = AppLocalizations.of(context);
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n?.clearWrongQuestions ?? 'Clear Wrong Questions'),
        content: Text(
          l10n?.languageChinese == '繁體中文'
              ? '確定要清除所有錯題紀錄嗎？'
              : 'Are you sure you want to clear all wrong question records?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n?.restart ?? 'Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: Text(l10n?.clearWrongQuestions ?? 'Clear'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await DatabaseHelper.instance.clearWrongQuestions();
      await _loadWrongQuestions();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          l10n?.reviewPageTitle ?? 'Review Wrong Questions',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: const Color(0xFF337AB7),
        actions: [
          if (_records.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.white),
              tooltip: l10n?.clearWrongQuestions ?? 'Clear Wrong Questions',
              onPressed: _clearWrongQuestions,
            ),
        ],
      ),
      bottomNavigationBar: const AdBanner(),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _records.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.check_circle_outline,
                    size: 64,
                    color: Colors.green,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    l10n?.noWrongQuestionsFound ?? 'No wrong questions found.',
                    style: const TextStyle(fontSize: 18, color: Colors.black54),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(l10n?.backToSelection ?? 'Back to Selection'),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: _records.length,
              itemBuilder: (context, index) {
                final record = _records[index];
                return _buildRecordCard(record, index + 1, l10n);
              },
            ),
    );
  }

  Widget _buildRecordCard(
    WrongQuestionRecord record,
    int displayIndex,
    AppLocalizations? l10n,
  ) {
    final q = record.question;
    final vehicleLabel = record.vehicle == 'car'
        ? (l10n?.vehicleCar ?? 'Car')
        : (l10n?.vehicleMotorcycle ?? 'Motorcycle');
    final langLabel = record.lang == 'en'
        ? (l10n?.languageEnglish ?? 'English')
        : (l10n?.languageChinese ?? 'Traditional Chinese');

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Vehicle & Lang badge
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Chip(
                  avatar: Icon(
                    record.vehicle == 'car'
                        ? Icons.directions_car
                        : Icons.two_wheeler,
                    size: 18,
                  ),
                  label: Text('$vehicleLabel ($langLabel)'),
                  backgroundColor: Colors.blue.shade50,
                  padding: EdgeInsets.zero,
                ),
                Text(
                  l10n?.questionInDatabase(q.num) ?? 'Question ${q.num}',
                  style: const TextStyle(fontSize: 12, color: Colors.black54),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Question Text
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$displayIndex. ',
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
                l10n?.architecture(q.architecture!) ??
                    'Architecture: ${q.architecture}',
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.black54,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],

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
                      height: 140,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) {
                        return Text(
                          l10n?.failedToLoadImage(imgPath) ??
                              'Failed to load image: $imgPath',
                          style: const TextStyle(color: Colors.red),
                        );
                      },
                    ),
                  );
                }).toList(),
              ),
            ],

            const SizedBox(height: 12),

            // Options display
            if (q.type == QuestionType.yesNo) ...[
              Row(
                children: const [
                  Chip(label: Text('O')),
                  SizedBox(width: 8),
                  Chip(label: Text('X')),
                ],
              ),
            ] else if (q.options != null && q.options!.isNotEmpty) ...[
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: ['1', '2', '3'].map((optKey) {
                  final text = q.options![optKey];
                  final isCorrectOption = optKey == q.answer;
                  final isUserWrongOption = optKey == record.userAnswer;

                  Color? bgColor;
                  if (isCorrectOption) {
                    bgColor = Colors.green.shade50;
                  } else if (isUserWrongOption) {
                    bgColor = Colors.red.shade50;
                  }

                  return Container(
                    margin: const EdgeInsets.symmetric(vertical: 2.0),
                    padding: const EdgeInsets.all(8.0),
                    decoration: BoxDecoration(
                      color: bgColor,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '($optKey) ',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: isCorrectOption
                                ? Colors.green.shade800
                                : isUserWrongOption
                                ? Colors.red.shade800
                                : Colors.black87,
                          ),
                        ),
                        Expanded(
                          child: Text(
                            text ?? '',
                            style: TextStyle(
                              color: isCorrectOption
                                  ? Colors.green.shade800
                                  : isUserWrongOption
                                  ? Colors.red.shade800
                                  : Colors.black87,
                            ),
                          ),
                        ),
                        if (isCorrectOption)
                          const Icon(
                            Icons.check_circle,
                            color: Colors.green,
                            size: 18,
                          )
                        else if (isUserWrongOption)
                          const Icon(Icons.cancel, color: Colors.red, size: 18),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ],

            const SizedBox(height: 12),
            const Divider(),

            // Answers info
            Row(
              children: [
                if (record.userAnswer != null) ...[
                  Text(
                    l10n?.userAnswerLabel(record.userAnswer!) ??
                        'Your wrong answer: ${record.userAnswer}',
                    style: const TextStyle(
                      color: Color(0xFFA94442),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 16),
                ],
                Text(
                  l10n?.correctFeedback(q.answer) ??
                      'Correct answer: ${q.answer}',
                  style: const TextStyle(
                    color: Color(0xFF3C763D),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
