import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers/supabase_provider.dart';
import '../../../models/user_profile.dart';

/// The signed-in user's profile row (display name, avatar, study
/// preferences). Null while signed out.
final profileProvider = FutureProvider.autoDispose<UserProfile?>((ref) async {
  final client = ref.watch(supabaseClientProvider);
  final userId = ref.watch(currentUserIdProvider);
  if (userId == null) return null;

  final row = await client.from('profiles').select().eq('id', userId).maybeSingle();
  if (row == null) return null;
  return UserProfile.fromMap(row);
});

/// The signed-in user's email, straight from the auth session rather than
/// the profiles table (profiles doesn't store it).
final currentUserEmailProvider = Provider<String?>((ref) {
  final client = ref.watch(supabaseClientProvider);
  ref.watch(authStateProvider);
  return client.auth.currentUser?.email;
});

class ProfileRepository {
  final Ref _ref;
  const ProfileRepository(this._ref);

  Future<void> updatePreferences({
    int? dailyGoalMinutes,
    String? defaultQuizDifficulty,
    int? preferredFlashcardCount,
  }) async {
    final client = _ref.read(supabaseClientProvider);
    final userId = _ref.read(currentUserIdProvider);
    if (userId == null) return;

    final update = <String, dynamic>{'updated_at': DateTime.now().toIso8601String()};
    if (dailyGoalMinutes != null) update['daily_goal_minutes'] = dailyGoalMinutes;
    if (defaultQuizDifficulty != null) update['default_quiz_difficulty'] = defaultQuizDifficulty;
    if (preferredFlashcardCount != null) update['preferred_flashcard_count'] = preferredFlashcardCount;

    await client.from('profiles').update(update).eq('id', userId);
    _ref.invalidate(profileProvider);
  }
}

final profileRepositoryProvider = Provider<ProfileRepository>((ref) {
  return ProfileRepository(ref);
});
