// lib/pages/browse/discover.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:justscroll/lib/api.dart';
import 'package:justscroll/models/manga.dart';
import 'package:justscroll/lib/utils.dart' as utils;
import 'package:justscroll/components/manga/manga_grid.dart';
import 'package:justscroll/components/ui/button.dart';

const _limit = 24;

final _discoverProvider = FutureProvider.family<MangaListResponse, ({String tab, int offset})>((ref, params) async {
  final data = params.tab == 'latest'
      ? await ApiClient.instance.getLatestUpdates(limit: _limit, offset: params.offset)
      : await ApiClient.instance.getPopular(limit: _limit, offset: params.offset);
  return MangaListResponse.fromJson(data);
});

class DiscoverPage extends ConsumerStatefulWidget {
  const DiscoverPage({super.key});

  @override
  ConsumerState<DiscoverPage> createState() => _DiscoverPageState();
}

class _DiscoverPageState extends ConsumerState<DiscoverPage> {
  String _tab = 'popular';
  int _offset = 0;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dataAsync = ref.watch(_discoverProvider((tab: _tab, offset: _offset)));
    final items = utils.deduplicateManga(dataAsync.valueOrNull?.data ?? []);
    final total = dataAsync.valueOrNull?.total ?? 0;
    final totalPages = (total / _limit).ceil();
    final currentPage = (_offset / _limit).floor() + 1;

    return RefreshIndicator(
      onRefresh: () async => ref.invalidate(_discoverProvider((tab: _tab, offset: _offset))),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          children: [
            _TabBar(activeTab: _tab, onTabChange: (t) => setState(() { _tab = t; _offset = 0; })),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(_tab == 'popular' ? 'Popular Manga' : 'Latest Updates', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: theme.colorScheme.onSurface)),
                  const SizedBox(height: 4),
                  Text(_tab == 'popular' ? 'The most popular manga right now' : 'Recently updated manga titles', style: TextStyle(fontSize: 14, color: theme.colorScheme.onSurface.withOpacity(0.5))),
                  if (!dataAsync.isLoading && items.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text('${items.length} titles${totalPages > 1 ? ' · Page $currentPage of $totalPages' : ''}', style: TextStyle(fontSize: 13, color: theme.colorScheme.onSurface.withOpacity(0.5))),
                  ],
                  const SizedBox(height: 16),
                  MangaGrid(manga: items, loading: dataAsync.isLoading, emptyTitle: 'No manga found'),
                  if (totalPages > 1 && !dataAsync.isLoading) ...[
                    const SizedBox(height: 24),
                    _Pagination(currentPage: currentPage, totalPages: totalPages, onPageChange: (p) => setState(() => _offset = (p - 1) * _limit)),
                  ],
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TabBar extends StatelessWidget {
  final String activeTab;
  final ValueChanged<String> onTabChange;
  const _TabBar({required this.activeTab, required this.onTabChange});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(border: Border(bottom: BorderSide(color: theme.colorScheme.outline.withOpacity(0.1)))),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(3),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.5),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: theme.colorScheme.outline.withOpacity(0.1)),
            ),
            child: Row(
              children: [
                _TabButton(label: 'Popular', icon: Icons.local_fire_department, active: activeTab == 'popular', onTap: () => onTabChange('popular')),
                const SizedBox(width: 4),
                _TabButton(label: 'Latest', icon: Icons.auto_awesome, active: activeTab == 'latest', onTap: () => onTabChange('latest')),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TabButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool active;
  final VoidCallback onTap;
  const _TabButton({required this.label, required this.icon, required this.active, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: active ? theme.colorScheme.primary.withOpacity(0.08) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(icon, size: 16, color: active ? theme.colorScheme.primary : theme.colorScheme.onSurface.withOpacity(0.4)),
            const SizedBox(width: 6),
            Text(label, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: active ? theme.colorScheme.primary : theme.colorScheme.onSurface.withOpacity(0.5))),
          ],
        ),
      ),
    );
  }
}

class _Pagination extends StatelessWidget {
  final int currentPage;
  final int totalPages;
  final ValueChanged<int> onPageChange;
  const _Pagination({required this.currentPage, required this.totalPages, required this.onPageChange});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final pages = utils.generatePageNumbers(currentPage, totalPages);

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        AppButton(
          icon: Icons.chevron_left,
          variant: ButtonVariant.outline,
          size: ButtonSize.sm,
          disabled: currentPage <= 1,
          onPressed: () => onPageChange(currentPage - 1),
        ),
        const SizedBox(width: 8),
        ...pages.map((p) {
          if (p == -1) return Padding(padding: const EdgeInsets.symmetric(horizontal: 4), child: Text('…', style: TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.4))));
          final active = p == currentPage;
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 2),
            child: GestureDetector(
              onTap: () => onPageChange(p),
              child: Container(
                width: 32, height: 32,
                decoration: BoxDecoration(
                  color: active ? theme.colorScheme.primary : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(child: Text('$p', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: active ? theme.colorScheme.onPrimary : theme.colorScheme.onSurface.withOpacity(0.5)))),
              ),
            ),
          );
        }),
        const SizedBox(width: 8),
        AppButton(
          icon: Icons.chevron_right,
          variant: ButtonVariant.outline,
          size: ButtonSize.sm,
          disabled: currentPage >= totalPages,
          onPressed: () => onPageChange(currentPage + 1),
        ),
      ],
    );
  }
}