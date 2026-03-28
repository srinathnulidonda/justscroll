// lib/pages/not_found.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:justscroll/components/ui/button.dart';

class NotFoundPage extends StatelessWidget {
  const NotFoundPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ShaderMask(
              shaderCallback: (bounds) => LinearGradient(
                colors: [theme.colorScheme.primary, theme.colorScheme.primary.withOpacity(0.5)],
              ).createShader(bounds),
              child: Text('404', style: TextStyle(fontSize: 80, fontWeight: FontWeight.w900, color: Colors.white, height: 1)),
            ),
            const SizedBox(height: 16),
            Text('Page not found', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700, color: theme.colorScheme.onSurface)),
            const SizedBox(height: 8),
            Text("The page you're looking for doesn't exist or has been moved.", textAlign: TextAlign.center, style: TextStyle(fontSize: 14, color: theme.colorScheme.onSurface.withOpacity(0.5))),
            const SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AppButton(label: 'Go Back', icon: Icons.arrow_back, onPressed: () => context.pop(), size: ButtonSize.lg),
                const SizedBox(width: 12),
                AppButton(label: 'Home', icon: Icons.home, variant: ButtonVariant.outline, onPressed: () => context.go('/'), size: ButtonSize.lg),
              ],
            ),
          ],
        ),
      ),
    );
  }
}