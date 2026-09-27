import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

/// The horizontal row of quick-action cards on Home ("Upload Material",
/// "Create from Text", etc.) — a small icon over a label, not a Material
/// Chip, matching the prototype's `.quick-chip`.
class QuickChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const QuickChip({super.key, required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          width: 108,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.paperLine, width: 1.5),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, size: 20, color: AppColors.ink),
              const SizedBox(height: 10),
              Text(
                label,
                maxLines: 2,
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, height: 1.2),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
