import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/constants/enums.dart';

IconData _iconFor(StudyMaterialType type) => switch (type) {
      StudyMaterialType.pdf => Icons.picture_as_pdf_outlined,
      StudyMaterialType.text => Icons.edit_note_rounded,
      StudyMaterialType.article => Icons.public_rounded,
      StudyMaterialType.youtube => Icons.play_circle_outline_rounded,
      StudyMaterialType.audio => Icons.graphic_eq_rounded,
    };

/// A single row in Home's "Recent Materials" list — file-type icon, title,
/// and a short meta line, matching the prototype's `.material-row`.
class MaterialRow extends StatelessWidget {
  final String title;
  final String meta;
  final StudyMaterialType type;

  const MaterialRow({super.key, required this.title, required this.meta, required this.type});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: AppColors.paperLine, width: 1.5),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            alignment: Alignment.center,
            decoration: BoxDecoration(color: AppColors.paperDim, borderRadius: BorderRadius.circular(10)),
            child: Icon(_iconFor(type), size: 17, color: AppColors.ink),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, maxLines: 1, overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                const SizedBox(height: 2),
                Text(meta, style: const TextStyle(fontSize: 11, color: AppColors.inkSoft)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
