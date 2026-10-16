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
}
