import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers/supabase_provider.dart';

/// One recent quiz attempt, flattened for display.
class RecentQuizAttempt {
  final String quizTitle;
  final int score;
  final int totalQuestions;
  final DateTime completedAt;

  const RecentQuizAttempt({
    required this.quizTitle,
    required this.score,
    required this.totalQuestions,
    required this.completedAt,
  });
}

/// Everything the Progress screen needs, derived from what the user has
/// actually done — no placeholder numbers. Weekly activity and streak are
/// approximated from flashcard reviews + quiz attempts, since the schema
/// doesn't keep a separate daily study-session log.
class ProgressData {
  final int totalStudyTimeSeconds;
  final int totalFlashcardsReviewed;
  final int totalQuizzesCompleted;
  final List<int> weeklyActivity; // 7 entries, Monday first
  final int streakDays;
  final Map<String, double> masteryBySubject; // 0..1
  final List<RecentQuizAttempt> recentAttempts;

  const ProgressData({
    this.totalStudyTimeSeconds = 0,
    this.totalFlashcardsReviewed = 0,
    this.totalQuizzesCompleted = 0,
    this.weeklyActivity = const [0, 0, 0, 0, 0, 0, 0],
    this.streakDays = 0,
    this.masteryBySubject = const {},
    this.recentAttempts = const [],
  });
}

final progressDataProvider = FutureProvider.autoDispose<ProgressData>((ref) async {
  final client = ref.watch(supabaseClientProvider);
  final userId = ref.watch(currentUserIdProvider);
  if (userId == null) return const ProgressData();

  // Aggregate totals + subject lookup.
  final spaceRows = await client.from('study_spaces').select('id,subject').eq('user_id', userId);
  final subjectById = <String, String>{
    for (final row in (spaceRows as List)) (row['id'] as String): (row['subject'] as String? ?? 'General'),
  };

  final progressRows = await client
      .from('learning_progress')
      .select('study_time_seconds,flashcards_reviewed,quizzes_completed')
      .eq('user_id', userId);

  var totalStudyTime = 0, totalFlashcards = 0, totalQuizzes = 0;
  for (final row in (progressRows as List)) {
    totalStudyTime += (row['study_time_seconds'] as num?)?.toInt() ?? 0;
    totalFlashcards += (row['flashcards_reviewed'] as num?)?.toInt() ?? 0;
    totalQuizzes += (row['quizzes_completed'] as num?)?.toInt() ?? 0;
  }

  // Quiz attempts (recent history) drive weekly activity, streak, mastery
  // and the "recent quizzes" list.
  final attemptRows = await client
      .from('quiz_attempts')
      .select('score,total_questions,completed_at,quizzes(study_space_id,title)')
      .eq('user_id', userId)
      .order('completed_at', ascending: false)
      .limit(200);

  // Flashcard reviews also count as activity for streak/weekly purposes.
  final flashcardRows = await client
      .from('flashcards')
      .select('last_reviewed_at')
      .eq('user_id', userId)
      .not('last_reviewed_at', 'is', null)
      .order('last_reviewed_at', ascending: false)
      .limit(200);

  final activityDates = <DateTime>[];
  final weeklyActivity = List<int>.filled(7, 0);
  final now = DateTime.now();
  final startOfWeek = DateTime(now.year, now.month, now.day).subtract(Duration(days: now.weekday - 1));

  final recentAttempts = <RecentQuizAttempt>[];
  final subjectScore = <String, int>{};
  final subjectTotal = <String, int>{};

  for (final row in (attemptRows as List)) {
    final completedAt = DateTime.tryParse(row['completed_at'] as String? ?? '') ?? now;
    activityDates.add(completedAt);

    final dayIndex = completedAt.difference(startOfWeek).inDays;
    if (dayIndex >= 0 && dayIndex < 7) weeklyActivity[dayIndex]++;

    final quizMeta = row['quizzes'] as Map<String, dynamic>?;
    final spaceId = quizMeta?['study_space_id'] as String?;
    final subject = subjectById[spaceId] ?? 'General';
    final score = (row['score'] as num?)?.toInt() ?? 0;
    final total = (row['total_questions'] as num?)?.toInt() ?? 0;
    subjectScore[subject] = (subjectScore[subject] ?? 0) + score;
    subjectTotal[subject] = (subjectTotal[subject] ?? 0) + total;

    if (recentAttempts.length < 5) {
      recentAttempts.add(RecentQuizAttempt(
        quizTitle: quizMeta?['title'] as String? ?? 'Quiz',
        score: score,
        totalQuestions: total,
        completedAt: completedAt,
      ));
    }
  }

  for (final row in (flashcardRows as List)) {
    final reviewedAt = DateTime.tryParse(row['last_reviewed_at'] as String? ?? '');
    if (reviewedAt == null) continue;
    activityDates.add(reviewedAt);
    final dayIndex = reviewedAt.difference(startOfWeek).inDays;
    if (dayIndex >= 0 && dayIndex < 7) weeklyActivity[dayIndex]++;
  }

  final mastery = <String, double>{
    for (final subject in subjectTotal.keys)
      if ((subjectTotal[subject] ?? 0) > 0) subject: (subjectScore[subject] ?? 0) / subjectTotal[subject]!,
  };

  // Streak: consecutive calendar days with any activity, walking back from
  // today (today missing yet doesn't break yesterday's streak).
  final activeDays = activityDates.map((d) => DateTime(d.year, d.month, d.day)).toSet();
  var cursor = DateTime(now.year, now.month, now.day);
  if (!activeDays.contains(cursor)) cursor = cursor.subtract(const Duration(days: 1));
  var streak = 0;
  while (activeDays.contains(cursor)) {
    streak++;
    cursor = cursor.subtract(const Duration(days: 1));
  }

  return ProgressData(
    totalStudyTimeSeconds: totalStudyTime,
    totalFlashcardsReviewed: totalFlashcards,
    totalQuizzesCompleted: totalQuizzes,
    weeklyActivity: weeklyActivity,
    streakDays: streak,
    masteryBySubject: mastery,
    recentAttempts: recentAttempts,
  );
});
