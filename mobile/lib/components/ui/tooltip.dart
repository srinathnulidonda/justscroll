// lib/components/ui/tooltip.dart
import 'package:flutter/material.dart';

class AppTooltip extends StatelessWidget {
  final String message;
  final Widget child;
  final bool preferBelow;

  const AppTooltip({
    super.key,
    required this.message,
    required this.child,
    this.preferBelow = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Tooltip(
      message: message,
      preferBelow: preferBelow,
      decoration: BoxDecoration(
        color: theme.colorScheme.onSurface,
        borderRadius: BorderRadius.circular(8),
      ),
      textStyle: TextStyle(fontSize: 12, color: theme.colorScheme.surface),
      waitDuration: const Duration(milliseconds: 400),
      child: child,
    );
  }
}