import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';

/// The dark "space card" from the prototype: an ink card with a subject
/// tag, title, highlighter progress bar, and a footer line with a percent
/// readout — used on Home's "Continue Learning" row and the full Learning
/// list.
class SpaceCard extends StatelessWidget {
  final String tag;
  final String title;
  final double progress; // 0..1
  final String footLeft;
  final VoidCallback onTap;

  const SpaceCard({
    super.key,
    required this.tag,
    required this.title,
    required this.progress,
    required this.footLeft,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final pct = (progress.clamp(0.0, 1.0) * 100).round();
    return Material(
      color: AppColors.ink,
      borderRadius: BorderRadius.circular(20),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Stack(
          children: [
            Positioned(
              right: -30,
              top: -30,
              child: Container(
                width: 110,
                height: 110,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.highlight.withValues(alpha: 0.08),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    tag.toUpperCase(),
                    style: const TextStyle(
                      fontSize: 10.5,
                      letterSpacing: 1,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFFB7B4D4),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: AppColors.paper),
                  ),
                  const SizedBox(height: 14),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(99),
                    child: LinearProgressIndicator(
                      value: progress.clamp(0.0, 1.0).toDouble(),
                      minHeight: 7,
                      backgroundColor: Colors.white.withValues(alpha: 0.14),
                      valueColor: const AlwaysStoppedAnimation(AppColors.highlight),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(footLeft, style: const TextStyle(fontSize: 11.5, color: Color(0xFFB7B4D4))),
                      Text('$pct%', style: AppTheme.statNumber(size: 13, color: AppColors.highlight)),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
