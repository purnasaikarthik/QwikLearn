import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers/supabase_provider.dart';
import '../../../models/study_material.dart';

/// The user's 3 most recently added materials across every study space, for
/// the "Recent Materials" section on Home.
final recentMaterialsProvider = FutureProvider.autoDispose<List<StudyMaterial>>((ref) async {
  final client = ref.watch(supabaseClientProvider);
  final userId = ref.watch(currentUserIdProvider);
  if (userId == null) return const [];

  final rows = await client
      .from('study_materials')
      .select()
      .eq('user_id', userId)
      .order('created_at', ascending: false)
      .limit(3);

  return (rows as List)
      .map((e) => StudyMaterial.fromMap(e as Map<String, dynamic>))
      .toList();
});
