import 'package:supabase_flutter/supabase_flutter.dart';

/// Result of a signUp() call — tells the UI whether the user is already
/// signed in, or still needs to confirm their email before a session exists.
class SignUpResult {
  final bool needsEmailConfirmation;
  const SignUpResult({required this.needsEmailConfirmation});
}

class AuthService {
  final SupabaseClient _client;
  const AuthService(this._client);

  Future<void> signIn({required String email, required String password}) async {
    try {
      await _client.auth.signInWithPassword(email: email, password: password);
    } on AuthException catch (e) {
      throw _friendlyMessage(e);
    }
  }

  Future<SignUpResult> signUp({
    required String email,
    required String password,
    required String fullName,
  }) async {
    try {
      final res = await _client.auth.signUp(
        email: email,
        password: password,
        data: {'full_name': fullName},
      );

      // The `profiles` row is created server-side by the `on_auth_user_created`
      // trigger (see supabase/schema.sql), so it works even when there's no
      // client session yet. We intentionally do NOT upsert into `profiles`
      // from the client here: if "Confirm email" is on, signUp() returns a
      // user with `res.session == null`, so `auth.uid()` is null and any
      // client-side write to `profiles` would be silently blocked by RLS.
      return SignUpResult(needsEmailConfirmation: res.session == null);
    } on AuthException catch (e) {
      throw _friendlyMessage(e);
    }
  }

  Future<void> sendPasswordReset(String email) async {
    try {
      await _client.auth.resetPasswordForEmail(email);
    } on AuthException catch (e) {
      throw _friendlyMessage(e);
    }
  }

  Future<void> signOut() async {
    await _client.auth.signOut();
  }

  /// Supabase's raw AuthException messages are usually fine to show directly,
  /// but a couple of the common ones read better rephrased.
  String _friendlyMessage(AuthException e) {
    final msg = e.message.toLowerCase();
    if (msg.contains('already registered') || msg.contains('already exists')) {
      return 'An account with that email already exists. Try signing in instead.';
    }
    if (msg.contains('email not confirmed')) {
      return 'Please confirm your email first — check your inbox for the confirmation link.';
    }
    if (msg.contains('invalid login credentials')) {
      return 'Incorrect email or password.';
    }
    return e.message;
  }
}
