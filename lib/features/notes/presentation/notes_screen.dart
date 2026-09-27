import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/binder_holes.dart';

class NotesScreen extends StatelessWidget {
  final String spaceId;
  const NotesScreen({super.key, required this.spaceId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(icon: const Icon(Icons.arrow_back_rounded), onPressed: () => context.pop()),
        title: Text('Notes', style: Theme.of(context).textTheme.headlineSmall),
      ),
      body: SafeArea(
        top: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
          children: [
            BinderCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Nucleophilic substitution — key points', style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 10),
                  Text(
                    '• SN1: two-step, carbocation intermediate, racemization\n'
                    '• SN2: one-step, backside attack, inversion of configuration\n'
                    '• Polar protic solvents favor SN1; polar aprotic solvents favor SN2\n'
                    '• Tertiary substrates favor SN1; primary substrates favor SN2',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(height: 1.7),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            BinderCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Elimination reactions', style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 10),
                  Text(
                    '• E1: carbocation intermediate, competes with SN1\n'
                    '• E2: concerted, requires anti-periplanar geometry\n'
                    '• Bulky bases (e.g. tert-butoxide) favor elimination over substitution',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(height: 1.7),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.highlight,
        foregroundColor: AppColors.ink,
        onPressed: () {},
        child: const Icon(Icons.add_rounded),
      ),
    );
  }
}
