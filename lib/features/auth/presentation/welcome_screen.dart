import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';

/// The landing screen between splash and auth, matching the prototype's
/// illustrated welcome card: a light top half with a simple illustration,
/// and a dark bottom sheet carrying the pitch + call to action.
class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.paper,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(28, 20, 28, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'QWIKLEARN',
                      style: TextStyle(
                        fontSize: 11,
                        letterSpacing: 2,
                        fontWeight: FontWeight.w600,
                        color: AppColors.inkSoft,
                      ),
                    ),
                    const Expanded(child: Center(child: _WelcomeIllustration())),
                  ],
                ),
              ),
            ),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(28, 34, 28, 40),
              decoration: const BoxDecoration(
                color: AppColors.ink,
                borderRadius: BorderRadius.vertical(top: Radius.circular(36)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'YOUR STUDY WORKSPACE',
                    style: TextStyle(
                      fontSize: 11,
                      letterSpacing: 2,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF9895BD),
                    ),
                  ),
                  const SizedBox(height: 10),
                  RichText(
                    text: TextSpan(
                      style: Theme.of(context).textTheme.displaySmall?.copyWith(color: AppColors.paper, height: 1.15),
                      children: [
                        const TextSpan(text: 'Turn any material into a '),
                        TextSpan(
                          text: 'study space',
                          style: TextStyle(
                            backgroundColor: AppColors.highlight.withValues(alpha: 0.9),
                            color: AppColors.ink,
                          ),
                        ),
                        const TextSpan(text: ' you\u2019ll actually use.'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Drop in notes, PDFs, or articles — QwikLearn organizes it into notes, flashcards, quizzes and more.',
                    style: TextStyle(color: Color(0xFFB7B4D4), fontSize: 14, height: 1.5),
                  ),
                  const SizedBox(height: 26),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => context.go('/signup'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.highlight,
                        foregroundColor: AppColors.ink,
                      ),
                      child: const Text('Get Started'),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Center(
                    child: GestureDetector(
                      onTap: () => context.go('/login'),
                      child: const Text(
                        'Already have an account? Sign in',
                        style: TextStyle(color: Color(0xFF9895BD), fontSize: 13.5),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _WelcomeIllustration extends StatelessWidget {
  const _WelcomeIllustration();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 200,
      width: 220,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned(
            left: 10,
            bottom: 10,
            child: Container(
              width: 150,
              height: 105,
              decoration: BoxDecoration(color: AppColors.ink, borderRadius: BorderRadius.circular(16)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    margin: const EdgeInsets.all(4),
                    height: 12,
                    decoration: BoxDecoration(color: AppColors.highlight, borderRadius: BorderRadius.circular(9)),
                  ),
                  const SizedBox(height: 12),
                  for (final w in [0.75, 0.55, 0.65])
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                      child: FractionallySizedBox(
                        alignment: Alignment.centerLeft,
                        widthFactor: w,
                        child: Container(
                          height: 6,
                          decoration: BoxDecoration(color: AppColors.inkSoft, borderRadius: BorderRadius.circular(4)),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
          Positioned(
            right: 14,
            top: 0,
            child: Container(
              width: 52,
              height: 52,
              decoration: const BoxDecoration(color: AppColors.lavender, shape: BoxShape.circle),
              child: const Icon(Icons.check_rounded, color: AppColors.ink),
            ),
          ),
          Positioned(
            left: 0,
            bottom: 10,
            child: Container(
              width: 44,
              height: 34,
              decoration: BoxDecoration(color: AppColors.coral, borderRadius: BorderRadius.circular(8)),
            ),
          ),
        ],
      ),
    );
  }
}
