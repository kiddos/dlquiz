import 'question.dart';

class WrongQuestionRecord {
  final int id;
  final String vehicle;
  final String lang;
  final Question question;
  final String? userAnswer;
  final String? createdAt;

  WrongQuestionRecord({
    required this.id,
    required this.vehicle,
    required this.lang,
    required this.question,
    this.userAnswer,
    this.createdAt,
  });

  factory WrongQuestionRecord.fromDbMap(Map<String, dynamic> map) {
    return WrongQuestionRecord(
      id: map['id'] is int ? map['id'] as int : int.tryParse(map['id'].toString()) ?? 0,
      vehicle: map['vehicle']?.toString() ?? '',
      lang: map['lang']?.toString() ?? '',
      question: Question.fromDbMap(map),
      userAnswer: map['user_answer']?.toString(),
      createdAt: map['created_at']?.toString(),
    );
  }
}
