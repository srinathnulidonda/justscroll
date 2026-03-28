// lib/components/common/empty_state.dart
import 'package:flutter/material.dart';
import 'package:justscroll/components/ui/button.dart';

class EmptyState extends StatelessWidget {
  final IconData? icon;
  final String title;
  final String? description;
  final VoidCallback? action;
  final String? actionLabel;

  const EmptyState({
    super.key,
    this.icon,
    required this.title,
    this.description,
    this.action,
    this.actionLabel,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 64, horizontal: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null)
              Container(
                padding: const EdgeInsets.all(16),
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(icon, size: 32, color: theme.colorScheme.onSurface.withOpacity(0.5)),
              ),
            Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600), textAlign: TextAlign.center),
            if (description != null) ...[
              const SizedBox(height: 4),
              Text(description!, style: TextStyle(fontSize: 14, color: theme.colorScheme.onSurface.withOpacity(0.5)), textAlign: TextAlign.center),
            ],
            if (action != null && actionLabel != null) ...[
              const SizedBox(height: 24),
              AppButton(label: actionLabel!, onPressed: action, size: ButtonSize.lg),
            ],
          ],
        ),
      ),
    );
  }
}