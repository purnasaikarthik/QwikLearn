import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/providers/supabase_provider.dart';
import '../../home/providers/recent_materials_provider.dart';
import '../providers/study_space_provider.dart';

/// Uploads a picked file into a study space: stores the bytes in the
/// private `study-materials` bucket (under the user's own folder, per the
/// bucket's RLS policy) and records a row in `study_materials`.
///
/// Only handles the raw upload + bookkeeping — there's no text-extraction
/// or AI summarization step yet, so `content` is left null. That's a
/// separate, honestly-scoped future enhancement.
class MaterialUploadRepository {
  final Ref _ref;
  const MaterialUploadRepository(this._ref);

  Future<void> uploadFile({
    required String studySpaceId,
    required String fileName,
    required List<int> bytes,
    required String materialType,
  }) async {
    final client = _ref.read(supabaseClientProvider);
    final userId = _ref.read(currentUserIdProvider);
    if (userId == null) throw Exception('You need to be signed in to upload a file.');

    final storagePath = '$userId/${DateTime.now().millisecondsSinceEpoch}_$fileName';

    await client.storage.from('study-materials').uploadBinary(
          storagePath,
          Uint8List.fromList(bytes),
          fileOptions: const FileOptions(upsert: true),
        );

    await client.from('study_materials').insert({
      'study_space_id': studySpaceId,
      'user_id': userId,
      'title': fileName,
      'material_type': materialType,
      'file_url': storagePath,
    });

    _ref.invalidate(recentMaterialsProvider);
    _ref.invalidate(spaceMaterialCountProvider(studySpaceId));
  }
}

final materialUploadRepositoryProvider = Provider<MaterialUploadRepository>((ref) {
  return MaterialUploadRepository(ref);
});
