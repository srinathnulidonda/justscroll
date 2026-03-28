// lib/pages/browse/search.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:justscroll/lib/api.dart';
import 'package:justscroll/models/manga.dart';
import 'package:justscroll/lib/utils.dart' as utils;
import 'package:justscroll/components/manga/manga_grid.dart';
import 'package:justscroll/components/ui/button.dart';

const _limit = 24;

final _searchProvider = FutureProvider.family<MangaListResponse, ({String query, int offset})>((ref, params) async {
  if (params.query.isEmpty) return const MangaListResponse(data: [], total: 0);
  final data = await ApiClient.instance.searchManga(params.query, limit: _limit, offset: params.offset);
  return MangaListResponse.fromJson(data);
});

class SearchPage extends ConsumerStatefulWidget {
  final String query;
  const SearchPage({super.key, required this.query});

  @override
  ConsumerState<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends ConsumerState<SearchPage> {
  late TextEditingController _controller;
  int _offset = 0;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.query);
  }

  @override
  void didUpdateWidget(SearchPage old) {
    super.didUpdateWidget(old);
    if (old.query != widget.query) {
      _controller.text = widget.query;
      _offset = 0;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _search() {
    final q = _controller.text.trim();
    if (q.isNotEmpty) {
      context.go('/search?q=${Uri.encodeComponent(q)}');
      setState(() => _offset = 0);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final query = widget.query;

    if (query.isEmpty) return _buildEmptySearch(context);

    final dataAsync = ref.watch(_searchProvider((query: query, offset: _offset)));
    final items = utils.deduplicateManga(dataAsync.valueOrNull?.data ?? []);
    final total = dataAsync.valueOrNull?.total ?? 0;
    final totalPages = (total / _limit).ceil();
    final currentPage = (_offset / _limit).floor() + 1;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Search Results', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: theme.colorScheme.onSurface)),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.5),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: theme.colorScheme.outline.withOpacity(0.2)),
            ),
            child: Row(
              children: [
                Icon(Icons.search, size: 14, color: theme.colorScheme.onSurface.withOpacity(0.4)),
                const SizedBox(width: 8),
                Text('Results for ', style: TextStyle(fontSize: 13, color: theme.colorScheme.onSurface.withOpacity(0.5))),
                Flexible(child: Text('"$query"', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: theme.colorScheme.onSurface), maxLines: 1, overflow: TextOverflow.ellipsis)),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: () { _controller.clear(); context.go('/search'); },
                  child: Icon(Icons.close, size: 16, color: theme.colorScheme.onSurface.withOpacity(0.4)),
                ),
              ],
            ),
          ),
          if (!dataAsync.isLoading && items.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text('${items.length} titles${totalPages > 1 ? ' · Page $currentPage of $totalPages' : ''}', style: TextStyle(fontSize: 13, color: theme.colorScheme.onSurface.withOpacity(0.5))),
          ],
          const SizedBox(height: 16),
          MangaGrid(
            manga: items,
            loading: dataAsync.isLoading,
            emptyTitle: 'No results for "$query"',
            emptyDescription: 'Try a different search term',
            emptyAction: () { _controller.clear(); context.go('/search'); },
            emptyActionLabel: 'Clear search',
          ),
          if (totalPages > 1 && !dataAsync.isLoading) ...[
            const SizedBox(height: 24),
            _SearchPagination(currentPage: currentPage, totalPages: totalPages, onPageChange: (p) => setState(() => _offset = (p - 1) * _limit)),
          ],
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildEmptySearch(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 64),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(color: theme.colorScheme.surfaceContainerHighest, borderRadius: BorderRadius.circular(16)),
              child: Icon(Icons.search, size: 40, color: theme.colorScheme.onSurface.withOpacity(0.3)),
            ),
            const SizedBox(height: 20),
            Text('Search Manga', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700, color: theme.colorScheme.onSurface)),
            const SizedBox(height: 8),
            Text('Search across thousands of manga, manhwa, and comic titles', textAlign: TextAlign.center, style: TextStyle(fontSize: 14, color: theme.colorScheme.onSurface.withOpacity(0.5))),
            const SizedBox(height: 24),
            SizedBox(
              width: 340,
              height: 48,
              child: TextField(
                controller: _controller,
                autofocus: true,
                onSubmitted: (_) => _search(),
                decoration: InputDecoration(
                  hintText: 'Type a title and press Enter…',
                  prefixIcon: const Icon(Icons.search, size: 20),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextButton.icon(
              onPressed: () => context.go('/discover'),
              icon: const Icon(Icons.explore, size: 18),
              label: const Text('Or browse popular & latest manga'),
            ),
          ],
        ),
      ),
    );
  }
}

class _SearchPagination extends StatelessWidget {
  final int currentPage;
  final int totalPages;
  final ValueChanged<int> onPageChange;
  const _SearchPagination({required this.currentPage, required this.totalPages, required this.onPageChange});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final pages = utils.generatePageNumbers(currentPage, totalPages);
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        AppButton(icon: Icons.chevron_left, variant: ButtonVariant.outline, size: ButtonSize.sm, disabled: currentPage <= 1, onPressed: () => onPageChange(currentPage - 1)),
        const SizedBox(width: 8),
        ...pages.map((p) {
          if (p == -1) return Padding(padding: const EdgeInsets.symmetric(horizontal: 4), child: Text('…', style: TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.4))));
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 2),
            child: GestureDetector(
              onTap: () => onPageChange(p),
              child: Container(
                width: 32, height: 32,
                decoration: BoxDecoration(color: p == currentPage ? theme.colorScheme.primary : Colors.transparent, borderRadius: BorderRadius.circular(8)),
                child: Center(child: Text('$p', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: p == currentPage ? theme.colorScheme.onPrimary : theme.colorScheme.onSurface.withOpacity(0.5)))),
              ),
            ),
          );
        }),
        const SizedBox(width: 8),
        AppButton(icon: Icons.chevron_right, variant: ButtonVariant.outline, size: ButtonSize.sm, disabled: currentPage >= totalPages, onPressed: () => onPageChange(currentPage + 1)),
      ],
    );
  }
}