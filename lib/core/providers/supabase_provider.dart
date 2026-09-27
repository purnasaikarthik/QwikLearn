import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// The single Supabase client instance, available anywhere via ref.watch.
/// `Supabase.initialize` is called once in main() before runApp.
final supabaseClientProvider = Provider<SupabaseClient>((ref) {
  return Supabase.instance.client;
});

/// Emits the current auth state (signed in / out) so the router and screens
/// can react without polling.
final authStateProvider = StreamProvider<AuthState>((ref) {
  final client = ref.watch(supabaseClientProvider);
  return client.auth.onAuthStateChange;
});

/// Convenience: the current user's id, or null when signed out.
final currentUserIdProvider = Provider<String?>((ref) {
  final client = ref.watch(supabaseClientProvider);
  // also depend on authStateProvider so this rebuilds on sign-in/out
  ref.watch(authStateProvider);
  return client.auth.currentUser?.id;
});
