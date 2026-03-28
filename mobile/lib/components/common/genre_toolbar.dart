// lib/components/common/genre_toolbar.dart
import 'package:flutter/material.dart';
import 'package:justscroll/lib/constants.dart';

class GenreToolbar extends StatefulWidget {
  final String activeGenre;
  final ValueChanged<String> onGenreChange;

  const GenreToolbar({
    super.key,
    required this.activeGenre,
    required this.onGenreChange,
  });

  @override
  State<GenreToolbar> createState() => _GenreToolbarState();
}

class _GenreToolbarState extends State<GenreToolbar> {
  final ScrollController _scrollController = ScrollController();
  final Map<String, GlobalKey> _keys = {};

  @override
  void initState() {
    super.initState();
    for (final g in kGenres) {
      _keys[g['key']!] = GlobalKey();
    }
    WidgetsBinding.instance
        .addPostFrameCallback((_) => _scrollToActive());
  }

  @override
  void didUpdateWidget(GenreToolbar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.activeGenre != widget.activeGenre) {
      WidgetsBinding.instance
          .addPostFrameCallback((_) => _scrollToActive());
    }
  }

  void _scrollToActive() {
    final key = _keys[widget.activeGenre];
    if (key?.currentContext != null) {
      Scrollable.ensureVisible(
        key!.currentContext!,
        alignment: 0.4,
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeOutCubic,
      );
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return RepaintBoundary(
      child: Container(
        decoration: BoxDecoration(
          color: theme.scaffoldBackgroundColor,
          border: Border(
            bottom: BorderSide(
              color: theme.colorScheme.outline.withOpacity(0.1),
            ),
          ),
        ),
        child: SingleChildScrollView(
          controller: _scrollController,
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(
              horizontal: 12, vertical: 8),
          physics: const BouncingScrollPhysics(),
          child: Row(
            children: kGenres.map((genre) {
              final key = genre['key']!;
              final label = genre['label']!;
              final isActive = widget.activeGenre == key;

              return Padding(
                key: _keys[key],
                padding: const EdgeInsets.only(right: 6),
                child: GestureDetector(
                  onTap: () => widget.onGenreChange(key),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: isActive
                          ? theme.colorScheme.primary
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isActive
                            ? theme.colorScheme.primary
                            : theme.colorScheme.outline
                                .withOpacity(0.25),
                      ),
                    ),
                    child: Text(
                      label,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: isActive
                            ? theme.colorScheme.onPrimary
                            : theme.colorScheme.onSurface
                                .withOpacity(0.55),
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}