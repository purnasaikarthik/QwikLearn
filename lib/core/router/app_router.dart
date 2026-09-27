import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../providers/supabase_provider.dart';
import '../../features/auth/presentation/splash_screen.dart';
import '../../features/auth/presentation/welcome_screen.dart';
import '../../features/auth/presentation/login_screen.dart';
import '../../features/auth/presentation/signup_screen.dart';
import '../../features/auth/presentation/forgot_password_screen.dart';
import '../../features/home/presentation/home_screen.dart';
import '../../features/study_spaces/presentation/my_learning_screen.dart';
import '../../features/study_spaces/presentation/new_study_space_sheet.dart';
import '../../features/progress/presentation/progress_screen.dart';
import '../../features/profile/presentation/profile_screen.dart';
import '../../features/study_spaces/presentation/study_space_detail_screen.dart';
import '../../features/notes/presentation/notes_screen.dart';
import '../../features/summaries/presentation/summary_screen.dart';
import '../../features/flashcards/presentation/flashcards_screen.dart';
import '../../features/quizzes/presentation/quiz_screen.dart';
import '../../features/key_concepts/presentation/key_concepts_screen.dart';
import '../../features/ai_chat/presentation/ai_chat_screen.dart';
import '../../shared/widgets/app_shell.dart';

/// Bridges Supabase's auth-change stream to a [Listenable] so GoRouter
/// re-evaluates its `redirect` callback whenever sign-in/sign-out happens,
/// instead of only on navigation.
class _AuthRefreshNotifier extends ChangeNotifier {
  late final StreamSubscription<AuthState> _sub;
  _AuthRefreshNotifier(SupabaseClient client) {
    _sub = client.auth.onAuthStateChange.listen((_) => notifyListeners());
  }
  @override
  void dispose() {
    _sub.cancel();
    super.dispose();
  }
}

const _publicRoutes = ['/splash', '/welcome', '/login', '/signup', '/forgot-password'];

final routerProvider = Provider<GoRouter>((ref) {
  final client = ref.watch(supabaseClientProvider);
  final refreshNotifier = _AuthRefreshNotifier(client);
  ref.onDispose(refreshNotifier.dispose);

  return GoRouter(
    initialLocation: '/splash',
    refreshListenable: refreshNotifier,
    redirect: (context, state) {
      final loggedIn = client.auth.currentSession != null;
      final goingToPublicRoute = _publicRoutes.contains(state.uri.path);

      if (!loggedIn && !goingToPublicRoute) return '/welcome';
      if (loggedIn && (state.uri.path == '/login' || state.uri.path == '/signup')) {
        return '/home';
      }
      return null;
    },
    routes: [
      GoRoute(path: '/splash', builder: (context, state) => const SplashScreen()),
      GoRoute(path: '/welcome', builder: (context, state) => const WelcomeScreen()),
      GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
      GoRoute(path: '/signup', builder: (context, state) => const SignupScreen()),
      GoRoute(path: '/forgot-password', builder: (context, state) => const ForgotPasswordScreen()),

      // Bottom-tab shell: home / learning / progress / profile, plus a
      // center "+" that opens the create sheet rather than navigating.
      ShellRoute(
        builder: (context, state, child) {
          final location = state.uri.toString();
          final index = switch (location) {
            '/home' => 0,
            '/spaces' => 1,
            '/progress' => 2,
            '/profile' => 3,
            _ => 0,
          };
          return AppShell(
            currentIndex: index,
            onTap: (i) {
              const dest = ['/home', '/spaces', '/progress', '/profile'];
              context.go(dest[i]);
            },
            onCreateTap: () => showCreateSheet(context),
            child: child,
          );
        },
        routes: [
          GoRoute(path: '/home', builder: (context, state) => const HomeScreen()),
          GoRoute(path: '/spaces', builder: (context, state) => const MyLearningScreen()),
          GoRoute(path: '/progress', builder: (context, state) => const ProgressScreen()),
          GoRoute(path: '/profile', builder: (context, state) => const ProfileScreen()),
        ],
      ),

      // Study space detail + tools (pushed on top of the shell, no bottom nav)
      GoRoute(
        path: '/study-space/:id',
        builder: (context, state) => StudySpaceDetailScreen(spaceId: state.pathParameters['id']!),
        routes: [
          GoRoute(
            path: 'notes',
            builder: (context, state) => NotesScreen(spaceId: state.pathParameters['id']!),
          ),
          GoRoute(
            path: 'summary',
            builder: (context, state) => SummaryScreen(spaceId: state.pathParameters['id']!),
          ),
          GoRoute(
            path: 'flashcards',
            builder: (context, state) => FlashcardsScreen(spaceId: state.pathParameters['id']!),
          ),
          GoRoute(
            path: 'quiz',
            builder: (context, state) => QuizScreen(spaceId: state.pathParameters['id']!),
          ),
          GoRoute(
            path: 'key-concepts',
            builder: (context, state) => KeyConceptsScreen(spaceId: state.pathParameters['id']!),
          ),
          GoRoute(
            path: 'chat',
            builder: (context, state) => AiChatScreen(spaceId: state.pathParameters['id']!),
          ),
        ],
      ),
    ],
  );
});
