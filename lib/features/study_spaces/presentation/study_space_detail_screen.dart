import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../providers/study_space_provider.dart';

/// Study space header + 6-tool grid, restyled to match the prototype's dark
/// curved header with a materials/resources/progress stat row.
class StudySpaceDetailScreen extends ConsumerWidget {
  final String spaceId;
  const StudySpaceDetailScreen({super.key, required this.spaceId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final spaceAsync = ref.watch(studySpaceByIdProvider(spaceId));

    return Scaffold(
      backgroundColor: AppColors.paper,
      body: spaceAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Could not load this study space.\n$e', textAlign: TextAlign.center)),
        data: (space) {
          if (space == null) {
            return const Center(child: Text('Study space not found'));
          }

          final materialCountAsync = ref.watch(spaceMaterialCountProvider(spaceId));
          final resourceCountAsync = ref.watch(spaceResourceCountProvider(spaceId));
          final progressAsync = ref.watch(spaceProgressProvider(spaceId));

          final materialCount = materialCountAsync.maybeWhen(data: (c) => c, orElse: () => 0);
          final resourceCount = resourceCountAsync.maybeWhen(data: (c) => c, orElse: () => 0);
          final progress = progressAsync.maybeWhen(data: (p) => p, orElse: () => 0.0);

          final tools = [
            (icon: Icons.description_outlined, label: 'Notes', desc: 'AI-structured notes from your material', color: AppColors.highlightDim, route: 'notes'),
            (icon: Icons.summarize_outlined, label: 'Summary', desc: 'Short, medium or detailed recap', color: AppColors.coralDim, route: 'summary'),
            (icon: Icons.style_outlined, label: 'Flashcards', desc: 'Cards ready to review', color: AppColors.lavenderDim, route: 'flashcards'),
            (icon: Icons.check_circle_outline_rounded, label: 'Quiz', desc: 'Test yourself, track your score', color: AppColors.sageDim, route: 'quiz'),
            (icon: Icons.lightbulb_outline_rounded, label: 'Key Concepts', desc: 'The ideas worth knowing', color: const Color(0xFFFFF0E0), route: 'key-concepts'),
            (icon: Icons.chat_bubble_outline_rounded, label: 'Ask QwikLearn', desc: 'Chat with your material', color: const Color(0xFFEAF2FF), route: 'chat'),
          ];

          return CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(20, 54, 20, 24),
                  decoration: const BoxDecoration(
                    color: AppColors.ink,
                    borderRadius: BorderRadius.vertical(bottom: Radius.circular(30)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      InkWell(
                        onTap: () => context.pop(),
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          width: 38,
                          height: 38,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(Icons.arrow_back_rounded, color: Colors.white, size: 19),
                        ),
                      ),
                      const SizedBox(height: 14),
                      Text(
                        (space.subject ?? 'General').toUpperCase(),
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1,
                          color: AppColors.highlight,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        space.title,
                        style: Theme.of(context).textTheme.headlineLarge?.copyWith(color: AppColors.paper, fontSize: 23),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          _HeaderStat(value: '$materialCount', label: 'Materials'),
                          const SizedBox(width: 18),
                          _HeaderStat(value: '$resourceCount', label: 'Resources'),
                          const SizedBox(width: 18),
                          _HeaderStat(value: '${(progress * 100).round()}%', label: 'Progress'),
                        ],
                      ),
                      const SizedBox(height: 16),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(99),
                        child: LinearProgressIndicator(
                          value: progress,
                          minHeight: 7,
                          backgroundColor: Colors.white.withValues(alpha: 0.15),
                          valueColor: const AlwaysStoppedAnimation(AppColors.highlight),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 18, 20, 32),
                sliver: SliverToBoxAdapter(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Learning Tools', style: Theme.of(context).textTheme.titleLarge),
                      const SizedBox(height: 12),
                      GridView.count(
                        crossAxisCount: 2,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        mainAxisSpacing: 12,
                        crossAxisSpacing: 12,
                        childAspectRatio: 1.15,
                        children: tools.map((t) {
                          return _ToolTile(
                            icon: t.icon,
                            label: t.label,
                            description: t.desc,
                            background: t.color,
                            onTap: () => context.push('/study-space/$spaceId/${t.route}'),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _HeaderStat extends StatelessWidget {
  final String value;
  final String label;
  const _HeaderStat({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(value, style: AppTheme.statNumber(size: 17, color: AppColors.paper)),
        const SizedBox(height: 2),
        Text(label, style: const TextStyle(fontSize: 10, color: Color(0xFF9895BD))),
      ],
    );
  }
}

class _ToolTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String description;
  final Color background;
  final VoidCallback onTap;

  const _ToolTile({
    required this.icon,
    required this.label,
    required this.description,
    required this.background,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AppColors.paperLine, width: 1.5),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 38,
                height: 38,
                alignment: Alignment.center,
                decoration: BoxDecoration(color: background, borderRadius: BorderRadius.circular(11)),
                child: Icon(icon, color: AppColors.ink, size: 18),
              ),
              const Spacer(),
              Text(label, style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 3),
              Text(
                description,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 11, color: AppColors.inkSoft, height: 1.3),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
