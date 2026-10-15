import 'dart:convert';
import '../models/question.dart';

class QuestionParser {
  static List<Question> parseJsonQuestions(String jsonContent) {
    // Remove BOM if present
    if (jsonContent.startsWith('\uFEFF')) {
      jsonContent = jsonContent.substring(1);
    }
    final List<dynamic> decoded = jsonDecode(jsonContent) as List<dynamic>;
    return decoded.map((e) => Question.fromJson(e as Map<String, dynamic>)).toList();
  }

  static List<Question> parseQuestions(String rawContent, QuestionType type) {
    // Remove BOM if present
    if (rawContent.startsWith('\uFEFF')) {
      rawContent = rawContent.substring(1);
    }

    final rawLines = rawContent.split('\n');
    final String splitStr = "splitting";
    StringBuffer contentBuffer = StringBuffer();

    for (var rawLine in rawLines) {
      String data = rawLine.trim();
      if (data.isEmpty) {
        continue;
      }
      if (data.length >= 2) {
        String last2 = data.substring(data.length - 2);
        if (_isDigit(last2[0]) && _isDigit(last2[1])) {
          contentBuffer.write(data);
          contentBuffer.write(splitStr);
          continue;
        }
      }
      contentBuffer.write(' ');
      contentBuffer.write(data);
    }

    final blocks = contentBuffer.toString().split(splitStr);
    final List<Question> questions = [];

    for (var block in blocks) {
      String line = block;
      if (line.isEmpty || line.trim().isEmpty) continue;

      line = line.replaceAll('\t', '');
      while (line.contains('  ')) {
        line = line.replaceAll('  ', ' ');
      }
      if (line.startsWith(' ')) {
        line = line.substring(1);
      }
      line = line.trim();
      if (line.isEmpty) continue;

      int firstSpace = line.indexOf(' ');
      if (firstSpace == -1) continue;
      int secondSpace = line.indexOf(' ', firstSpace + 1);
      if (secondSpace == -1) continue;

      String num = line.substring(0, firstSpace);
      String ans = line.substring(firstSpace + 1, secondSpace);

      String questionText = line.substring(secondSpace + 1);
      if (questionText.length >= 2) {
        questionText = questionText.substring(0, questionText.length - 2);
      }
      questionText = questionText.replaceAll(' ', '');

      questions.add(Question(
        num: num,
        answer: ans,
        text: questionText,
        type: type,
      ));
    }

    return questions;
  }

  static bool _isDigit(String s) {
    if (s.isEmpty) return false;
    int code = s.codeUnitAt(0);
    return code >= 48 && code <= 57;
  }
}
