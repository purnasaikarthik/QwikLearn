import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

/// The signature "highlighter swipe" — a crooked marker-stroke rectangle
/// drawn behind text or behind a progress fill. Slightly rotated and with
/// a soft, felt-tip-uneven right edge so it never looks like a plain
/// rounded-rect chip.
class HighlighterSwipe extends StatelessWidget {
  final Widget child;
  final Color color;
  final double angleDegrees;
  final EdgeInsetsGeometry padding;

  const HighlighterSwipe({
    super.key,
    required this.child,
    this.color = AppColors.highlight,
    this.angleDegrees = -1.4,
    this.padding = const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Positioned.fill(
          child: Transform.rotate(
            angle: angleDegrees * 3.1415926535 / 180,
            child: CustomPaint(painter: _SwipePainter(color: color)),
          ),
        ),
        Padding(padding: padding, child: child),
      ],
    );
  }
}

class _SwipePainter extends CustomPainter {
  final Color color;
  const _SwipePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color.withValues(alpha: 0.85);
    final path = Path()
      ..moveTo(0, size.height * 0.12)
      ..lineTo(size.width * 0.98, 0)
      ..lineTo(size.width, size.height * 0.78)
      ..lineTo(size.width * 0.03, size.height)
      ..close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _SwipePainter oldDelegate) => oldDelegate.color != color;
}

/// A horizontal progress bar drawn as a growing highlighter stroke rather
/// than a rounded Material bar — used on study space cards, streaks, and
/// the daily-goal ring's linear cousin.
class HighlighterProgressBar extends StatelessWidget {
  final double value; // 0..1
  final double height;
  final Color trackColor;
  final Color fillColor;

  const HighlighterProgressBar({
    super.key,
    required this.value,
    this.height = 10,
    this.trackColor = AppColors.paperLine,
    this.fillColor = AppColors.highlight,
  });

  @override
  Widget build(BuildContext context) {
    final clamped = value.clamp(0.0, 1.0);
    return LayoutBuilder(
      builder: (context, constraints) {
        return Stack(
          children: [
            Container(
              height: height,
              width: double.infinity,
              decoration: BoxDecoration(
                color: trackColor,
                borderRadius: BorderRadius.circular(height),
              ),
            ),
            AnimatedContainer(
              duration: const Duration(milliseconds: 500),
              curve: Curves.easeOutCubic,
              height: height,
              width: constraints.maxWidth * clamped,
              decoration: BoxDecoration(
                color: fillColor,
                borderRadius: BorderRadius.circular(height),
              ),
            ),
          ],
        );
      },
    );
  }
}
