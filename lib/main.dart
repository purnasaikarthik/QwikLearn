import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Values come from --dart-define or a build-time .env step; see .env.example.
  await Supabase.initialize(
    url: const String.fromEnvironment('SUPABASE_URL', defaultValue: ''),
    publishableKey: const String.fromEnvironment('SUPABASE_ANON_KEY', defaultValue: ''),
  );

  runApp(const ProviderScope(child: QwikLearnApp()));
}

class QwikLearnApp extends ConsumerWidget {
  const QwikLearnApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    return MaterialApp.router(
      title: 'QwikLearn',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      routerConfig: router,
    );
  }
}
