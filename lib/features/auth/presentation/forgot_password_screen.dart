import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../providers/auth_provider.dart';

class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  ConsumerState<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  final _email = TextEditingController();
  bool _sent = false;
  bool _sending = false;

  Future<void> _submit() async {
    if (!_email.text.contains('@')) return;
    setState(() => _sending = true);
    try {
      await ref.read(authServiceProvider).sendPasswordReset(_email.text.trim());
      setState(() {
        _sent = true;
        _sending = false;
      });
    } catch (_) {
      setState(() => _sending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Reset password')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: _sent
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.mark_email_read_outlined, size: 48, color: AppColors.ink),
                    const SizedBox(height: 16),
                    Text('Check your inbox', style: Theme.of(context).textTheme.headlineMedium),
                    const SizedBox(height: 8),
                    Text(
                      'We sent a reset link to ${_email.text.trim()}.',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Forgot your password?', style: Theme.of(context).textTheme.headlineMedium),
                    const SizedBox(height: 8),
                    Text(
                      "Enter the email on your account and we'll send a reset link.",
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 24),
                    TextField(
                      controller: _email,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(hintText: 'you@example.com'),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _sending ? null : _submit,
                        child: Text(_sending ? 'Sending…' : 'Send reset link'),
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}
