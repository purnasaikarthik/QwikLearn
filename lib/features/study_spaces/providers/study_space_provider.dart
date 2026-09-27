import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers/supabase_provider.dart';
import '../../../models/study_space.dart';

/// The signed-in user's study spaces, freshest first. Call
/// `ref.invalidate(studySpacesProvider)` after creating or deleting a space
/// to refresh the list.
final studySpacesProvider = FutureProvider.autoDispose<List<StudySpace>>((ref) async {
  final client = ref.watch(supabaseClientProvider);
  final userId = ref.watch(currentUserIdProvider);
  if (userId == null) return const [];

  final rows = await client
      .from('study_spaces')
      .select()
      .eq('user_id', userId)
      .order('created_at', ascending: false);

  return (rows as List)
      .map((e) => StudySpace.fromMap(e as Map<String, dynamic>))
      .toList();
});

/// A single study space by id — used on the detail screen so it doesn't
/// need to wait for (or search through) the full list.
final studySpaceByIdProvider = FutureProvider.autoDispose.family<StudySpace?, String>((ref, id) async {
  final client = ref.watch(supabaseClientProvider);
  final row = await client.from('study_spaces').select().eq('id', id).maybeSingle();
  if (row == null) return null;
  return StudySpace.fromMap(row);
});

/// Creating / mutating study spaces goes through here so the UI never talks
/// to Supabase directly.
class StudySpaceRepository {
  final Ref _ref;
  const StudySpaceRepository(this._ref);

  Future<String> create({required String title, String? subject, String? description}) async {
    final client = _ref.read(supabaseClientProvider);
    final userId = _ref.read(currentUserIdProvider);
    if (userId == null) throw Exception('You need to be signed in to create a study space.');

    final row = await client
        .from('study_spaces')
        .insert({
          'user_id': userId,
          'title': title,
          'subject': subject,
          'description': description,
        })
        .select('id')
        .single();

    _ref.invalidate(studySpacesProvider);
    return row['id'] as String;
  }
}

final studySpaceRepositoryProvider = Provider<StudySpaceRepository>((ref) {
  return StudySpaceRepository(ref);
});

/// A study space's completion, approximated as flashcards reviewed over
/// flashcards available (the schema has no explicit "percent complete"
/// column, so this stays honest about what's actually measurable: 0 when
/// there's nothing to review yet, otherwise a real ratio).
final spaceProgressProvider = FutureProvider.autoDispose.family<double, String>((ref, spaceId) async {
  final client = ref.watch(supabaseClientProvider);
  final userId = ref.watch(currentUserIdProvider);
  if (userId == null) return 0;

  final totalRows = await client.from('flashcards').select('id').eq('study_space_id', spaceId);
  final total = (totalRows as List).length;
  if (total == 0) return 0;

  final progressRow = await client
      .from('learning_progress')
      .select('flashcards_reviewed')
      .eq('user_id', userId)
      .eq('study_space_id', spaceId)
      .maybeSingle();

  final reviewed = (progressRow?['flashcards_reviewed'] as num?)?.toInt() ?? 0;
  return (reviewed / total).clamp(0.0, 1.0).toDouble();
});

/// How many materials have been added to a study space — used on the
/// Learning list's card footer ("12 materials").
final spaceMaterialCountProvider = FutureProvider.autoDispose.family<int, String>((ref, spaceId) async {
  final client = ref.watch(supabaseClientProvider);
  final rows = await client.from('study_materials').select('id').eq('study_space_id', spaceId);
  return (rows as List).length;
});

/// "Resources" on the study-space header = generated artifacts (notes +
/// summaries + key concepts) rather than raw uploaded materials.
final spaceResourceCountProvider = FutureProvider.autoDispose.family<int, String>((ref, spaceId) async {
  final client = ref.watch(supabaseClientProvider);
  final notes = await client.from('notes').select('id').eq('study_space_id', spaceId);
  final summaries = await client.from('summaries').select('id').eq('study_space_id', spaceId);
  final concepts = await client.from('key_concepts').select('id').eq('study_space_id', spaceId);
  return (notes as List).length + (summaries as List).length + (concepts as List).length;
});
