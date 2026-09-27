import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers/supabase_provider.dart';
import '../data/auth_service.dart';

final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService(ref.watch(supabaseClientProvider));
});

enum AuthFormStatus { idle, submitting, success, needsEmailConfirmation, error }

class AuthFormState {
  final AuthFormStatus status;
  final String? errorMessage;
  const AuthFormState({this.status = AuthFormStatus.idle, this.errorMessage});
}

class AuthFormNotifier extends StateNotifier<AuthFormState> {
  final AuthService _service;
  AuthFormNotifier(this._service) : super(const AuthFormState());

  Future<bool> signIn(String email, String password) async {
    state = const AuthFormState(status: AuthFormStatus.submitting);
    try {
      await _service.signIn(email: email, password: password);
      state = const AuthFormState(status: AuthFormStatus.success);
      return true;
    } catch (e) {
      state = AuthFormState(status: AuthFormStatus.error, errorMessage: e.toString());
      return false;
    }
  }

  /// Returns true if the caller should navigate straight into the app
  /// (session already active). Returns false either on error, or when the
  /// account was created but needs email confirmation first — check
  /// `state.status` to tell those two apart.
  Future<bool> signUp(String email, String password, String fullName) async {
    state = const AuthFormState(status: AuthFormStatus.submitting);
    try {
      final result = await _service.signUp(email: email, password: password, fullName: fullName);
      if (result.needsEmailConfirmation) {
        state = const AuthFormState(status: AuthFormStatus.needsEmailConfirmation);
        return false;
      }
      state = const AuthFormState(status: AuthFormStatus.success);
      return true;
    } catch (e) {
      state = AuthFormState(status: AuthFormStatus.error, errorMessage: e.toString());
      return false;
    }
  }
}

final authFormProvider = StateNotifierProvider.autoDispose<AuthFormNotifier, AuthFormState>((ref) {
  return AuthFormNotifier(ref.watch(authServiceProvider));
});
