import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../../models/quiz.dart';
import '../providers/quiz_provider.dart';

class QuizScreen extends ConsumerStatefulWidget {
  final String spaceId;
  const QuizScreen({super.key, required this.spaceId});

  @override
  ConsumerState<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends ConsumerState<QuizScreen> {
  int _index = 0;
  String? _selected;
  bool _revealed = false;
  int _score = 0;
  bool _finished = false;
  bool _attemptSaved = false;

  void _select(String option, String correct) {
    if (_revealed) return;
    setState(() {
      _selected = option;
      _revealed = true;
      if (option == correct) _score++;
    });
  }

  void _next(Quiz quiz) {
    final total = quiz.questions.length;
    if (_index + 1 >= total) {
      setState(() => _finished = true);
      if (!_attemptSaved) {
        _attemptSaved = true;
        ref.read(quizRepositoryProvider).recordAttempt(
              quizId: quiz.id,
              studySpaceId: widget.spaceId,
              score: _score,
              totalQuestions: total,
            );
      }
      return;
    }
    setState(() {
      _index++;
      _selected = null;
      _revealed = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final quizAsync = ref.watch(quizProvider(widget.spaceId));

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(icon: const Icon(Icons.arrow_back_rounded), onPressed: () => context.pop()),
        title: quizAsync.maybeWhen(
          data: (q) => Text(q?.title ?? 'Quiz', style: Theme.of(context).textTheme.headlineSmall),
          orElse: () => Text('Quiz', style: Theme.of(context).textTheme.headlineSmall),
        ),
      ),
      body: SafeArea(
        top: false,
        child: quizAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text('Could not load the quiz.\n$e', textAlign: TextAlign.center)),
          data: (quiz) {
            if (quiz == null || quiz.questions.isEmpty) {
              return const EmptyState(
                icon: Icons.check_circle_outline_rounded,
                title: 'No quiz yet',
                message: 'A quiz generated from your materials will show up here.',
              );
            }
            return _finished ? _ResultView(score: _score, total: quiz.questions.length) : _questionView(quiz);
          },
        ),
      ),
    );
  }

  Widget _questionView(Quiz quiz) {
    final q = quiz.questions[_index];
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: (_index + 1) / quiz.questions.length,
            minHeight: 6,
            borderRadius: BorderRadius.circular(6),
            backgroundColor: AppColors.paperLine,
            valueColor: const AlwaysStoppedAnimation(AppColors.highlight),
          ),
          const SizedBox(height: 8),
          Text('Question ${_index + 1} of ${quiz.questions.length}', style: Theme.of(context).textTheme.bodySmall),
          const SizedBox(height: 20),
          Text(q.question, style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 24),
          Expanded(
            child: ListView(
              children: [
                ...q.options.map<Widget>((opt) {
                  final isCorrect = opt == q.correctAnswer;
                  final isSelected = opt == _selected;
                  Color bg = AppColors.paperDim;
                  Color? border;
                  if (_revealed) {
                    if (isCorrect) {
                      bg = AppColors.sageDim;
                      border = AppColors.sage;
                    } else if (isSelected) {
                      bg = AppColors.coralDim;
                      border = AppColors.coral;
                    }
                  }
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Material(
                      color: bg,
                      borderRadius: BorderRadius.circular(16),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(16),
                        onTap: () => _select(opt, q.correctAnswer),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: border ?? AppColors.paperLine),
                          ),
                          child: Row(
                            children: [
                              Expanded(child: Text(opt, style: Theme.of(context).textTheme.bodyLarge)),
                              if (_revealed && isCorrect) const Icon(Icons.check_circle, color: AppColors.sage),
                              if (_revealed && isSelected && !isCorrect) const Icon(Icons.cancel, color: AppColors.coral),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                }),
                if (_revealed && q.explanation != null) ...[
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(color: AppColors.paperDim, borderRadius: BorderRadius.circular(14)),
                    child: Text(q.explanation!, style: Theme.of(context).textTheme.bodyMedium),
                  ),
                ],
              ],
            ),
          ),
          if (_revealed)
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => _next(quiz),
                child: Text(_index + 1 >= quiz.questions.length ? 'See results' : 'Next question'),
              ),
            ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}

class _ResultView extends StatelessWidget {
  final int score;
  final int total;
  const _ResultView({required this.score, required this.total});

  @override
  Widget build(BuildContext context) {
    final pct = total == 0 ? 0 : ((score / total) * 100).round();
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 120, height: 120,
              decoration: const BoxDecoration(color: AppColors.ink, shape: BoxShape.circle),
              alignment: Alignment.center,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('$pct%', style: Theme.of(context).textTheme.headlineLarge?.copyWith(color: AppColors.highlight)),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Text('You scored $score / $total', style: Theme.of(context).textTheme.headlineMedium),
            const SizedBox(height: 8),
            Text(
              pct >= 80 ? "You've got this locked in." : 'A little more review and this will stick.',
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 28),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(onPressed: () => context.pop(), child: const Text('Back to study space')),
            ),
          ],
        ),
      ),
    );
  }
}
