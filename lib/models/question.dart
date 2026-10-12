enum QuestionType { yesNo, multipleChoice }

class Question {
  final String num;
  final String answer; // 'O' / 'X' for yesNo, '1' / '2' / '3' for multipleChoice
  final String text;
  final QuestionType type;
  int? assignedIndex;

  Question({
    required this.num,
    required this.answer,
    required this.text,
    required this.type,
    this.assignedIndex,
  });
}
