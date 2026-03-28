// lib/pages/auth/login.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:justscroll/stores/auth_store.dart';
import 'package:justscroll/stores/toast_store.dart';
import 'package:justscroll/components/ui/input.dart';
import 'package:justscroll/components/ui/button.dart';
import 'package:justscroll/components/ui/card.dart';

class LoginPage extends ConsumerStatefulWidget {
  final String? redirect;
  const LoginPage({super.key, this.redirect});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _loading = false;
  String? _usernameError;
  String? _passwordError;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  bool _validate() {
    setState(() {
      _usernameError = _usernameController.text.trim().isEmpty ? 'Username is required' : null;
      _passwordError = _passwordController.text.isEmpty ? 'Password is required' : null;
    });
    return _usernameError == null && _passwordError == null;
  }

  Future<void> _handleSubmit() async {
    if (!_validate()) return;
    setState(() => _loading = true);
    try {
      await ref.read(authStoreProvider.notifier).login(
        _usernameController.text.trim(),
        _passwordController.text,
      );
      ref.read(toastProvider.notifier).success('Welcome back!');
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
      setState(() => _passwordError = 'Invalid credentials');
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
                  Text('Welcome back', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: theme.colorScheme.onSurface)),
                  const SizedBox(height: 4),
                  Text('Sign in to your account', style: TextStyle(fontSize: 14, color: theme.colorScheme.onSurface.withOpacity(0.5))),
                  const SizedBox(height: 24),
                  AppInput(
                    label: 'Username',
                    hint: 'Enter your username',
                    prefixIcon: Icons.person_outline,
                    controller: _usernameController,
                    error: _usernameError,
                    autofocus: true,
                    onSubmitted: _handleSubmit,
                  ),
                  const SizedBox(height: 16),
                  AppInput(
                    label: 'Password',
                    hint: 'Enter your password',
                    prefixIcon: Icons.lock_outline,
                    controller: _passwordController,
                    error: _passwordError,
                    obscureText: true,
                    onSubmitted: _handleSubmit,
                  ),
                  const SizedBox(height: 24),
                  AppButton(
                    label: 'Sign In',
                    onPressed: _handleSubmit,
                    loading: _loading,
                    size: ButtonSize.lg,
                    width: double.infinity,
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text("Don't have an account? ", style: TextStyle(fontSize: 14, color: theme.colorScheme.onSurface.withOpacity(0.5))),
                      GestureDetector(
                        onTap: () => context.go('/register${widget.redirect != null ? '?redirect=${widget.redirect}' : ''}'),
                        child: Text('Create one', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: theme.colorScheme.primary)),
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