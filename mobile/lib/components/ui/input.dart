// lib/components/ui/input.dart
import 'package:flutter/material.dart';

class AppInput extends StatefulWidget {
  final String? label;
  final String? hint;
  final String? error;
  final String? helperText;
  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onSubmitted;
  final IconData? prefixIcon;
  final bool obscureText;
  final bool autofocus;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;
  final int maxLines;
  final bool enabled;

  const AppInput({
    super.key,
    this.label,
    this.hint,
    this.error,
    this.helperText,
    this.controller,
    this.onChanged,
    this.onSubmitted,
    this.prefixIcon,
    this.obscureText = false,
    this.autofocus = false,
    this.keyboardType,
    this.validator,
    this.maxLines = 1,
    this.enabled = true,
  });

  @override
  State<AppInput> createState() => _AppInputState();
}

class _AppInputState extends State<AppInput> {
  bool _showPassword = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isPassword = widget.obscureText;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (widget.label != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Text(
              widget.label!,
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: theme.colorScheme.onSurface.withOpacity(0.8)),
            ),
          ),
        TextFormField(
          controller: widget.controller,
          onChanged: widget.onChanged,
          onFieldSubmitted: (_) => widget.onSubmitted?.call(),
          obscureText: isPassword && !_showPassword,
          autofocus: widget.autofocus,
          keyboardType: widget.keyboardType,
          validator: widget.validator,
          maxLines: widget.maxLines,
          enabled: widget.enabled,
          style: const TextStyle(fontSize: 14),
          decoration: InputDecoration(
            hintText: widget.hint,
            prefixIcon: widget.prefixIcon != null ? Icon(widget.prefixIcon, size: 18) : null,
            suffixIcon: isPassword
                ? IconButton(
                    icon: Icon(_showPassword ? Icons.visibility_off : Icons.visibility, size: 18),
                    onPressed: () => setState(() => _showPassword = !_showPassword),
                  )
                : null,
            errorText: widget.error,
            helperText: widget.helperText,
            errorStyle: TextStyle(fontSize: 12, color: theme.colorScheme.error),
          ),
        ),
      ],
    );
  }
}