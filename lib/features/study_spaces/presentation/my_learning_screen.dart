import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../shared/widgets/space_card.dart';
import '../../../shared/widgets/empty_state.dart';
import '../providers/study_space_provider.dart';
import 'new_study_space_sheet.dart';

/// The "Learning" tab — every study space the user has, matching the
/// prototype's full list-plus-add-another-space screen.
class MyLearningScreen extends ConsumerWidget {
  const MyLearningScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final spacesAsync = ref.watch(studySpacesProvider);

    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async => ref.invalidate(studySpacesProvider),
          child: spacesAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => ListView(
              padding: const EdgeInsets.all(20),
              children: [Text('Could not load your study spaces: $e')],
            ),
            data: (spaces) {
              return ListView(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 110),
                children: [
                  Text('My Learning', style: Theme.of(context).textTheme.displaySmall),
                  const SizedBox(height: 4),
                  Text(
                    '${spaces.length} study space${spaces.length == 1 ? '' : 's'}',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 18),
                  ...spaces.map((space) {
                    final countAsync = ref.watch(spaceMaterialCountProvider(space.id));
                    final progressAsync = ref.watch(spaceProgressProvider(space.id));
                    final count = countAsync.maybeWhen(data: (c) => c, orElse: () => 0);
                    final progress = progressAsync.maybeWhen(data: (p) => p, orElse: () => 0.0);
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: SpaceCard(
                        tag: space.subject ?? 'General',
                        title: space.title,
                        progress: progress,
                        footLeft: '$count material${count == 1 ? '' : 's'}',
                        onTap: () => context.push('/study-space/${space.id}'),
                      ),
                    );
                  }),
                  const SizedBox(height: 8),
                  EmptyState(
                    icon: Icons.auto_stories_outlined,
                    title: 'Add another space',
                    message: 'Create a new study space from a PDF, pasted notes, or an article.',
                    actionLabel: '+ Create Study Space',
                    onAction: () => showCreateSheet(context),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
