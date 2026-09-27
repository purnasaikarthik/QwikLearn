import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

/// Bottom navigation matching the prototype: a floating ink pill with four
/// tab items and a raised highlighter-yellow "+" button in the middle that
/// opens the create sheet rather than navigating to a tab.
class AppShell extends StatelessWidget {
  final Widget child;
  final int currentIndex;
  final ValueChanged<int> onTap;
  final VoidCallback onCreateTap;

  const AppShell({
    super.key,
    required this.child,
    required this.currentIndex,
    required this.onTap,
    required this.onCreateTap,
  });

  static final _items = [
    (icon: Icons.grid_view_rounded, label: 'Home'),
    (icon: Icons.style_outlined, label: 'Learning'),
    (icon: Icons.insights_rounded, label: 'Progress'),
    (icon: Icons.person_outline_rounded, label: 'Profile'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: child,
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.fromLTRB(14, 0, 14, 16),
        child: Container(
          height: 66,
          decoration: BoxDecoration(
            color: AppColors.ink,
            borderRadius: BorderRadius.circular(26),
            boxShadow: [
              BoxShadow(color: AppColors.ink.withValues(alpha: 0.5), blurRadius: 30, offset: const Offset(0, 16)),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _NavItem(item: _items[0], active: currentIndex == 0, onTap: () => onTap(0)),
              _NavItem(item: _items[1], active: currentIndex == 1, onTap: () => onTap(1)),
              _CreateButton(onTap: onCreateTap),
              _NavItem(item: _items[2], active: currentIndex == 2, onTap: () => onTap(2)),
              _NavItem(item: _items[3], active: currentIndex == 3, onTap: () => onTap(3)),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final ({IconData icon, String label}) item;
  final bool active;
  final VoidCallback onTap;

  const _NavItem({required this.item, required this.active, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final color = active ? AppColors.highlight : AppColors.paper.withValues(alpha: 0.55);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(item.icon, color: color, size: 21),
            const SizedBox(height: 4),
            Text(
              item.label,
              style: TextStyle(color: color, fontSize: 9.5, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }
}

class _CreateButton extends StatelessWidget {
  final VoidCallback onTap;
  const _CreateButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Transform.translate(
        offset: const Offset(0, -28),
        child: Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            color: AppColors.highlight,
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.paper, width: 5),
            boxShadow: [
              BoxShadow(color: AppColors.highlight.withValues(alpha: 0.55), blurRadius: 22, offset: const Offset(0, 10)),
            ],
          ),
          child: const Icon(Icons.add_rounded, color: AppColors.ink, size: 26),
        ),
      ),
    );
  }
}
