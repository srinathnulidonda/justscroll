// lib/components/ui/dialog.dart
import 'package:flutter/material.dart';

class AppDialog {
  static Future<T?> show<T>({
    required BuildContext context,
    required String title,
    String? description,
    required Widget content,
    List<Widget>? actions,
  }) {
    return showDialog<T>(
      context: context,
      barrierColor: Colors.black54,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: Theme.of(ctx).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600)),
              if (description != null) ...[
                const SizedBox(height: 8),
                Text(description, style: TextStyle(fontSize: 14, color: Theme.of(ctx).colorScheme.onSurface.withOpacity(0.6))),
              ],
              const SizedBox(height: 16),
              content,
              if (actions != null) ...[
                const SizedBox(height: 20),
                Row(mainAxisAlignment: MainAxisAlignment.end, children: actions),
              ],
            ],
          ),
        ),
      ),
    );
  }

  static Future<bool?> confirm({
    required BuildContext context,
    required String title,
    String? description,
    String confirmLabel = 'Confirm',
    String cancelLabel = 'Cancel',
    bool destructive = false,
  }) {
    return showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(title),
        content: description != null ? Text(description) : null,
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(cancelLabel)),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: destructive ? TextButton.styleFrom(foregroundColor: Theme.of(ctx).colorScheme.error) : null,
            child: Text(confirmLabel),
          ),
        ],
      ),
    );
  }
}