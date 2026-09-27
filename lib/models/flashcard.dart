import '../core/constants/enums.dart';

class Flashcard {
  final String id;
  final String studySpaceId;
  final String front;
  final String back;
  final CardDifficulty difficulty;
  final DateTime? lastReviewedAt;

  const Flashcard({
    required this.id,
    required this.studySpaceId,
    required this.front,
    required this.back,
    this.difficulty = CardDifficulty.medium,
    this.lastReviewedAt,
  });

  factory Flashcard.fromMap(Map<String, dynamic> map) => Flashcard(
        id: map['id'] as String,
        studySpaceId: map['study_space_id'] as String,
        front: map['front'] as String,
        back: map['back'] as String,
        difficulty: CardDifficulty.values.firstWhere(
          (d) => d.name == (map['difficulty'] as String? ?? 'medium'),
          orElse: () => CardDifficulty.medium,
        ),
        lastReviewedAt: map['last_reviewed_at'] != null
            ? DateTime.tryParse(map['last_reviewed_at'] as String)
            : null,
      );
}
