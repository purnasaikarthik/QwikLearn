import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers/supabase_provider.dart';
import '../../../models/flashcard.dart';

/// The flashcard deck for one study space, ordered by creation so review
/// order stays predictable.
final flashcardsProvider = FutureProvider.autoDispose.family<List<Flashcard>, String>((ref, spaceId) async {
  final client = ref.watch(supabaseClientProvider);
  final rows = await client
      .from('flashcards')
      .select()
      .eq('study_space_id', spaceId)
      .order('created_at');

  return (rows as List)
      .map((e) => Flashcard.fromMap(e as Map<String, dynamic>))
      .toList();
});

/// Recording a review goes through here: it stamps the card as reviewed and
/// nudges the study space's aggregate progress row, so Progress screen
/// numbers stay grounded in what actually happened.
class FlashcardRepository {
  final Ref _ref;
  const FlashcardRepository(this._ref);

  Future<void> markReviewed(String cardId, String studySpaceId) async {
    final client = _ref.read(supabaseClientProvider);
    final userId = _ref.read(currentUserIdProvider);
    if (userId == null) return;

    await client
        .from('flashcards')
        .update({'last_reviewed_at': DateTime.now().toIso8601String()})
        .eq('id', cardId);

    final existing = await client
        .from('learning_progress')
        .select('flashcards_reviewed')
        .eq('user_id', userId)
        .eq('study_space_id', studySpaceId)
        .maybeSingle();

    final current = (existing?['flashcards_reviewed'] as num?)?.toInt() ?? 0;

    await client.from('learning_progress').upsert({
      'user_id': userId,
      'study_space_id': studySpaceId,
      'flashcards_reviewed': current + 1,
      'updated_at': DateTime.now().toIso8601String(),
    }, onConflict: 'user_id,study_space_id');
  }
}

final flashcardRepositoryProvider = Provider<FlashcardRepository>((ref) {
  return FlashcardRepository(ref);
});
