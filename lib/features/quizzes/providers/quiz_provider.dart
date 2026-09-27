import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers/supabase_provider.dart';
import '../../../models/quiz.dart';

/// The most recent quiz generated for a study space, questions included.
/// Returns null when the space has no quiz yet (the screen shows an empty
/// state rather than fabricated questions).
final quizProvider = FutureProvider.autoDispose.family<Quiz?, String>((ref, spaceId) async {
  final client = ref.watch(supabaseClientProvider);

  final quizRow = await client
      .from('quizzes')
      .select()
      .eq('study_space_id', spaceId)
      .order('created_at', ascending: false)
      .limit(1)
      .maybeSingle();

  if (quizRow == null) return null;

  final questionRows = await client
      .from('quiz_questions')
      .select()
      .eq('quiz_id', quizRow['id'] as String);

  final questions = (questionRows as List)
      .map((e) => QuizQuestion.fromMap(e as Map<String, dynamic>))
      .toList();

  return Quiz.fromMap(quizRow, questions: questions);
});

/// Saving a completed attempt goes through here: it records the score and
/// nudges the study space's aggregate progress, so Progress-screen numbers
/// are grounded in quizzes you actually took.
class QuizRepository {
  final Ref _ref;
  const QuizRepository(this._ref);

  Future<void> recordAttempt({
    required String quizId,
    required String studySpaceId,
    required int score,
    required int totalQuestions,
  }) async {
    final client = _ref.read(supabaseClientProvider);
    final userId = _ref.read(currentUserIdProvider);
    if (userId == null) return;

    await client.from('quiz_attempts').insert({
      'quiz_id': quizId,
      'user_id': userId,
      'score': score,
      'total_questions': totalQuestions,
    });

    final existing = await client
        .from('learning_progress')
        .select('quizzes_completed')
        .eq('user_id', userId)
        .eq('study_space_id', studySpaceId)
        .maybeSingle();

    final current = (existing?['quizzes_completed'] as num?)?.toInt() ?? 0;

    await client.from('learning_progress').upsert({
      'user_id': userId,
      'study_space_id': studySpaceId,
      'quizzes_completed': current + 1,
      'updated_at': DateTime.now().toIso8601String(),
    }, onConflict: 'user_id,study_space_id');
  }
}

final quizRepositoryProvider = Provider<QuizRepository>((ref) {
  return QuizRepository(ref);
});
