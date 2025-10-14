//lib/screens/splash_screen.dart

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:manga_app/screens/auth/login_screen.dart';
import 'package:manga_app/screens/home_screen.dart';
import 'package:google_fonts/google_fonts.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;
  late Animation<double> _subtitleFadeAnimation;
  late Animation<Color?> _backgroundColorAnimation;

  final String title = "MANGA";

  @override
  void initState() {
    super.initState();

    // Animation controller with a 2.5-second duration for a snappier feel
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500),
    );

    // Scale animation for the title (simplified, no elastic curve)
    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.4, curve: Curves.easeInOut),
      ),
    );

    // Opacity animation for the entire content
    _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.3, curve: Curves.easeIn),
      ),
    );

    // Subtitle fade-in animation (simplified, no slide)
    _subtitleFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.4, 0.7, curve: Curves.easeOut),
      ),
    );

    // Background color transition for subtle depth
    _backgroundColorAnimation = ColorTween(
      begin: const Color(0xFF121212), // Darker, modern base color
      end: const Color(0xFF1E1E1E), // Slight shift for elegance
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 1.0, curve: Curves.easeInOut),
      ),
    );

    _controller.forward();

    // Check auth status and navigate after animation
    _checkAuthAndNavigate();
  }

  void _checkAuthAndNavigate() {
    Future.delayed(const Duration(milliseconds: 2500), () {
      if (mounted) {
        final user = FirebaseAuth.instance.currentUser;
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder:
                (_) => user != null ? const HomeScreen() : const LoginScreen(),
          ),
        );
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  _backgroundColorAnimation.value ?? const Color(0xFF121212),
                  const Color(0xFF0A0A0A),
                ],
              ),
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Main title with simplified scale and glow
                  Opacity(
                    opacity: _opacityAnimation.value,
                    child: Transform.scale(
                      scale: _scaleAnimation.value,
                      child: Text(
                        title,
                        style: GoogleFonts.bangers(
                          textStyle: TextStyle(
                            fontSize: 72,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            letterSpacing: 2.0,
                            shadows: [
                              Shadow(
                                color: Colors.purpleAccent.withOpacity(0.4),
                                blurRadius: 12,
                                offset: const Offset(0, 0),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20), // Tighter spacing for modern look
                  // Subtitle with fade-in only
                  Opacity(
                    opacity: _subtitleFadeAnimation.value,
                    child: Text(
                      "READER",
                      style: GoogleFonts.poppins(
                        textStyle: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w400,
                          color: Colors.white.withOpacity(0.8),
                          letterSpacing: 4.0,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 40), // Adjusted for balance
                  // Modern loading indicator
                  Opacity(
                    opacity: _opacityAnimation.value,
                    child: SizedBox(
                      width: 36,
                      height: 36,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          // Pulsing outer ring
                          TweenAnimationBuilder<double>(
                            tween: Tween(begin: 0.8, end: 1.0),
                            duration: const Duration(milliseconds: 800),
                            builder: (context, value, child) {
                              return Transform.scale(
                                scale: value,
                                child: Container(
                                  width: 36,
                                  height: 36,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: Colors.purpleAccent.withOpacity(
                                        0.6,
                                      ),
                                      width: 2,
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                          // Inner dot
                          Container(
                            width: 12,
                            height: 12,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.purpleAccent,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
