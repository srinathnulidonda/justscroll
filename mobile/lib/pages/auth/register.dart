// lib/pages/auth/register.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:justscroll/stores/auth_store.dart';
import 'package:justscroll/stores/toast_store.dart';
import 'package:justscroll/components/ui/input.dart';
import 'package:justscroll/components/ui/button.dart';
import 'package:justscroll/components/ui/card.dart';

class RegisterPage extends ConsumerStatefulWidget {
  final String? redirect;
  const RegisterPage({super.key, this.redirect});

  @override
  ConsumerState<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends ConsumerState<RegisterPage> {
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  bool _loading = false;
  final Map<String, String?> _errors = {};

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  bool _validate() {
    final errors = <String, String?>{};
    if (_usernameController.text.trim().length < 3) errors['username'] = 'Username must be at least 3 characters';
    if (!RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(_emailController.text)) errors['email'] = 'Enter a valid email';
    if (_passwordController.text.length < 6) errors['password'] = 'Password must be at least 6 characters';
    if (_passwordController.text != _confirmController.text) errors['confirm'] = 'Passwords do not match';
    setState(() {
      _errors.clear();
      _errors.addAll(errors);
    });
    return errors.isEmpty;
  }

  Future<void> _handleSubmit() async {
    if (!_validate()) return;
    setState(() => _loading = true);
    try {
      await ref.read(authStoreProvider.notifier).register(
        _usernameController.text.trim(),
        _emailController.text.trim(),
        _passwordController.text,
      );
      ref.read(toastProvider.notifier).success('Account created! Welcome aboard.');
      if (mounted) {
        final redirect = widget.redirect;
        if (redirect != null && redirect.isNotEmpty) {
          context.go(redirect);
        } else {
          context.go('/');
        }
      }
    } catch (e) {
      ref.read(toastProvider.notifier).error(e.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SingleChildScrollView(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 40),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            child: AppCard(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Image.asset('assets/images/logo.png', height: 36, errorBuilder: (_, __, ___) => Text('JustScroll', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: theme.colorScheme.primary))),
                  const SizedBox(height: 16),
                  Text('Create account', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: theme.colorScheme.onSurface)),
                  const SizedBox(height: 4),
                  Text('Start your reading journey', style: TextStyle(fontSize: 14, color: theme.colorScheme.onSurface.withOpacity(0.5))),
                  const SizedBox(height: 24),
                  AppInput(label: 'Username', hint: 'Choose a username', prefixIcon: Icons.person_outline, controller: _usernameController, error: _errors['username'], autofocus: true),
                  const SizedBox(height: 16),
                  AppInput(label: 'Email', hint: 'you@example.com', prefixIcon: Icons.email_outlined, controller: _emailController, error: _errors['email'], keyboardType: TextInputType.emailAddress),
                  const SizedBox(height: 16),
                  AppInput(label: 'Password', hint: 'Min. 6 characters', prefixIcon: Icons.lock_outline, controller: _passwordController, error: _errors['password'], obscureText: true),
                  const SizedBox(height: 16),
                  AppInput(label: 'Confirm Password', hint: 'Re-enter password', prefixIcon: Icons.lock_outline, controller: _confirmController, error: _errors['confirm'], obscureText: true, onSubmitted: _handleSubmit),
                  const SizedBox(height: 24),
                  AppButton(label: 'Create Account', onPressed: _handleSubmit, loading: _loading, size: ButtonSize.lg, width: double.infinity),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Already have an account? ', style: TextStyle(fontSize: 14, color: theme.colorScheme.onSurface.withOpacity(0.5))),
                      GestureDetector(
                        onTap: () => context.go('/login${widget.redirect != null ? '?redirect=${widget.redirect}' : ''}'),
                        child: Text('Sign in', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: theme.colorScheme.primary)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}