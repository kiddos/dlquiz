enum QuestionType { yesNo, multipleChoice }

class Question {
  final String num;
  final String answer; // '1' / '2' / '3' for multipleChoice (or 'O'/'X' if yesNo)
  final String text;
  final QuestionType type;
  final List<String> images; // e.g. ["images/1.png"] or asset path "questions/v2/images/1.png"
  final Map<String, String> options; // e.g. {"1": "...", "2": "...", "3": "..."}
  final String? rawAnswer;
  final int? page;
  final String? architecture;
  int? assignedIndex;

  Question({
    required this.num,
    required this.answer,
    required this.text,
    required this.type,
    this.images = const [],
    this.options = const {},
    this.rawAnswer,
    this.page,
    this.architecture,
    this.assignedIndex,
  });

  factory Question.fromJson(Map<String, dynamic> json) {
    final numVal = json['num'] != null ? json['num'].toString() : '';
    final answerVal = json['answer'] != null ? json['answer'].toString() : '';
    final textVal = json['text'] != null ? json['text'].toString() : '';

    final imagesList = (json['images'] as List<dynamic>?)
            ?.map((e) => e.toString())
            .toList() ??
        [];

    final Map<String, String> optionsMap = {};
    if (json['options'] is Map) {
      (json['options'] as Map<String, dynamic>).forEach((k, v) {
        optionsMap[k] = v.toString();
      });
    }

    return Question(
      num: numVal,
      answer: answerVal,
      text: textVal,
      type: QuestionType.multipleChoice,
      images: imagesList,
      options: optionsMap,
      rawAnswer: json['raw_answer']?.toString(),
      page: json['page'] is int ? json['page'] as int : int.tryParse(json['page']?.toString() ?? ''),
      architecture: json['architecture']?.toString(),
    );
  }
}
