// lib/components/ui/button.dart
import 'package:flutter/material.dart';

enum ButtonVariant { primary, secondary, outline, ghost, destructive, link }
enum ButtonSize { sm, md, lg, xl, icon, iconSm }

class AppButton extends StatelessWidget {
  final String? label;
  final VoidCallback? onPressed;
  final ButtonVariant variant;
  final ButtonSize size;
  final bool loading;
  final bool disabled;
  final IconData? icon;
  final IconData? trailingIcon;
  final Widget? child;
  final double? width;

  const AppButton({
    super.key,
    this.label,
    this.onPressed,
    this.variant = ButtonVariant.primary,
    this.size = ButtonSize.md,
    this.loading = false,
    this.disabled = false,
    this.icon,
    this.trailingIcon,
    this.child,
    this.width,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = _getColors(theme);
    final dimensions = _getDimensions();
    final isDisabled = disabled || loading;

    return SizedBox(
      width: width,
      height: dimensions.$1,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isDisabled ? null : onPressed,
          borderRadius: BorderRadius.circular(dimensions.$3),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: EdgeInsets.symmetric(horizontal: dimensions.$2),
            decoration: BoxDecoration(
              color: isDisabled ? colors.$1.withOpacity(0.5) : colors.$1,
              borderRadius: BorderRadius.circular(dimensions.$3),
              border: variant == ButtonVariant.outline
                  ? Border.all(color: theme.colorScheme.outline.withOpacity(isDisabled ? 0.3 : 1))
                  : null,
            ),
            child: Row(
              mainAxisSize: width != null ? MainAxisSize.max : MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (loading)
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: colors.$2,
                      ),
                    ),
                  )
                else if (icon != null)
                  Padding(
                    padding: EdgeInsets.only(right: label != null ? 6 : 0),
                    child: Icon(icon, size: dimensions.$4, color: isDisabled ? colors.$2.withOpacity(0.5) : colors.$2),
                  ),
                if (child != null)
                  child!
                else if (label != null)
                  Text(
                    label!,
                    style: TextStyle(
                      fontSize: dimensions.$5,
                      fontWeight: FontWeight.w600,
                      color: isDisabled ? colors.$2.withOpacity(0.5) : colors.$2,
                    ),
                  ),
                if (trailingIcon != null)
                  Padding(
                    padding: const EdgeInsets.only(left: 6),
                    child: Icon(trailingIcon, size: dimensions.$4, color: isDisabled ? colors.$2.withOpacity(0.5) : colors.$2),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  (Color, Color) _getColors(ThemeData theme) {
    return switch (variant) {
      ButtonVariant.primary => (theme.colorScheme.primary, theme.colorScheme.onPrimary),
      ButtonVariant.secondary => (theme.colorScheme.secondary, theme.colorScheme.onSecondary),
      ButtonVariant.outline => (Colors.transparent, theme.colorScheme.onSurface),
      ButtonVariant.ghost => (Colors.transparent, theme.colorScheme.onSurface),
      ButtonVariant.destructive => (theme.colorScheme.error, theme.colorScheme.onError),
      ButtonVariant.link => (Colors.transparent, theme.colorScheme.primary),
    };
  }

  // height, hPadding, radius, iconSize, fontSize
  (double, double, double, double, double) _getDimensions() {
    return switch (size) {
      ButtonSize.sm => (32, 12, 8, 14, 12),
      ButtonSize.md => (36, 16, 10, 16, 14),
      ButtonSize.lg => (40, 20, 10, 18, 14),
      ButtonSize.xl => (48, 32, 12, 20, 16),
      ButtonSize.icon => (36, 0, 10, 18, 14),
      ButtonSize.iconSm => (32, 0, 8, 16, 12),
    };
  }
}