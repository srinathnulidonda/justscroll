// lib/components/manga/chapter_list.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:justscroll/models/chapter.dart';
import 'package:justscroll/components/ui/skeleton.dart';
import 'package:justscroll/components/common/empty_state.dart';
import 'package:justscroll/lib/utils.dart' as utils;

class ChapterList extends StatefulWidget {
  final List<Chapter> chapters;
  final bool loading;
  final String mangaId;

  const ChapterList({super.key, required this.chapters, this.loading = false, required this.mangaId});

  @override
  State<ChapterList> createState() => _ChapterListState();
}

class _ChapterListState extends State<ChapterList> {
  String _search = '';
  bool _sortAsc = false;
  int _visibleCount = 20;

  List<Chapter> get _filtered {
    var list = widget.chapters;
    if (_search.trim().isNotEmpty) {
      final q = _search.toLowerCase();
      list = list.where((ch) =>
        (ch.chapter?.toLowerCase().contains(q) ?? false) ||
        (ch.title?.toLowerCase().contains(q) ?? false) ||
        (ch.scanlationGroup?.toLowerCase().contains(q) ?? false)
      ).toList();
    }
    if (_sortAsc) list = list.reversed.toList();
    return list;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (widget.loading) {
      return Column(
        children: List.generate(8, (_) => Padding(
          padding: const EdgeInsets.only(bottom: 6),
          child: Skeleton(height: 56, borderRadius: BorderRadius.circular(10)),
        )),
      );
    }

    final filtered = _filtered;
    final visible = filtered.take(_visibleCount).toList();
    final hasMore = _visibleCount < filtered.length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: SizedBox(
                height: 36,
                child: TextField(
                  onChanged: (v) => setState(() { _search = v; _visibleCount = 20; }),
                  style: const TextStyle(fontSize: 13),
                  decoration: InputDecoration(
                    hintText: 'Search chapters…',
                    prefixIcon: const Icon(Icons.search, size: 18),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
                    filled: true,
                    fillColor: theme.colorScheme.surfaceContainerHighest.withOpacity(0.5),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Material(
              color: theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(8),
              child: InkWell(
                borderRadius: BorderRadius.circular(8),
                onTap: () => setState(() => _sortAsc = !_sortAsc),
                child: Container(
                  width: 36, height: 36,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: theme.colorScheme.outline.withOpacity(0.3)),
                  ),
                  child: Icon(Icons.swap_vert, size: 18, color: theme.colorScheme.onSurface.withOpacity(0.5)),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: theme.colorScheme.secondary,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text('${widget.chapters.length}', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: theme.colorScheme.onSecondary)),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (filtered.isEmpty)
          EmptyState(
            icon: Icons.description_outlined,
            title: 'No chapters available',
            description: _search.isNotEmpty ? 'Try a different search term' : 'This title may be external-only',
          )
        else ...[
          ...visible.map((ch) {
            final readable = ch.readable && ch.pages > 0;
            return Padding(
              padding: const EdgeInsets.only(bottom: 2),
              child: Material(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(10),
                child: InkWell(
                  onTap: readable ? () => context.go('/read/${ch.id}?manga=${widget.mangaId}') : null,
                  borderRadius: BorderRadius.circular(10),
                  child: Opacity(
                    opacity: readable ? 1 : 0.4,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                      child: Row(
                        children: [
                          Container(
                            width: 32, height: 32,
                            decoration: BoxDecoration(
                              color: readable
                                  ? theme.colorScheme.primary.withOpacity(0.05)
                                  : theme.colorScheme.surfaceContainerHighest,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              readable ? Icons.menu_book : Icons.open_in_new,
                              size: 16,
                              color: readable ? theme.colorScheme.onSurface.withOpacity(0.5) : theme.colorScheme.onSurface.withOpacity(0.3),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(ch.label, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
                                const SizedBox(height: 2),
                                Row(
                                  children: [
                                    if (ch.scanlationGroup != null && ch.scanlationGroup!.isNotEmpty)
                                      Flexible(child: Text(ch.scanlationGroup!, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 11, color: theme.colorScheme.onSurface.withOpacity(0.4)))),
                                    if (ch.pages > 0) ...[
                                      if (ch.scanlationGroup != null) Text(' · ', style: TextStyle(fontSize: 11, color: theme.colorScheme.onSurface.withOpacity(0.3))),
                                      Text('${ch.pages}p', style: TextStyle(fontSize: 11, color: theme.colorScheme.onSurface.withOpacity(0.4))),
                                    ],
                                    if (ch.publishedAt != null) ...[
                                      Text(' · ', style: TextStyle(fontSize: 11, color: theme.colorScheme.onSurface.withOpacity(0.3))),
                                      Text(utils.formatDate(ch.publishedAt), style: TextStyle(fontSize: 11, color: theme.colorScheme.onSurface.withOpacity(0.4))),
                                    ],
                                  ],
                                ),
                              ],
                            ),
                          ),
                          if (!readable)
                            Text('External', style: TextStyle(fontSize: 10, color: theme.colorScheme.onSurface.withOpacity(0.3))),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          }),
          if (hasMore)
            Center(
              child: Padding(
                padding: const EdgeInsets.only(top: 8),
                child: TextButton(
                  onPressed: () => setState(() => _visibleCount += 20),
                  child: Text('Load more (${filtered.length - _visibleCount} remaining)', style: const TextStyle(fontSize: 13)),
                ),
              ),
            ),
        ],
      ],
    );
  }
}