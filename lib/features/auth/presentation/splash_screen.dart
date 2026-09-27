import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/providers/supabase_provider.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 700))..forward();
    Timer(const Duration(milliseconds: 1400), _route);
  }

  void _route() {
    if (!mounted) return;
    final userId = ref.read(currentUserIdProvider);
    context.go(userId == null ? '/welcome' : '/home');
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.ink,
      body: Center(
        child: FadeTransition(
          opacity: _controller,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Stack(
                clipBehavior: Clip.none,
                alignment: Alignment.center,
                children: [
                  Positioned(
                    child: Transform.rotate(
                      angle: -0.05,
                      child: Container(
                        width: 92,
                        height: 34,
                        decoration: BoxDecoration(
                          color: AppColors.highlight,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ),
                  Text(
                    'Qwik\nLearn',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.displayMedium?.copyWith(
                          color: AppColors.paper,
                          height: 0.95,
                        ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              Text(
                'Learn Faster. Understand Better.',
                style: TextStyle(color: AppColors.paper.withValues(alpha: 0.7), fontSize: 13),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
