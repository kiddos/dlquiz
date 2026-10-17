import 'dart:convert';

enum QuestionType { yesNo, multipleChoice }

class Question {
  final String num;
  final String answer; // 'O' / 'X' for yesNo, '1' / '2' / '3' for multipleChoice
  final String? rawAnswer;
  final int? page;
  final String? architecture;
  final String text;
  final Map<String, String>? options;
  final List<String> images;
  final QuestionType type;
  int? assignedIndex;

  Question({
    required this.num,
    required this.answer,
    this.rawAnswer,
    this.page,
    this.architecture,
    required this.text,
    this.options,
    this.images = const [],
    this.type = QuestionType.multipleChoice,
    this.assignedIndex,
  });

  factory Question.fromJson(Map<String, dynamic> json, {String assetPrefix = ''}) {
    final numVal = json['num']?.toString() ?? '';
    final answerVal = json['answer']?.toString() ?? '';
    final rawAns = json['raw_answer']?.toString();
    final pageVal = json['page'] as int?;
    final archVal = json['architecture']?.toString();
    final textVal = json['text']?.toString() ?? '';

    Map<String, String> optionsMap = {};
    if (json['options'] is Map) {
      (json['options'] as Map).forEach((k, v) {
        optionsMap[k.toString()] = v.toString();
      });
    }

    List<String> imageList = [];
    if (json['images'] is List) {
      for (var img in (json['images'] as List)) {
        final imgStr = img.toString();
        if (assetPrefix.isNotEmpty && !imgStr.startsWith('http') && !imgStr.startsWith('assets/')) {
          imageList.add('$assetPrefix/$imgStr');
        } else {
          imageList.add(imgStr);
        }
      }
    }

    QuestionType qType = QuestionType.multipleChoice;
    if (answerVal == 'O' || answerVal == 'X') {
      qType = QuestionType.yesNo;
    }

    return Question(
      num: numVal,
      answer: answerVal,
      rawAnswer: rawAns,
      page: pageVal,
      architecture: archVal,
      text: textVal,
      options: optionsMap.isNotEmpty ? optionsMap : null,
      images: imageList,
      type: qType,
    );
  }

  Map<String, dynamic> toDbMap({required String vehicle, required String lang, String? userAnswer}) {
    return {
      'vehicle': vehicle,
      'lang': lang,
      'num': num,
      'answer': answer,
      'raw_answer': rawAnswer,
      'page': page,
      'architecture': architecture,
      'text': text,
      'options': options != null ? jsonEncode(options) : null,
      'images': jsonEncode(images),
      'type': type.name,
      'user_answer': userAnswer,
    };
  }

  factory Question.fromDbMap(Map<String, dynamic> map) {
    Map<String, String>? optionsMap;
    if (map['options'] != null && map['options'].toString().isNotEmpty) {
      try {
        final decoded = jsonDecode(map['options'].toString());
        if (decoded is Map) {
          optionsMap = {};
          decoded.forEach((k, v) {
            optionsMap![k.toString()] = v.toString();
          });
        }
      } catch (_) {}
    }

    List<String> imageList = [];
    if (map['images'] != null && map['images'].toString().isNotEmpty) {
      try {
        final decoded = jsonDecode(map['images'].toString());
        if (decoded is List) {
          imageList = decoded.map((e) => e.toString()).toList();
        }
      } catch (_) {}
    }

    QuestionType qType = QuestionType.multipleChoice;
    final typeStr = map['type']?.toString();
    final ansStr = map['answer']?.toString();
    if (typeStr == 'yesNo' || ansStr == 'O' || ansStr == 'X') {
      qType = QuestionType.yesNo;
    }

    return Question(
      num: map['num']?.toString() ?? '',
      answer: ansStr ?? '',
      rawAnswer: map['raw_answer']?.toString(),
      page: map['page'] as int?,
      architecture: map['architecture']?.toString(),
      text: map['text']?.toString() ?? '',
      options: optionsMap,
      images: imageList,
      type: qType,
    );
  }
}
