import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/highlighter_swipe.dart';

class SummaryScreen extends StatefulWidget {
  final String spaceId;
  const SummaryScreen({super.key, required this.spaceId});

  @override
  State<SummaryScreen> createState() => _SummaryScreenState();
}

class _SummaryScreenState extends State<SummaryScreen> {
  int _lengthIndex = 1;
  static const _lengths = ['Short', 'Medium', 'Detailed'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(icon: const Icon(Icons.arrow_back_rounded), onPressed: () => context.pop()),
        title: Text('Summary', style: Theme.of(context).textTheme.headlineSmall),
      ),
      body: SafeArea(
        top: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
          children: [
            Row(
              children: List.generate(_lengths.length, (i) {
                final selected = i == _lengthIndex;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(_lengths[i]),
                    selected: selected,
                    selectedColor: AppColors.highlight,
                    onSelected: (_) => setState(() => _lengthIndex = i),
                  ),
                );
              }),
            ),
            const SizedBox(height: 20),
            HighlighterSwipe(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Text('Chapter 12 in brief', style: Theme.of(context).textTheme.headlineMedium),
            ),
            const SizedBox(height: 14),
            Text(
              'Chapter 12 covers nucleophilic substitution and elimination reactions. '
              'SN1 and SN2 mechanisms differ in step count, stereochemical outcome, and the '
              'substrate/solvent conditions that favor each. E1 and E2 elimination compete with '
              'substitution and are favored by bulky bases and higher temperatures. Carbocation '
              'stability and rearrangement explain many of the exceptions seen in mechanism problems.',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(height: 1.7),
            ),
          ],
        ),
      ),
    );
  }
}
