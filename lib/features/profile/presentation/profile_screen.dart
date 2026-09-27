import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../auth/providers/auth_provider.dart';
import '../providers/profile_provider.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(profileProvider);
    final email = ref.watch(currentUserEmailProvider) ?? '';

    return Scaffold(
      body: SafeArea(
        child: profileAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text('Could not load your profile.\n$e', textAlign: TextAlign.center)),
          data: (profile) {
            final name = (profile?.fullName?.trim().isNotEmpty ?? false) ? profile!.fullName!.trim() : 'Your name';
            final initial = name.isNotEmpty ? name[0].toUpperCase() : '?';
            final dailyGoal = profile?.dailyGoalMinutes ?? 30;
            final quizDifficulty = profile?.defaultQuizDifficulty ?? 'medium';
            final cardsPerDeck = profile?.preferredFlashcardCount ?? 20;

            return ListView(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 100),
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 32,
                      backgroundColor: AppColors.lavender,
                      child: Text(initial, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w700, color: AppColors.ink)),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(name, style: Theme.of(context).textTheme.headlineMedium, overflow: TextOverflow.ellipsis),
                          const SizedBox(height: 2),
                          Text(email, style: Theme.of(context).textTheme.bodyMedium, overflow: TextOverflow.ellipsis),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 28),
                _SettingsRow(
                  icon: Icons.flag_outlined,
                  label: 'Daily goal',
                  value: '$dailyGoal min',
                  onTap: () => _editNumberDialog(
                    context, ref,
                    title: 'Daily goal (minutes)',
                    initial: dailyGoal,
                    onSave: (v) => ref.read(profileRepositoryProvider).updatePreferences(dailyGoalMinutes: v),
                  ),
                ),
                _SettingsRow(
                  icon: Icons.quiz_outlined,
                  label: 'Default quiz difficulty',
                  value: quizDifficulty[0].toUpperCase() + quizDifficulty.substring(1),
                  onTap: () => _editDifficultyDialog(context, ref, current: quizDifficulty),
                ),
                _SettingsRow(
                  icon: Icons.style_outlined,
                  label: 'Cards per deck',
                  value: '$cardsPerDeck',
                  onTap: () => _editNumberDialog(
                    context, ref,
                    title: 'Cards per deck',
                    initial: cardsPerDeck,
                    onSave: (v) => ref.read(profileRepositoryProvider).updatePreferences(preferredFlashcardCount: v),
                  ),
                ),
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  onPressed: () async {
                    await ref.read(authServiceProvider).signOut();
                    if (context.mounted) context.go('/welcome');
                  },
                  icon: const Icon(Icons.logout_rounded, color: AppColors.coral),
                  label: const Text('Sign out', style: TextStyle(color: AppColors.coral)),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppColors.coral),
                    minimumSize: const Size.fromHeight(52),
                  ),
                ),
                const SizedBox(height: 16),
                Center(
                  child: Text(
                    'QwikLearn v1.0.0',
                    style: TextStyle(fontFamily: 'monospace', fontSize: 11, color: AppColors.inkSoft.withValues(alpha: 0.7)),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  void _editNumberDialog(
    BuildContext context,
    WidgetRef ref, {
    required String title,
    required int initial,
    required Future<void> Function(int) onSave,
  }) {
    final ctrl = TextEditingController(text: '$initial');
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: TextField(
          controller: ctrl,
          keyboardType: TextInputType.number,
          autofocus: true,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Cancel')),
          TextButton(
            onPressed: () async {
              final value = int.tryParse(ctrl.text.trim());
              Navigator.of(ctx).pop();
              if (value != null) await onSave(value);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _editDifficultyDialog(BuildContext context, WidgetRef ref, {required String current}) {
    showDialog(
      context: context,
      builder: (ctx) => SimpleDialog(
        title: const Text('Default quiz difficulty'),
        children: ['easy', 'medium', 'hard'].map((d) {
          return SimpleDialogOption(
            onPressed: () async {
              Navigator.of(ctx).pop();
              await ref.read(profileRepositoryProvider).updatePreferences(defaultQuizDifficulty: d);
            },
            child: Text(d[0].toUpperCase() + d.substring(1)),
          );
        }).toList(),
      ),
    );
  }
}

class _SettingsRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final VoidCallback onTap;

  const _SettingsRow({required this.icon, required this.label, required this.value, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: AppColors.paperDim,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                Icon(icon, color: AppColors.inkSoft, size: 20),
                const SizedBox(width: 14),
                Expanded(child: Text(label, style: Theme.of(context).textTheme.bodyLarge)),
                Text(value, style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(width: 4),
                const Icon(Icons.chevron_right_rounded, color: AppColors.inkSoft, size: 18),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
