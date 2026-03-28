// lib/components/ui/dropdown.dart
import 'package:flutter/material.dart';

class AppDropdown<T> extends StatelessWidget {
  final T? value;
  final List<DropdownItem<T>> items;
  final ValueChanged<T?> onChanged;
  final String? hint;
  final Widget? icon;

  const AppDropdown({
    super.key,
    this.value,
    required this.items,
    required this.onChanged,
    this.hint,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: theme.colorScheme.outline.withOpacity(0.5)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<T>(
          value: value,
          isExpanded: true,
          hint: hint != null ? Text(hint!, style: TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.5))) : null,
          icon: icon ?? Icon(Icons.keyboard_arrow_down, color: theme.colorScheme.onSurface.withOpacity(0.5)),
          borderRadius: BorderRadius.circular(12),
          dropdownColor: theme.colorScheme.surface,
          items: items.map((item) => DropdownMenuItem<T>(
            value: item.value,
            child: Row(
              children: [
                if (item.icon != null) ...[
                  Icon(item.icon, size: 18, color: theme.colorScheme.onSurface.withOpacity(0.6)),
                  const SizedBox(width: 10),
                ],
                Text(item.label, style: const TextStyle(fontSize: 14)),
              ],
            ),
          )).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}

class DropdownItem<T> {
  final T value;
  final String label;
  final IconData? icon;
  const DropdownItem({required this.value, required this.label, this.icon});
}

class AppPopupMenu<T> extends StatelessWidget {
  final List<PopupItem<T>> items;
  final ValueChanged<T> onSelected;
  final Widget? child;
  final IconData? icon;

  const AppPopupMenu({
    super.key,
    required this.items,
    required this.onSelected,
    this.child,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<T>(
      onSelected: onSelected,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      offset: const Offset(0, 8),
      child: child,
      icon: icon != null ? Icon(icon) : null,
      itemBuilder: (ctx) => items.map((item) {
        if (item.isDivider) return const PopupMenuDivider() as PopupMenuEntry<T>;
        return PopupMenuItem<T>(
          value: item.value,
          child: Row(
            children: [
              if (item.icon != null) ...[
                Icon(item.icon, size: 18, color: item.destructive ? Theme.of(ctx).colorScheme.error : Theme.of(ctx).colorScheme.onSurface.withOpacity(0.6)),
                const SizedBox(width: 10),
              ],
              Text(item.label, style: TextStyle(fontSize: 14, color: item.destructive ? Theme.of(ctx).colorScheme.error : null)),
            ],
          ),
        );
      }).toList(),
    );
  }
}

class PopupItem<T> {
  final T? value;
  final String label;
  final IconData? icon;
  final bool destructive;
  final bool isDivider;
  const PopupItem({this.value, this.label = '', this.icon, this.destructive = false, this.isDivider = false});
  const PopupItem.divider() : value = null, label = '', icon = null, destructive = false, isDivider = true;
}