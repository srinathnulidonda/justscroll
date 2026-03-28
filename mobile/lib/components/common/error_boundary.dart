// lib/components/common/error_boundary.dart
import 'package:flutter/material.dart';
import 'package:justscroll/components/ui/button.dart';

class ErrorBoundary extends StatefulWidget {
  final Widget child;
  const ErrorBoundary({super.key, required this.child});

  @override
  State<ErrorBoundary> createState() => _ErrorBoundaryState();
}

class _ErrorBoundaryState extends State<ErrorBoundary> {
  bool _hasError = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _hasError = false;
  }

  @override
  Widget build(BuildContext context) {
    if (_hasError) {
      return _ErrorView(onRetry: () => setState(() => _hasError = false));
    }

    return widget.child;
  }
}

class _ErrorView extends StatelessWidget {
  final VoidCallback onRetry;
  const _ErrorView({required this.onRetry});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.colorScheme.error.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(Icons.warning_amber_rounded, size: 32, color: theme.colorScheme.error),
            ),
            const SizedBox(height: 16),
            const Text('Something went wrong', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Text('An unexpected error occurred.', style: TextStyle(fontSize: 14, color: theme.colorScheme.onSurface.withOpacity(0.5))),
            const SizedBox(height: 24),
            AppButton(label: 'Retry', onPressed: onRetry, variant: ButtonVariant.outline),
          ],
        ),
      ),
    );
  }
}