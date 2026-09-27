import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/app_colors.dart';

/// A single number+label pair rendered in IBM Plex Mono, per the rule that
/// everything numeric on QwikLearn reads like a scoreboard.
class StatDisplay extends StatelessWidget {
  final String value;
  final String label;
  final Color? valueColor;
  final double size;
  final CrossAxisAlignment alignment;

  const StatDisplay({
    super.key,
    required this.value,
    required this.label,
    this.valueColor,
    this.size = 28,
    this.alignment = CrossAxisAlignment.start,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: alignment,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(value, style: AppTheme.statNumber(size: size, color: valueColor)),
        const SizedBox(height: 2),
        Text(label.toUpperCase(), style: AppTheme.statLabel()),
      ],
    );
  }
}

/// Circular "daily goal" ring — dial styling instead of a plain
/// CircularProgressIndicator, drawn with a highlighter-colored stroke.
class GoalRing extends StatelessWidget {
  final double value; // 0..1
  final double size;
  final String centerValue;
  final String centerLabel;

  const GoalRing({
    super.key,
    required this.value,
    this.size = 96,
    required this.centerValue,
    required this.centerLabel,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            width: size,
            height: size,
            child: CircularProgressIndicator(
              value: value.clamp(0.0, 1.0),
              strokeWidth: 8,
              strokeCap: StrokeCap.round,
              backgroundColor: AppColors.paperLine,
              valueColor: const AlwaysStoppedAnimation(AppColors.highlight),
            ),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(centerValue, style: AppTheme.statNumber(size: 20)),
              Text(centerLabel.toUpperCase(), style: AppTheme.statLabel()),
            ],
          ),
        ],
      ),
    );
  }
}
