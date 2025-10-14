//lib/screens/auth/signup_screen.dart

import 'package:flutter/material.dart';
import 'package:manga_app/models/user_profile.dart';
import 'package:manga_app/screens/home_screen.dart';
import 'package:manga_app/services/firebase_service.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _firebaseService = FirebaseService();
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  Future<void> _signup() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      try {
        final userCredential = await _firebaseService.signUp(
          _emailController.text.trim(),
          _passwordController.text.trim(),
        );

        final userProfile = UserProfile(
          uid: userCredential.user!.uid,
          username: _usernameController.text.trim(),
          email: _emailController.text.trim(),
          profileImageUrl: '',
          favorites: [],
          lastReadChapter: {},
        );

        await _firebaseService.createUserProfile(userProfile);

        if (mounted) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const HomeScreen()),
          );
        }
      } catch (e) {
        if (mounted) {
          showDialog(
            context: context,
            builder:
                (_) => AlertDialog(
                  title: const Text('Sign Up Error'),
                  content: Text('Error: ${e.toString()}'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('OK'),
                    ),
                  ],
                ),
          );
        }
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blueAccent.withOpacity(0.1), Colors.grey[100]!],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          'Create Account',
                          style: Theme.of(context).textTheme.headlineMedium
                              ?.copyWith(fontWeight: FontWeight.bold),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Sign up to start reading manga',
                          style: Theme.of(context).textTheme.bodyLarge,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 32),
                        TextFormField(
                          controller: _usernameController,
                          decoration: InputDecoration(
                            labelText: 'Username',
                            prefixIcon: const Icon(Icons.person),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          validator:
                              (value) =>
                                  value!.isEmpty
                                      ? 'Please enter a username'
                                      : null,
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _emailController,
                          decoration: InputDecoration(
                            labelText: 'Email',
                            prefixIcon: const Icon(Icons.email),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          keyboardType: TextInputType.emailAddress,
                          validator:
                              (value) =>
                                  value!.isEmpty
                                      ? 'Please enter your email'
                                      : null,
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _passwordController,
                          decoration: InputDecoration(
                            labelText: 'Password',
                            prefixIcon: const Icon(Icons.lock),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscurePassword
                                    ? Icons.visibility
                                    : Icons.visibility_off,
                              ),
                              onPressed:
                                  () => setState(
                                    () => _obscurePassword = !_obscurePassword,
                                  ),
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          obscureText: _obscurePassword,
                          validator: (value) {
                            if (value!.isEmpty)
                              return 'Please enter a password';
                            if (value.length < 6)
                              return 'Password must be at least 6 characters';
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _confirmPasswordController,
                          decoration: InputDecoration(
                            labelText: 'Confirm Password',
                            prefixIcon: const Icon(Icons.lock),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscureConfirmPassword
                                    ? Icons.visibility
                                    : Icons.visibility_off,
                              ),
                              onPressed:
                                  () => setState(
                                    () =>
                                        _obscureConfirmPassword =
                                            !_obscureConfirmPassword,
                                  ),
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          obscureText: _obscureConfirmPassword,
                          validator: (value) {
                            if (value!.isEmpty)
                              return 'Please confirm your password';
                            if (value != _passwordController.text)
                              return 'Passwords do not match';
                            return null;
                          },
                        ),
                        const SizedBox(height: 24),
                        AnimatedScale(
                          scale: _isLoading ? 0.95 : 1.0,
                          duration: const Duration(milliseconds: 200),
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _signup,
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              backgroundColor: Colors.blueAccent,
                              foregroundColor: Colors.white,
                            ),
                            child:
                                _isLoading
                                    ? const CircularProgressIndicator(
                                      color: Colors.white,
                                    )
                                    : const Text(
                                      'SIGN UP',
                                      style: TextStyle(fontSize: 16),
                                    ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
