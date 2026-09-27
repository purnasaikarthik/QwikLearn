import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

/// Three punched binder holes down the left edge of a card — the recurring
/// "index card" detail used across study space cards, flashcards, and
/// material tiles.
class BinderHoles extends StatelessWidget {
  final double holeSize;
  final Color? holeColor;
  final Color? ringColor;

  const BinderHoles({super.key, this.holeSize = 10, this.holeColor, this.ringColor});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: holeSize + 8,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: List.generate(3, (_) => _hole()),
      ),
    );
  }

  Widget _hole() {
    return Container(
      width: holeSize,
      height: holeSize,
      decoration: BoxDecoration(
        color: holeColor ?? AppColors.paper,
        shape: BoxShape.circle,
        border: Border.all(color: ringColor ?? AppColors.paperLine, width: 1.2),
      ),
    );
  }
}

/// Wraps a child in a card with a binder-hole gutter on the left —
/// the base shape for study space cards and flashcard fronts.
class BinderCard extends StatelessWidget {
  final Widget child;
  final Color background;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;

  const BinderCard({
    super.key,
    required this.child,
    this.background = AppColors.paperDim,
    this.padding = const EdgeInsets.all(18),
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: background,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.paperLine, width: 1),
          ),
          padding: padding.add(const EdgeInsets.only(left: 4)),
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const BinderHoles(),
                const SizedBox(width: 10),
                Expanded(child: child),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
