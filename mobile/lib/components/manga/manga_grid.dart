// lib/components/manga/manga_grid.dart
import 'package:flutter/material.dart';
import 'package:justscroll/models/manga.dart';
import 'package:justscroll/components/manga/manga_card.dart';
import 'package:justscroll/components/ui/skeleton.dart';
import 'package:justscroll/components/common/empty_state.dart';

class MangaGrid extends StatelessWidget {
  final List<Manga> manga;
  final bool loading;
  final String? emptyTitle;
  final String? emptyDescription;
  final VoidCallback? emptyAction;
  final String? emptyActionLabel;

  const MangaGrid({
    super.key,
    required this.manga,
    this.loading = false,
    this.emptyTitle,
    this.emptyDescription,
    this.emptyAction,
    this.emptyActionLabel,
  });

  @override
  Widget build(BuildContext context) {
    if (loading) return const MangaGridSkeleton();

    if (manga.isEmpty) {
      return EmptyState(
        icon: Icons.search_off,
        title: emptyTitle ?? 'No manga found',
        description:
            emptyDescription ?? 'Try adjusting your search or filters',
        action: emptyAction,
        actionLabel: emptyActionLabel,
      );
    }

    final w = MediaQuery.of(context).size.width;
    final cols =
        w < 400 ? 2 : w < 640 ? 3 : w < 768 ? 4 : w < 1024 ? 5 : 6;

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      addRepaintBoundaries: true,
      addAutomaticKeepAlives: false,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: cols,
        childAspectRatio: 0.48,
        crossAxisSpacing: 12,
        mainAxisSpacing: 16,
      ),
      itemCount: manga.length,
      itemBuilder: (_, i) {
        final m = manga[i];
        return MangaCard(
          key: ValueKey(m.id),
          id: m.id,
          title: m.title,
          coverUrl: m.coverUrl,
          author: m.author,
          status: m.status,
          score: m.score,
          year: m.year,
          tags: m.tags,
        );
      },
    );
  }
}