// lib/components/ui/badge.dart
import 'package:flutter/material.dart';

enum BadgeVariant { primary, secondary, success, warning, destructive, outline }

class AppBadge extends StatelessWidget {
  final String label;
  final BadgeVariant variant;
  final Color? bgColor;
  final Color? textColor;
  final double fontSize;

  const AppBadge({
    super.key,
    required this.label,
    this.variant = BadgeVariant.primary,
    this.bgColor,
    this.textColor,
    this.fontSize = 11,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = _getColors(theme);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: bgColor ?? colors.$1,
        borderRadius: BorderRadius.circular(20),
        border: variant == BadgeVariant.outline
            ? Border.all(color: theme.colorScheme.outline.withOpacity(0.5))
            : null,
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: fontSize,
          fontWeight: FontWeight.w600,
          color: textColor ?? colors.$2,
          height: 1.4,
        ),
      ),
    );
  }

  (Color, Color) _getColors(ThemeData theme) {
    return switch (variant) {
      BadgeVariant.primary => (theme.colorScheme.primary.withOpacity(0.1), theme.colorScheme.primary),
      BadgeVariant.secondary => (theme.colorScheme.secondary, theme.colorScheme.onSecondary),
      BadgeVariant.success => (const Color(0xFF10B981).withOpacity(0.1), const Color(0xFF10B981)),
      BadgeVariant.warning => (const Color(0xFFF59E0B).withOpacity(0.1), const Color(0xFFF59E0B)),
      BadgeVariant.destructive => (theme.colorScheme.error.withOpacity(0.1), theme.colorScheme.error),
      BadgeVariant.outline => (Colors.transparent, theme.colorScheme.onSurface),
    };
  }
}