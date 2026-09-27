class LearningProgress {
  final String studySpaceId;
  final int studyTimeSeconds;
  final int flashcardsReviewed;
  final int quizzesCompleted;

  const LearningProgress({
    required this.studySpaceId,
    this.studyTimeSeconds = 0,
    this.flashcardsReviewed = 0,
    this.quizzesCompleted = 0,
  });

  factory LearningProgress.fromMap(Map<String, dynamic> map) => LearningProgress(
        studySpaceId: map['study_space_id'] as String,
        studyTimeSeconds: (map['study_time_seconds'] as num?)?.toInt() ?? 0,
        flashcardsReviewed: (map['flashcards_reviewed'] as num?)?.toInt() ?? 0,
        quizzesCompleted: (map['quizzes_completed'] as num?)?.toInt() ?? 0,
      );
}
