// lib/components/ui/card.dart
import 'package:flutter/material.dart';

class AppCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final VoidCallback? onTap;
  final BorderRadiusGeometry? borderRadius;
  final Color? color;
  final bool hover;

  const AppCard({
    super.key,
    required this.child,
    this.padding,
    this.onTap,
    this.borderRadius,
    this.color,
    this.hover = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final br = borderRadius ?? BorderRadius.circular(12);

    return Material(
      color: color ?? theme.colorScheme.surface,
      borderRadius: br,
      child: InkWell(
        onTap: onTap,
        borderRadius: br as BorderRadius?,
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            borderRadius: br,
            border: Border.all(color: theme.colorScheme.outline.withOpacity(0.3)),
          ),
          child: child,
        ),
      ),
    );
  }
}

class CardHeader extends StatelessWidget {
  final Widget child;
  const CardHeader({super.key, required this.child});
  @override
  Widget build(BuildContext context) => Padding(padding: const EdgeInsets.fromLTRB(20, 20, 20, 8), child: child);
}

class CardContent extends StatelessWidget {
  final Widget child;
  const CardContent({super.key, required this.child});
  @override
  Widget build(BuildContext context) => Padding(padding: const EdgeInsets.fromLTRB(20, 0, 20, 20), child: child);
}