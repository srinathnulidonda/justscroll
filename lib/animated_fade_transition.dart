import 'package:flutter/material.dart';

/// A widget that applies a fade transition to its child based on animation
class AnimatedFadeTransition extends StatelessWidget {
  final Animation<double> animation;
  final Widget child;
  final Curve curve;

  const AnimatedFadeTransition({
    super.key,
    required this.animation,
    required this.child,
    this.curve = Curves.easeInOut,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        return FadeTransition(
          opacity: CurvedAnimation(parent: animation, curve: curve),
          child: child,
        );
      },
      child: child,
    );
  }
}
