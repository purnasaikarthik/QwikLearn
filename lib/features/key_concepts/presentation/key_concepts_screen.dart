import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';

class KeyConceptsScreen extends StatelessWidget {
  final String spaceId;
  const KeyConceptsScreen({super.key, required this.spaceId});

  static const _concepts = [
    (name: 'Nucleophile', def: 'An electron-rich species that donates a pair of electrons to form a new bond.'),
    (name: 'Leaving group', def: 'An atom or group that departs with the bonding electrons during a substitution or elimination.'),
    (name: 'Carbocation', def: 'A carbon atom bearing a positive charge and only three bonds; stability increases with substitution.'),
    (name: 'Stereochemistry', def: 'The study of the 3D spatial arrangement of atoms and how it affects reactivity and properties.'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(icon: const Icon(Icons.arrow_back_rounded), onPressed: () => context.pop()),
        title: Text('Key Concepts', style: Theme.of(context).textTheme.headlineSmall),
      ),
      body: SafeArea(
        top: false,
        child: ListView.separated(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
          itemCount: _concepts.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, i) {
            final c = _concepts[i];
            return Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: AppColors.lavenderDim, borderRadius: BorderRadius.circular(18)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(c.name, style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 6),
                  Text(c.def, style: Theme.of(context).textTheme.bodyMedium),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
