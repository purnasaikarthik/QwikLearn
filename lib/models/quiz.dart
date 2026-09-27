import '../core/constants/enums.dart';

class QuizQuestion {
  final String id;
  final String question;
  final QuestionType type;
  final List<String> options;
  final String correctAnswer;
  final String? explanation;

  const QuizQuestion({
    required this.id,
    required this.question,
    required this.type,
    this.options = const [],
    required this.correctAnswer,
    this.explanation,
  });

  factory QuizQuestion.fromMap(Map<String, dynamic> map) => QuizQuestion(
        id: map['id'] as String,
        question: map['question'] as String,
        type: (map['question_type'] as String? ?? 'multiple_choice') == 'true_false'
            ? QuestionType.trueFalse
            : QuestionType.multipleChoice,
        options: (map['options'] as List?)?.map((e) => e.toString()).toList() ?? const [],
        correctAnswer: map['correct_answer'] as String,
        explanation: map['explanation'] as String?,
      );
}

class Quiz {
  final String id;
  final String studySpaceId;
  final String title;
  final QuizDifficulty difficulty;
  final List<QuizQuestion> questions;

  const Quiz({
    required this.id,
    required this.studySpaceId,
    required this.title,
    required this.difficulty,
    this.questions = const [],
  });

  factory Quiz.fromMap(Map<String, dynamic> map, {List<QuizQuestion> questions = const []}) => Quiz(
        id: map['id'] as String,
        studySpaceId: map['study_space_id'] as String,
        title: map['title'] as String,
        difficulty: QuizDifficulty.values.firstWhere(
          (d) => d.name == (map['difficulty'] as String? ?? 'medium'),
          orElse: () => QuizDifficulty.medium,
        ),
        questions: questions,
      );
}
