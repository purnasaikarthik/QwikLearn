import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/highlighter_swipe.dart';
import '../providers/auth_provider.dart';

class SignupScreen extends ConsumerStatefulWidget {
  const SignupScreen({super.key});

  @override
  ConsumerState<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends ConsumerState<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final ok = await ref
        .read(authFormProvider.notifier)
        .signUp(_email.text.trim(), _password.text, _name.text.trim());
    if (!mounted) return;
    if (ok) {
      context.go('/home');
      return;
    }
    final status = ref.read(authFormProvider).status;
    if (status == AuthFormStatus.needsEmailConfirmation) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Account created! Check your email to confirm it, then sign in.'),
          duration: Duration(seconds: 6),
        ),
      );
      context.go('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    final formState = ref.watch(authFormProvider);
    final submitting = formState.status == AuthFormStatus.submitting;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                IconButton(
                  onPressed: () => context.go('/welcome'),
                  icon: const Icon(Icons.arrow_back_rounded),
                  padding: EdgeInsets.zero,
                ),
                const SizedBox(height: 12),
                HighlighterSwipe(
                  child: Text('Start your\nstudy space.', style: Theme.of(context).textTheme.displayMedium),
                ),
                const SizedBox(height: 32),
                Text('Full name', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _name,
                  decoration: const InputDecoration(hintText: 'Ada Lovelace'),
                  validator: (v) => (v == null || v.trim().isEmpty) ? 'Enter your name' : null,
                ),
                const SizedBox(height: 18),
                Text('Email', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _email,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(hintText: 'you@example.com'),
                  validator: (v) => (v == null || !v.contains('@')) ? 'Enter a valid email' : null,
                ),
                const SizedBox(height: 18),
                Text('Password', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _password,
                  obscureText: true,
                  decoration: const InputDecoration(hintText: 'At least 6 characters'),
                  validator: (v) => (v == null || v.length < 6) ? 'At least 6 characters' : null,
                ),
                if (formState.status == AuthFormStatus.error) ...[
                  const SizedBox(height: 10),
                  Text(
                    formState.errorMessage ?? 'Could not create your account. Try again.',
                    style: TextStyle(color: AppColors.coral, fontSize: 13),
                  ),
                ],
                const SizedBox(height: 28),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: submitting ? null : _submit,
                    child: submitting
                        ? const SizedBox(
                            width: 20, height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.paper),
                          )
                        : const Text('Create account'),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Already studying with us? ', style: Theme.of(context).textTheme.bodyMedium),
                    GestureDetector(
                      onTap: () => context.go('/login'),
                      child: Text(
                        'Sign in',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: AppColors.ink,
                              decoration: TextDecoration.underline,
                              decorationColor: AppColors.highlight,
                              decorationThickness: 2,
                            ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
