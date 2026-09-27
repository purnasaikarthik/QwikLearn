import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/space_card.dart';
import '../../../shared/widgets/quick_chip.dart';
import '../../../shared/widgets/material_row.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../study_spaces/providers/study_space_provider.dart';
import '../../study_spaces/presentation/new_study_space_sheet.dart';
import '../../profile/providers/profile_provider.dart';
import '../../progress/providers/progress_provider.dart';
import '../providers/recent_materials_provider.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  String _greeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(profileProvider);
    final spacesAsync = ref.watch(studySpacesProvider);
    final materialsAsync = ref.watch(recentMaterialsProvider);
    final activityAsync = ref.watch(progressDataProvider);

    final firstName = profileAsync.maybeWhen(
      data: (p) => (p?.fullName?.trim().isNotEmpty ?? false) ? p!.fullName!.trim().split(' ').first : 'there',
      orElse: () => '…',
    );
    final initial = firstName.isNotEmpty ? firstName[0].toUpperCase() : '?';

    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(studySpacesProvider);
            ref.invalidate(recentMaterialsProvider);
            ref.invalidate(progressDataProvider);
          },
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 110),
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('${_greeting()}, $firstName \ud83d\udc4b', style: Theme.of(context).textTheme.headlineMedium),
                        const SizedBox(height: 4),
                        Text('What would you like to learn today?', style: Theme.of(context).textTheme.bodyMedium),
                      ],
                    ),
                  ),
                  CircleAvatar(
                    radius: 21,
                    backgroundColor: AppColors.lavender,
                    child: Text(initial, style: const TextStyle(fontWeight: FontWeight.w700, color: AppColors.ink)),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              SizedBox(
                height: 94,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    QuickChip(
                      icon: Icons.description_outlined,
                      label: 'Upload Material',
                      onTap: () => showCreateSheet(context),
                    ),
                    const SizedBox(width: 10),
                    QuickChip(
                      icon: Icons.edit_note_rounded,
                      label: 'Create from Text',
                      onTap: () => showCreateSheet(context),
                    ),
                    const SizedBox(width: 10),
                    QuickChip(
                      icon: Icons.add_rounded,
                      label: 'Create Study Space',
                      onTap: () => showCreateSheet(context),
                    ),
                    const SizedBox(width: 10),
                    QuickChip(
                      icon: Icons.play_circle_outline_rounded,
                      label: 'Continue Learning',
                      onTap: () => context.go('/spaces'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Continue Learning', style: Theme.of(context).textTheme.titleLarge),
                  TextButton(onPressed: () => context.go('/spaces'), child: const Text('See all')),
                ],
              ),
              spacesAsync.when(
                loading: () => const Padding(
                  padding: EdgeInsets.symmetric(vertical: 20),
                  child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
                ),
                error: (e, _) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Text('Could not load your study spaces.', style: Theme.of(context).textTheme.bodyMedium),
                ),
                data: (spaces) {
                  if (spaces.isEmpty) {
                    return Padding(
                      padding: const EdgeInsets.only(top: 6, bottom: 6),
                      child: EmptyState(
                        icon: Icons.auto_stories_outlined,
                        title: 'No study spaces yet',
                        message: 'Create one from a PDF, pasted notes, or an article.',
                        actionLabel: 'Create Study Space',
                        onAction: () => showCreateSheet(context),
                      ),
                    );
                  }
                  final top = spaces.take(2).toList();
                  return Column(
                    children: top.map((space) {
                      final progressAsync = ref.watch(spaceProgressProvider(space.id));
                      final progress = progressAsync.maybeWhen(data: (p) => p, orElse: () => 0.0);
                      return Padding(
                        padding: const EdgeInsets.only(top: 12),
                        child: SpaceCard(
                          tag: space.subject ?? 'General',
                          title: space.title,
                          progress: progress,
                          footLeft: 'Updated ${DateFormat.MMMd().format(space.createdAt)}',
                          onTap: () => context.push('/study-space/${space.id}'),
                        ),
                      );
                    }).toList(),
                  );
                },
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Recent Materials', style: Theme.of(context).textTheme.titleLarge),
                ],
              ),
              const SizedBox(height: 8),
              materialsAsync.when(
                loading: () => const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
                ),
                error: (e, _) => const SizedBox.shrink(),
                data: (materials) {
                  if (materials.isEmpty) {
                    return Text(
                      'Materials you add will show up here.',
                      style: Theme.of(context).textTheme.bodyMedium,
                    );
                  }
                  return Column(
                    children: materials
                        .map((m) => MaterialRow(
                              title: m.title,
                              meta: DateFormat.MMMEd().format(m.createdAt),
                              type: m.materialType,
                            ))
                        .toList(),
                  );
                },
              ),
              const SizedBox(height: 24),
              Text('Your activity', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 10),
              activityAsync.when(
                loading: () => const Center(child: CircularProgressIndicator(strokeWidth: 2)),
                error: (e, _) => const SizedBox.shrink(),
                data: (data) {
                  final hours = data.totalStudyTimeSeconds ~/ 3600;
                  final minutes = (data.totalStudyTimeSeconds % 3600) ~/ 60;
                  final timeLabel = hours > 0 ? '${hours}h ${minutes}m' : '${minutes}m';
                  return Row(
                    children: [
                      Expanded(child: _StatBox(value: timeLabel, label: 'Study time')),
                      const SizedBox(width: 10),
                      Expanded(child: _StatBox(value: '${data.totalQuizzesCompleted}', label: 'Quizzes')),
                      const SizedBox(width: 10),
                      Expanded(child: _StatBox(value: '${data.totalFlashcardsReviewed}', label: 'Flashcards')),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatBox extends StatelessWidget {
  final String value;
  final String label;
  const _StatBox({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: AppColors.paperLine, width: 1.5),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Text(value, style: AppTheme.statNumber(size: 19)),
          const SizedBox(height: 3),
          Text(label, style: AppTheme.statLabel()),
        ],
      ),
    );
  }
}
