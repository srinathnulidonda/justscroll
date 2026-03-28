// lib/components/ui/progress.dart
import 'package:flutter/material.dart';

class AppProgress extends StatelessWidget {
  final double value;
  final double max;
  final double height;
  final Color? color;
  final Color? backgroundColor;

  const AppProgress({
    super.key,
    required this.value,
    this.max = 100,
    this.height = 6,
    this.color,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final pct = (value / max).clamp(0.0, 1.0);

    return Container(
      height: height,
      decoration: BoxDecoration(
        color: backgroundColor ?? theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(height),
      ),
      child: FractionallySizedBox(
        alignment: Alignment.centerLeft,
        widthFactor: pct,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeOut,
          decoration: BoxDecoration(
            color: color ?? theme.colorScheme.primary,
            borderRadius: BorderRadius.circular(height),
          ),
        ),
      ),
    );
  }
}