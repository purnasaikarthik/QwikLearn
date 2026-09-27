import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/highlighter_swipe.dart';
import '../providers/auth_provider.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _obscure = true;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final ok = await ref.read(authFormProvider.notifier).signIn(_email.text.trim(), _password.text);
    if (ok && mounted) context.go('/home');
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
                  child: Text('Welcome\nback.', style: Theme.of(context).textTheme.displayMedium),
                ),
                const SizedBox(height: 10),
                Text(
                  'Pick up right where you left off.',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 36),
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
                  obscureText: _obscure,
                  decoration: InputDecoration(
                    hintText: '••••••••',
                    suffixIcon: IconButton(
                      icon: Icon(_obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined),
                      onPressed: () => setState(() => _obscure = !_obscure),
                    ),
                  ),
                  validator: (v) => (v == null || v.length < 6) ? 'At least 6 characters' : null,
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () => context.push('/forgot-password'),
                    child: const Text('Forgot password?'),
                  ),
                ),
                if (formState.status == AuthFormStatus.error) ...[
                  const SizedBox(height: 4),
                  Text(
                    formState.errorMessage ?? 'Could not sign in. Check your details and try again.',
                    style: TextStyle(color: AppColors.coral, fontSize: 13),
                  ),
                ],
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: submitting ? null : _submit,
                    child: submitting
                        ? const SizedBox(
                            width: 20, height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.paper),
                          )
                        : const Text('Sign in'),
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("New to QwikLearn? ", style: Theme.of(context).textTheme.bodyMedium),
                    GestureDetector(
                      onTap: () => context.go('/signup'),
                      child: Text(
                        'Create an account',
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
