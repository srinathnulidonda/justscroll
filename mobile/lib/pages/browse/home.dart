// lib/pages/browse/home.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:justscroll/lib/api.dart';
import 'package:justscroll/models/manga.dart';
import 'package:justscroll/lib/utils.dart' as utils;
import 'package:justscroll/components/manga/manga_grid.dart';
import 'package:justscroll/components/common/genre_toolbar.dart';
import 'package:justscroll/components/ui/button.dart';

final _homePopularProvider = FutureProvider<MangaListResponse>((ref) async {
  final data = await ApiClient.instance.getPopular(limit: 30);
  return MangaListResponse.fromJson(data);
});

final _homeLatestProvider = FutureProvider<MangaListResponse>((ref) async {
  final data = await ApiClient.instance.getLatestUpdates(limit: 20);
  return MangaListResponse.fromJson(data);
});

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  String _activeGenre = 'all';

  List<Manga> _filterByGenre(List<Manga> items) {
    if (_activeGenre == 'all') return items;
    final g = _activeGenre.toLowerCase().replaceAll('-', ' ');
    return items.where((m) => m.tags.any((t) {
      final tl = t.toLowerCase();
      return tl == g || tl.contains(g) || g.contains(tl);
    })).toList();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final popularAsync = ref.watch(_homePopularProvider);
    final latestAsync = ref.watch(_homeLatestProvider);

    final allPopular = utils.deduplicateManga(popularAsync.valueOrNull?.data ?? []);
    final allLatest = utils.deduplicateManga(latestAsync.valueOrNull?.data ?? []);
    final filteredPopular = _filterByGenre(allPopular);
    final filteredLatest = _filterByGenre(allLatest);
    final isFiltered = _activeGenre != 'all';

    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(_homePopularProvider);
        ref.invalidate(_homeLatestProvider);
      },
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(child: GenreToolbar(activeGenre: _activeGenre, onGenreChange: (g) => setState(() => _activeGenre = g))),
          if (isFiltered)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                child: Row(
                  children: [
                    Expanded(
                      child: Text.rich(
                        TextSpan(children: [
                          TextSpan(text: _activeGenre.replaceAll('-', ' '), style: TextStyle(fontWeight: FontWeight.w600, color: theme.colorScheme.onSurface)),
                          if (!popularAsync.isLoading) TextSpan(text: ' · ${filteredPopular.length + filteredLatest.length} results', style: TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.5))),
                        ]),
                        style: const TextStyle(fontSize: 13),
                      ),
                    ),
                    GestureDetector(
                      onTap: () => setState(() => _activeGenre = 'all'),
                      child: Row(
                        children: [
                          Icon(Icons.close, size: 14, color: theme.colorScheme.onSurface.withOpacity(0.5)),
                          const SizedBox(width: 2),
                          Text('Clear', style: TextStyle(fontSize: 12, color: theme.colorScheme.onSurface.withOpacity(0.5))),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _SectionHeader(title: 'Popular Now', onAction: () => context.go('/discover')),
                  const SizedBox(height: 12),
                  MangaGrid(
                    manga: isFiltered ? filteredPopular : allPopular,
                    loading: popularAsync.isLoading,
                    emptyTitle: isFiltered ? 'No popular ${_activeGenre.replaceAll('-', ' ')} manga' : 'No popular manga found',
                    emptyDescription: 'Try a different genre or check back later',
                  ),
                  const SizedBox(height: 32),
                  _SectionHeader(title: 'Latest Updates', onAction: () => context.go('/discover?tab=latest')),
                  const SizedBox(height: 12),
                  MangaGrid(
                    manga: isFiltered ? filteredLatest : allLatest,
                    loading: latestAsync.isLoading,
                    emptyTitle: isFiltered ? 'No latest ${_activeGenre.replaceAll('-', ' ')} manga' : 'No latest updates',
                    emptyDescription: 'Try a different genre or check back later',
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final VoidCallback onAction;
  const _SectionHeader({required this.title, required this.onAction});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Text(title, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: theme.colorScheme.onSurface)),
        const Spacer(),
        GestureDetector(
          onTap: onAction,
          child: Row(
            children: [
              Text('View all', style: TextStyle(fontSize: 13, color: theme.colorScheme.onSurface.withOpacity(0.5))),
              const SizedBox(width: 2),
              Icon(Icons.arrow_forward, size: 14, color: theme.colorScheme.onSurface.withOpacity(0.5)),
            ],
          ),
        ),
      ],
    );
  }
}