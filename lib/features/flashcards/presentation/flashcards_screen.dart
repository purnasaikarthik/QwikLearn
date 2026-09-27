import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/constants/enums.dart';
import '../../../shared/widgets/empty_state.dart';
import '../providers/flashcard_provider.dart';

class FlashcardsScreen extends ConsumerStatefulWidget {
  final String spaceId;
  const FlashcardsScreen({super.key, required this.spaceId});

  @override
  ConsumerState<FlashcardsScreen> createState() => _FlashcardsScreenState();
}

class _FlashcardsScreenState extends ConsumerState<FlashcardsScreen> {
  int _index = 0;
  bool _showBack = false;

  void _flip() => setState(() => _showBack = !_showBack);

  void _next(List cards) {
    final reviewedCard = cards[_index];
    ref.read(flashcardRepositoryProvider).markReviewed(reviewedCard.id, widget.spaceId);
    setState(() {
      _showBack = false;
      _index = (_index + 1) % cards.length;
    });
  }

  static const _difficultyColor = {
    CardDifficulty.easy: AppColors.sage,
    CardDifficulty.medium: AppColors.warning,
    CardDifficulty.difficult: AppColors.coral,
  };

  @override
  Widget build(BuildContext context) {
    final cardsAsync = ref.watch(flashcardsProvider(widget.spaceId));

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(icon: const Icon(Icons.arrow_back_rounded), onPressed: () => context.pop()),
        title: Text('Flashcards', style: Theme.of(context).textTheme.headlineSmall),
      ),
      body: SafeArea(
        top: false,
        child: cardsAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text('Could not load flashcards.\n$e', textAlign: TextAlign.center)),
          data: (cards) {
            if (cards.isEmpty) {
              return const EmptyState(
                icon: Icons.style_outlined,
                title: 'No flashcards yet',
                message: 'Flashcards generated from your materials will show up here.',
              );
            }
            if (_index >= cards.length) _index = 0;
            final card = cards[_index];

            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: LinearProgressIndicator(
                          value: (_index + 1) / cards.length,
                          minHeight: 6,
                          borderRadius: BorderRadius.circular(6),
                          backgroundColor: AppColors.paperLine,
                          valueColor: const AlwaysStoppedAnimation(AppColors.highlight),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text('${_index + 1} / ${cards.length}', style: Theme.of(context).textTheme.bodySmall),
                    ],
                  ),
                  const SizedBox(height: 28),
                  Expanded(
                    child: GestureDetector(
                      onTap: _flip,
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 250),
                        transitionBuilder: (child, anim) => ScaleTransition(scale: anim, child: child),
                        child: Container(
                          key: ValueKey('${_index}_$_showBack'),
                          width: double.infinity,
                          padding: const EdgeInsets.all(28),
                          decoration: BoxDecoration(
                            color: _showBack ? AppColors.ink : AppColors.paperDim,
                            borderRadius: BorderRadius.circular(28),
                            border: Border.all(color: AppColors.paperLine, width: 1),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: (_difficultyColor[card.difficulty] ?? AppColors.warning).withValues(alpha: 0.2),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Text(
                                      card.difficulty.label,
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                        color: _showBack ? AppColors.paper : AppColors.ink,
                                      ),
                                    ),
                                  ),
                                  Icon(Icons.touch_app_outlined, size: 18, color: _showBack ? AppColors.paper.withValues(alpha: 0.6) : AppColors.inkSoft),
                                ],
                              ),
                              const Spacer(),
                              Text(
                                _showBack ? card.back : card.front,
                                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                      color: _showBack ? AppColors.paper : AppColors.ink,
                                      height: 1.4,
                                    ),
                              ),
                              const Spacer(),
                              Text(
                                _showBack ? 'Tap to see the question' : 'Tap to reveal the answer',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: _showBack ? AppColors.paper.withValues(alpha: 0.6) : AppColors.inkSoft,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => _next(cards),
                          icon: const Icon(Icons.close_rounded, color: AppColors.coral),
                          label: const Text('Still learning'),
                          style: OutlinedButton.styleFrom(side: const BorderSide(color: AppColors.coral)),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () => _next(cards),
                          icon: const Icon(Icons.check_rounded),
                          label: const Text('Got it'),
                          style: ElevatedButton.styleFrom(backgroundColor: AppColors.sage, foregroundColor: AppColors.ink),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
