class UserProfile {
  final String id;
  final String? fullName;
  final String? avatarUrl;
  final int dailyGoalMinutes;
  final String defaultQuizDifficulty;
  final int preferredFlashcardCount;

  const UserProfile({
    required this.id,
    this.fullName,
    this.avatarUrl,
    this.dailyGoalMinutes = 30,
    this.defaultQuizDifficulty = 'medium',
    this.preferredFlashcardCount = 20,
  });

  factory UserProfile.fromMap(Map<String, dynamic> map) => UserProfile(
        id: map['id'] as String,
        fullName: map['full_name'] as String?,
        avatarUrl: map['avatar_url'] as String?,
        dailyGoalMinutes: (map['daily_goal_minutes'] as num?)?.toInt() ?? 30,
        defaultQuizDifficulty: map['default_quiz_difficulty'] as String? ?? 'medium',
        preferredFlashcardCount: (map['preferred_flashcard_count'] as num?)?.toInt() ?? 20,
      );
}
