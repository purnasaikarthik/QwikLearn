import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/highlighter_swipe.dart';
import '../providers/progress_provider.dart';

class ProgressScreen extends ConsumerWidget {
  const ProgressScreen({super.key});

  static const _days = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dataAsync = ref.watch(progressDataProvider);

    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async => ref.invalidate(progressDataProvider),
          child: dataAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => ListView(
              padding: const EdgeInsets.all(20),
              children: [Text('Could not load your progress: $e')],
            ),
            data: (data) {
              final hours = data.totalStudyTimeSeconds ~/ 3600;
              final minutes = (data.totalStudyTimeSeconds % 3600) ~/ 60;
              final timeLabel = hours > 0 ? '${hours}h ${minutes}m' : '${minutes}m';
              final maxActivity = data.weeklyActivity.isEmpty
                  ? 1
                  : data.weeklyActivity.reduce((a, b) => a > b ? a : b).clamp(1, 1 << 30);

              return ListView(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 100),
                children: [
                  HighlighterSwipe(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Text('Your progress', style: Theme.of(context).textTheme.displayMedium),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(child: _StatCard(value: '${data.streakDays}', label: 'day streak', color: AppColors.highlightDim)),
                      const SizedBox(width: 12),
                      Expanded(child: _StatCard(value: timeLabel, label: 'total study time', color: AppColors.lavenderDim)),
                      const SizedBox(width: 12),
                      Expanded(child: _StatCard(value: '${data.totalFlashcardsReviewed}', label: 'cards reviewed', color: AppColors.sageDim)),
                    ],
                  ),
                  const SizedBox(height: 28),
                  Text('Activity this week', style: Theme.of(context).textTheme.headlineSmall),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 140,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: List.generate(7, (i) {
                        final value = data.weeklyActivity[i];
                        final isTop = value == maxActivity && value > 0;
                        final heightFactor = value == 0 ? 0.04 : value / maxActivity;
                        return Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 6),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Container(
                                  height: 100 * heightFactor,
                                  decoration: BoxDecoration(
                                    color: isTop ? AppColors.highlight : AppColors.paperDim,
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(color: AppColors.paperLine),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(_days[i], style: Theme.of(context).textTheme.bodySmall),
                              ],
                            ),
                          ),
                        );
                      }),
                    ),
                  ),
                  const SizedBox(height: 28),
                  Text('Mastery by subject', style: Theme.of(context).textTheme.headlineSmall),
                  const SizedBox(height: 12),
                  if (data.masteryBySubject.isEmpty)
                    Text(
                      'Take a quiz to see mastery by subject.',
                      style: Theme.of(context).textTheme.bodyMedium,
                    )
                  else
                    ...data.masteryBySubject.entries.map((e) => _MasteryRow(subject: e.key, value: e.value)),
                  const SizedBox(height: 20),
                  Text('Recent Quizzes', style: Theme.of(context).textTheme.headlineSmall),
                  const SizedBox(height: 12),
                  if (data.recentAttempts.isEmpty)
                    Text(
                      'Quizzes you complete will show up here.',
                      style: Theme.of(context).textTheme.bodyMedium,
                    )
                  else
                    ...data.recentAttempts.map((a) => Container(
                          margin: const EdgeInsets.only(bottom: 10),
                          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 13),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            border: Border.all(color: AppColors.paperLine, width: 1.5),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(a.quizTitle, maxLines: 1, overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                              ),
                              Text('${a.score}/${a.totalQuestions}', style: AppTheme.statNumber(size: 14)),
                            ],
                          ),
                        )),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String value;
  final String label;
  final Color color;
  const _StatCard({required this.value, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(18)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(value, style: AppTheme.statNumber(size: 20)),
          const SizedBox(height: 2),
          Text(label.toUpperCase(), style: AppTheme.statLabel()),
        ],
      ),
    );
  }
}

class _MasteryRow extends StatelessWidget {
  final String subject;
  final double value;
  const _MasteryRow({required this.subject, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(subject, style: Theme.of(context).textTheme.titleMedium),
              Text('${(value * 100).round()}%', style: Theme.of(context).textTheme.bodyMedium),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: value,
              minHeight: 8,
              backgroundColor: AppColors.paperLine,
              valueColor: const AlwaysStoppedAnimation(AppColors.ink),
            ),
          ),
        ],
      ),
    );
  }
}
