import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../providers/study_space_provider.dart';
import 'upload_material_flow.dart';

/// The bottom sheet opened by the nav bar's "+" button, matching the
/// prototype's create sheet. "Upload PDF" and "Add Text" both create real
/// study spaces / materials — "Paste Article" still needs a processing
/// pipeline that doesn't exist yet, so it shows a "coming soon" note.
///
/// Takes only a [BuildContext] (no WidgetRef) so it can be opened from
/// anywhere, including the router's nav shell where only a plain [Ref] is
/// available — provider access happens via [ProviderScope.containerOf].
Future<void> showCreateSheet(BuildContext context) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppColors.paper,
    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
    builder: (sheetCtx) {
      return SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(22, 14, 22, 28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 18),
                  decoration: BoxDecoration(color: AppColors.paperLine, borderRadius: BorderRadius.circular(2)),
                ),
              ),
              Text('Create Your Study Space', style: Theme.of(sheetCtx).textTheme.headlineMedium),
              const SizedBox(height: 6),
              _SheetOption(
                icon: Icons.picture_as_pdf_outlined,
                title: 'Upload PDF',
                subtitle: 'Import a document to extract content',
                onTap: () {
                  Navigator.of(sheetCtx).pop();
                  startPdfUpload(context);
                },
              ),
              _SheetOption(
                icon: Icons.edit_note_rounded,
                title: 'Add Text',
                subtitle: 'Paste or type your notes',
                onTap: () {
                  Navigator.of(sheetCtx).pop();
                  _showQuickCreateDialog(context);
                },
              ),
              _SheetOption(
                icon: Icons.public_rounded,
                title: 'Paste Article',
                subtitle: 'Save web content directly',
                onTap: () {
                  Navigator.of(sheetCtx).pop();
                  _comingSoon(context);
                },
                showDivider: false,
              ),
            ],
          ),
        ),
      );
    },
  );
}

void _comingSoon(BuildContext context) {
  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(content: Text('Coming soon — for now, try "Add Text" to create a study space.')),
  );
}

void _showQuickCreateDialog(BuildContext context) {
  final titleCtrl = TextEditingController();
  final subjectCtrl = TextEditingController();
  showModalBottomSheet(
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
            Container(
              width: 40, height: 4,
              decoration: BoxDecoration(color: AppColors.paperLine, borderRadius: BorderRadius.circular(2)),
              margin: const EdgeInsets.only(bottom: 20),
              alignment: Alignment.center,
            ),
            Text('New study space', style: Theme.of(ctx).textTheme.headlineMedium),
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
                  final repo = ProviderScope.containerOf(ctx).read(studySpaceRepositoryProvider);
                  try {
                    await repo.create(
                      title: titleCtrl.text.trim(),
                      subject: subjectCtrl.text.trim().isEmpty ? null : subjectCtrl.text.trim(),
                    );
                    if (ctx.mounted) Navigator.of(ctx).pop();
                  } catch (e) {
                    if (ctx.mounted) {
                      ScaffoldMessenger.of(ctx).showSnackBar(
                        SnackBar(content: Text('Could not create space: $e')),
                      );
                    }
                  }
                },
                child: const Text('Create space'),
              ),
            ),
          ],
        ),
      );
    },
  );
}

class _SheetOption extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final bool showDivider;

  const _SheetOption({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.showDivider = true,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          border: showDivider ? const Border(bottom: BorderSide(color: AppColors.paperLine)) : null,
        ),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              alignment: Alignment.center,
              decoration: BoxDecoration(color: AppColors.paperDim, borderRadius: BorderRadius.circular(12)),
              child: Icon(icon, size: 19, color: AppColors.ink),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 2),
                  Text(subtitle, style: const TextStyle(fontSize: 11.5, color: AppColors.inkSoft)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
