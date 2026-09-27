import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../data/material_upload_repository.dart';
import '../providers/study_space_provider.dart';

/// Entry point for the "Upload PDF" sheet option: picks a file, asks which
/// study space it belongs to (or creates one), uploads it to Supabase
/// Storage, and records it — then drops the person onto that study space.
Future<void> startPdfUpload(BuildContext context) async {
  final container = ProviderScope.containerOf(context);

  final result = await FilePicker.platform.pickFiles(
    type: FileType.custom,
    allowedExtensions: ['pdf'],
    withData: true,
  );
  if (result == null || result.files.isEmpty) return;

  final picked = result.files.single;
  final bytes = picked.bytes;
  if (bytes == null) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Couldn't read that file — please try again.")),
      );
    }
    return;
  }

  if (!context.mounted) return;
  final spaceId = await _pickOrCreateSpace(context);
  if (spaceId == null) return;

  if (!context.mounted) return;
  _showUploadingDialog(context);

  try {
    await container.read(materialUploadRepositoryProvider).uploadFile(
          studySpaceId: spaceId,
          fileName: picked.name,
          bytes: bytes,
          materialType: 'pdf',
        );
    if (context.mounted) {
      Navigator.of(context, rootNavigator: true).pop(); // close uploading dialog
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${picked.name} added.')),
      );
      context.push('/study-space/$spaceId');
    }
  } catch (e) {
    if (context.mounted) {
      Navigator.of(context, rootNavigator: true).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Upload failed: $e')),
      );
    }
  }
}

void _showUploadingDialog(BuildContext context) {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (_) => const AlertDialog(
      content: Row(
        children: [
          SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2.5)),
          SizedBox(width: 16),
          Text('Uploading...'),
        ],
      ),
    ),
  );
}

/// Shows existing study spaces to pick from, plus a "create new" option.
/// Returns the chosen/created study space's id, or null if cancelled.
Future<String?> _pickOrCreateSpace(BuildContext context) async {
  final container = ProviderScope.containerOf(context);
  final spaces = await container.read(studySpacesProvider.future);

  if (!context.mounted) return null;

  if (spaces.isEmpty) {
    return _createSpaceDialog(context);
  }

  const createNewSentinel = '__create_new__';

  final choice = await showModalBottomSheet<String>(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppColors.paper,
    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
    builder: (sheetCtx) {
      return SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(22, 18, 22, 18),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Add to which study space?', style: Theme.of(sheetCtx).textTheme.headlineMedium),
              const SizedBox(height: 12),
              ...spaces.map((s) => ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.auto_stories_outlined),
                    title: Text(s.title),
                    subtitle: s.subject != null ? Text(s.subject!) : null,
                    onTap: () => Navigator.of(sheetCtx).pop(s.id),
                  )),
              const Divider(),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.add_rounded),
                title: const Text('Create new study space'),
                onTap: () => Navigator.of(sheetCtx).pop(createNewSentinel),
              ),
            ],
          ),
        ),
      );
    },
  );

  if (choice == createNewSentinel) {
    if (!context.mounted) return null;
    return _createSpaceDialog(context);
  }
  return choice;
}

Future<String?> _createSpaceDialog(BuildContext context) async {
  final titleCtrl = TextEditingController();
  final subjectCtrl = TextEditingController();
  final container = ProviderScope.containerOf(context);

  return showModalBottomSheet<String>(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppColors.paper,
    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
    builder: (ctx) {
      return Padding(
        padding: EdgeInsets.only(
          left: 24, right: 24, top: 20,
          bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Name this study space', style: Theme.of(ctx).textTheme.headlineMedium),
            const SizedBox(height: 20),
            TextField(
              controller: titleCtrl,
              decoration: const InputDecoration(hintText: 'e.g. Organic Chemistry — Ch. 12'),
              autofocus: true,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: subjectCtrl,
              decoration: const InputDecoration(hintText: 'Subject (optional)'),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  if (titleCtrl.text.trim().isEmpty) return;
                  try {
                    final id = await container.read(studySpaceRepositoryProvider).create(
                          title: titleCtrl.text.trim(),
                          subject: subjectCtrl.text.trim().isEmpty ? null : subjectCtrl.text.trim(),
                        );
                    if (ctx.mounted) Navigator.of(ctx).pop(id);
                  } catch (e) {
                    if (ctx.mounted) {
                      ScaffoldMessenger.of(ctx).showSnackBar(
                        SnackBar(content: Text('Could not create space: $e')),
                      );
                    }
                  }
                },
                child: const Text('Continue'),
              ),
            ),
          ],
        ),
      );
    },
  );
}
