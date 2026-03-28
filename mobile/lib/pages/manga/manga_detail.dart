// lib/pages/manga/manga_detail.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:justscroll/lib/api.dart';
import 'package:justscroll/lib/constants.dart';
import 'package:justscroll/lib/utils.dart' as utils;
import 'package:justscroll/models/manga.dart';
import 'package:justscroll/models/chapter.dart';
import 'package:justscroll/models/character.dart';
import 'package:justscroll/models/user.dart';
import 'package:justscroll/stores/auth_store.dart';
import 'package:justscroll/stores/toast_store.dart';
import 'package:justscroll/components/common/optimized_image.dart';
import 'package:justscroll/components/common/empty_state.dart';
import 'package:justscroll/components/manga/chapter_list.dart';
import 'package:justscroll/components/manga/character_card.dart';
import 'package:justscroll/components/ui/badge.dart';
import 'package:justscroll/components/ui/button.dart';
import 'package:justscroll/components/ui/skeleton.dart';
import 'package:justscroll/components/ui/tabs.dart';

final _mangaProvider = FutureProvider.family<Manga, String>((ref, id) async {
  final data = await ApiClient.instance.getMangaDetail(id);
  return Manga.fromJson(data);
});

final _chaptersProvider =
    FutureProvider.family<List<Chapter>, String>((ref, id) async {
  if (id.startsWith('mal-') || id.startsWith('cv-')) return [];
  final data = await ApiClient.instance.getMangaChapters(id);
  return ChapterListResponse.fromJson(data).data;
});

final _charactersProvider =
    FutureProvider.family<CharacterListResponse, String>((ref, id) async {
  final data = await ApiClient.instance.getMangaCharacters(id);
  return CharacterListResponse.fromJson(data);
});

final _bookmarksProvider = FutureProvider<BookmarkListResponse>((ref) async {
  final auth = ref.watch(authStoreProvider);
  if (!auth.isAuthenticated) {
    return const BookmarkListResponse(data: [], total: 0);
  }
  final data = await ApiClient.instance.getBookmarks();
  return BookmarkListResponse.fromJson(data);
});

class MangaDetailPage extends ConsumerStatefulWidget {
  final String id;
  const MangaDetailPage({super.key, required this.id});

  @override
  ConsumerState<MangaDetailPage> createState() => _MangaDetailPageState();
}

class _MangaDetailPageState extends ConsumerState<MangaDetailPage> {
  int _tabIndex = 0;
  bool _descExpanded = false;
  bool _bookmarkLoading = false;

  void _goBack() {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go('/');
    }
  }

  @override
  Widget build(BuildContext context) {
    final mangaAsync = ref.watch(_mangaProvider(widget.id));
    final chaptersAsync = ref.watch(_chaptersProvider(widget.id));
    final charsAsync = ref.watch(_charactersProvider(widget.id));

    return mangaAsync.when(
      loading: () => _buildLoadingState(context),
      error: (e, _) => EmptyState(
        icon: Icons.error_outline,
        title: 'Manga not found',
        description: 'This title may have been removed.',
        action: _goBack,
        actionLabel: 'Go Back',
      ),
      data: (manga) {
        final chapters = chaptersAsync.valueOrNull ?? [];
        final characters = charsAsync.valueOrNull;

        return AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: _MangaDetailContent(
            key: ValueKey('detail-${widget.id}'),
            manga: manga,
            mangaId: widget.id,
            chapters: chapters,
            chaptersLoading: chaptersAsync.isLoading,
            chaptersError: chaptersAsync.hasError,
            characters: characters,
            charsLoading: charsAsync.isLoading,
            charsError: charsAsync.hasError,
            tabIndex: _tabIndex,
            descExpanded: _descExpanded,
            bookmarkLoading: _bookmarkLoading,
            onTabChanged: (i) => setState(() => _tabIndex = i),
            onDescToggle: () => setState(() => _descExpanded = !_descExpanded),
            onBookmarkLoading: (v) => setState(() => _bookmarkLoading = v),
            onBack: _goBack,
            onRefresh: () {
              ref.invalidate(_mangaProvider(widget.id));
              ref.invalidate(_chaptersProvider(widget.id));
              ref.invalidate(_charactersProvider(widget.id));
            },
            ref: ref,
          ),
        );
      },
    );
  }

  Widget _buildLoadingState(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;
    return Stack(
      children: [
        const DetailSkeleton(),
        Positioned(
          top: topPadding - 20,
          left: 12,
          child: Material(
            color: Colors.black.withOpacity(0.4),
            borderRadius: BorderRadius.circular(12),
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: _goBack,
              child: const Padding(
                padding: EdgeInsets.all(10),
                child: Icon(
                  Icons.arrow_back_rounded,
                  size: 20,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _MangaDetailContent extends StatelessWidget {
  final Manga manga;
  final String mangaId;
  final List<Chapter> chapters;
  final bool chaptersLoading;
  final bool chaptersError;
  final CharacterListResponse? characters;
  final bool charsLoading;
  final bool charsError;
  final int tabIndex;
  final bool descExpanded;
  final bool bookmarkLoading;
  final ValueChanged<int> onTabChanged;
  final VoidCallback onDescToggle;
  final ValueChanged<bool> onBookmarkLoading;
  final VoidCallback onBack;
  final VoidCallback onRefresh;
  final WidgetRef ref;

  const _MangaDetailContent({
    super.key,
    required this.manga,
    required this.mangaId,
    required this.chapters,
    required this.chaptersLoading,
    required this.chaptersError,
    required this.characters,
    required this.charsLoading,
    required this.charsError,
    required this.tabIndex,
    required this.descExpanded,
    required this.bookmarkLoading,
    required this.onTabChanged,
    required this.onDescToggle,
    required this.onBookmarkLoading,
    required this.onBack,
    required this.onRefresh,
    required this.ref,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final sourceInfo = kSources[manga.source] ?? kSources['mangadex']!;
    final statusInfo = manga.status != null ? kStatusMap[manga.status] : null;
    final description = utils.stripHtml(manga.description);
    final bookmarks = ref.watch(_bookmarksProvider).valueOrNull?.data ?? [];
    final isBookmarked = bookmarks.any((b) => b.mangaId == mangaId);
    final auth = ref.watch(authStoreProvider);
    final firstReadable = chapters
        .cast<Chapter?>()
        .firstWhere((ch) => ch!.readable && ch.pages > 0, orElse: () => null);

    return RefreshIndicator(
      onRefresh: () async => onRefresh(),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _Hero(
              manga: manga,
              sourceInfo: sourceInfo,
              statusInfo: statusInfo,
              onBack: onBack,
            ),
            _Stats(manga: manga, chapters: chapters),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: _Actions(
                mangaId: mangaId,
                manga: manga,
                firstReadable: firstReadable,
                isBookmarked: isBookmarked,
                bookmarkLoading: bookmarkLoading,
                auth: auth,
                ref: ref,
                onBookmarkLoading: onBookmarkLoading,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (description.isNotEmpty) ...[
                    const SizedBox(height: 20),
                    _Description(
                      text: description,
                      expanded: descExpanded,
                      onToggle: onDescToggle,
                    ),
                  ],
                  if (manga.tags.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    _Tags(tags: manga.tags),
                  ],
                  const SizedBox(height: 24),
                  AppTabs(
                    tabs: [
                      AppTab(
                        label: 'Chapters',
                        icon: Icons.menu_book,
                        count: chapters.length,
                      ),
                      AppTab(
                        label: 'Characters',
                        icon: Icons.people,
                        count: characters?.total,
                      ),
                    ],
                    selectedIndex: tabIndex,
                    onChanged: onTabChanged,
                    children: [
                      mangaId.startsWith('mal-') || mangaId.startsWith('cv-')
                          ? const EmptyState(
                              icon: Icons.menu_book,
                              title: 'Chapters unavailable',
                              description:
                                  'This source doesn\'t provide chapter reading.',
                            )
                          : chaptersLoading
                              ? _chaptersSkeleton()
                              : chaptersError
                                  ? const EmptyState(
                                      icon: Icons.error_outline,
                                      title: 'Failed to load chapters',
                                    )
                                  : ChapterList(
                                      chapters: chapters,
                                      mangaId: mangaId,
                                    ),
                      charsLoading
                          ? _charsSkeleton()
                          : charsError
                              ? const EmptyState(
                                  icon: Icons.error_outline,
                                  title: 'Failed to load characters',
                                )
                              : (characters?.data.isEmpty ?? true)
                                  ? const EmptyState(
                                      icon: Icons.people,
                                      title: 'No characters available',
                                    )
                                  : CharacterGrid(
                                      characters: characters!.data,
                                    ),
                    ],
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _chaptersSkeleton() {
    return Column(
      children: List.generate(
        5,
        (_) => Padding(
          padding: const EdgeInsets.only(bottom: 6),
          child: Skeleton(
            height: 56,
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
    );
  }

  Widget _charsSkeleton() {
    return Column(
      children: List.generate(
        4,
        (_) => Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Skeleton(
            height: 72,
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }
}

class _Hero extends StatelessWidget {
  final Manga manga;
  final SourceInfo sourceInfo;
  final StatusInfo? statusInfo;
  final VoidCallback onBack;

  const _Hero({
    required this.manga,
    required this.sourceInfo,
    this.statusInfo,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final coverUrl = utils.proxyImage(manga.coverUrl);
    final hasCover = coverUrl.isNotEmpty;
    final topPadding = MediaQuery.of(context).padding.top;

    return RepaintBoundary(
      child: Stack(
        children: [
          // Background
          if (hasCover)
            SizedBox(
              height: 220,
              width: double.infinity,
              child: Stack(
                children: [
                  Positioned.fill(
                    child: Image.network(
                      coverUrl,
                      fit: BoxFit.cover,
                      cacheWidth: 600,
                      errorBuilder: (_, __, ___) => Container(
                        color: theme.colorScheme.surfaceContainerHighest,
                      ),
                    ),
                  ),
                  const Positioned.fill(
                    child: ColoredBox(color: Color(0x88000000)),
                  ),
                  Positioned.fill(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            theme.scaffoldBackgroundColor,
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            )
          else
            SizedBox(
              height: 120,
              width: double.infinity,
              child: ColoredBox(
                color: theme.colorScheme.surfaceContainerHighest,
              ),
            ),

          // Back button - at the very top
          Positioned(
            top: topPadding -20,
            left: 12,
            right: 12,
            child: Row(
              children: [
                Material(
                  color: Colors.black.withOpacity(0.4),
                  borderRadius: BorderRadius.circular(12),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: onBack,
                    child: const Padding(
                      padding: EdgeInsets.all(10),
                      child: Icon(
                        Icons.arrow_back_rounded,
                        size: 20,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                const Spacer(),
              ],
            ),
          ),

          // Content
          Padding(
            padding: EdgeInsets.fromLTRB(16, hasCover ? 100 : 60, 16, 0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                // Cover
                SizedBox(
                  width: 110,
                  child: AspectRatio(
                    aspectRatio: 2 / 3,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x4D000000),
                            blurRadius: 16,
                            offset: Offset(0, 6),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: OptimizedImage(
                          src: manga.coverUrl,
                          fit: BoxFit.cover,
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),

                // Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Wrap(
                        spacing: 6,
                        runSpacing: 4,
                        children: [
                          AppBadge(
                            label: sourceInfo.label,
                            bgColor: sourceInfo.bgColor,
                            textColor: sourceInfo.textColor,
                            fontSize: 10,
                          ),
                          if (statusInfo != null)
                            AppBadge(
                              label: statusInfo!.label,
                              bgColor: statusInfo!.bgColor,
                              textColor: statusInfo!.textColor,
                              fontSize: 10,
                            ),
                          if (manga.contentRating != null)
                            AppBadge(
                              label: manga.contentRating!,
                              variant: BadgeVariant.outline,
                              fontSize: 10,
                            ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        manga.title,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: theme.colorScheme.onSurface,
                          height: 1.2,
                        ),
                      ),
                      if (manga.author != null) ...[
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(
                              Icons.person_outline,
                              size: 14,
                              color:
                                  theme.colorScheme.onSurface.withOpacity(0.5),
                            ),
                            const SizedBox(width: 4),
                            Flexible(
                              child: Text(
                                manga.author!,
                                style: TextStyle(
                                  fontSize: 13,
                                  color: theme.colorScheme.onSurface
                                      .withOpacity(0.5),
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (manga.artist != null &&
                                manga.artist != manga.author) ...[
                              Text(
                                ' · ',
                                style: TextStyle(
                                  color: theme.colorScheme.onSurface
                                      .withOpacity(0.3),
                                ),
                              ),
                              Icon(
                                Icons.palette_outlined,
                                size: 14,
                                color: theme.colorScheme.onSurface
                                    .withOpacity(0.5),
                              ),
                              const SizedBox(width: 4),
                              Flexible(
                                child: Text(
                                  manga.artist!,
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: theme.colorScheme.onSurface
                                        .withOpacity(0.5),
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Stats extends StatelessWidget {
  final Manga manga;
  final List<Chapter> chapters;

  const _Stats({required this.manga, required this.chapters});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final stats = <_StatData>[];

    if (manga.score != null) {
      stats.add(_StatData(
        Icons.star,
        'Score',
        manga.score!.toStringAsFixed(1),
        const Color(0xFFF59E0B),
      ));
    }
    if (manga.members != null) {
      stats.add(_StatData(
        Icons.people,
        'Members',
        utils.formatNumber(manga.members),
        const Color(0xFF3B82F6),
      ));
    }
    if (chapters.isNotEmpty) {
      stats.add(_StatData(
        Icons.tag,
        'Chapters',
        chapters.length.toString(),
        const Color(0xFF10B981),
      ));
    }
    if (manga.year != null) {
      stats.add(_StatData(
        Icons.calendar_today,
        'Year',
        manga.year.toString(),
        const Color(0xFF8B5CF6),
      ));
    }

    if (stats.isEmpty) return const SizedBox(height: 16);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Row(
        children: stats
            .map((s) => Expanded(
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: theme.colorScheme.outline.withOpacity(0.2),
                      ),
                    ),
                    child: Column(
                      children: [
                        Icon(s.icon, size: 16, color: s.color),
                        const SizedBox(height: 4),
                        Text(
                          s.value,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                        Text(
                          s.label,
                          style: TextStyle(
                            fontSize: 10,
                            color:
                                theme.colorScheme.onSurface.withOpacity(0.5),
                          ),
                        ),
                      ],
                    ),
                  ),
                ))
            .toList(),
      ),
    );
  }
}

class _StatData {
  final IconData icon;
  final String label;
  final String value;
  final Color color;
  const _StatData(this.icon, this.label, this.value, this.color);
}

class _Actions extends StatelessWidget {
  final String mangaId;
  final Manga manga;
  final Chapter? firstReadable;
  final bool isBookmarked;
  final bool bookmarkLoading;
  final AuthState auth;
  final WidgetRef ref;
  final ValueChanged<bool> onBookmarkLoading;

  const _Actions({
    required this.mangaId,
    required this.manga,
    required this.firstReadable,
    required this.isBookmarked,
    required this.bookmarkLoading,
    required this.auth,
    required this.ref,
    required this.onBookmarkLoading,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        if (firstReadable != null)
          Expanded(
            child: AppButton(
              label: 'Start Reading',
              icon: Icons.menu_book,
              onPressed: () =>
                  context.go('/read/${firstReadable!.id}?manga=$mangaId'),
              size: ButtonSize.lg,
            ),
          ),
        if (firstReadable != null) const SizedBox(width: 10),
        if (auth.isAuthenticated)
          Expanded(
            child: AppButton(
              label: isBookmarked ? 'Saved' : 'Save',
              icon:
                  isBookmarked ? Icons.bookmark : Icons.bookmark_add_outlined,
              variant:
                  isBookmarked ? ButtonVariant.secondary : ButtonVariant.outline,
              loading: bookmarkLoading,
              onPressed: () async {
                onBookmarkLoading(true);
                try {
                  if (isBookmarked) {
                    await ApiClient.instance.removeBookmark(mangaId);
                    ref.read(toastProvider.notifier).success('Bookmark removed');
                  } else {
                    await ApiClient.instance.addBookmark(
                      mangaId,
                      mangaTitle: manga.title,
                      coverUrl: manga.coverUrl,
                    );
                    ref.read(toastProvider.notifier).success('Bookmarked!');
                  }
                  ref.invalidate(_bookmarksProvider);
                } catch (e) {
                  ref
                      .read(toastProvider.notifier)
                      .error('Failed to update bookmark');
                }
                onBookmarkLoading(false);
              },
              size: ButtonSize.lg,
            ),
          )
        else
          Expanded(
            child: AppButton(
              label: 'Save',
              icon: Icons.bookmark_add_outlined,
              variant: ButtonVariant.outline,
              onPressed: () => context.go('/login?redirect=/manga/$mangaId'),
              size: ButtonSize.lg,
            ),
          ),
      ],
    );
  }
}

class _Description extends StatelessWidget {
  final String text;
  final bool expanded;
  final VoidCallback onToggle;

  const _Description({
    required this.text,
    required this.expanded,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.outline.withOpacity(0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Synopsis',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.onSurface.withOpacity(0.5),
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 8),
          AnimatedCrossFade(
            duration: const Duration(milliseconds: 200),
            crossFadeState:
                expanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
            firstChild: Text(
              text,
              maxLines: 4,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 14,
                color: theme.colorScheme.onSurface.withOpacity(0.7),
                height: 1.6,
              ),
            ),
            secondChild: Text(
              text,
              style: TextStyle(
                fontSize: 14,
                color: theme.colorScheme.onSurface.withOpacity(0.7),
                height: 1.6,
              ),
            ),
          ),
          if (text.length > 200)
            GestureDetector(
              onTap: onToggle,
              child: Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  expanded ? 'Show less' : 'Read more',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: theme.colorScheme.primary,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _Tags extends StatelessWidget {
  final List<String> tags;
  const _Tags({required this.tags});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.outline.withOpacity(0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Genres & Tags',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.onSurface.withOpacity(0.5),
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: tags
                .map((tag) => GestureDetector(
                      onTap: () =>
                          context.go('/search?q=${Uri.encodeComponent(tag)}'),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surfaceContainerHighest
                              .withOpacity(0.6),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color:
                                theme.colorScheme.outline.withOpacity(0.15),
                          ),
                        ),
                        child: Text(
                          tag,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color:
                                theme.colorScheme.onSurface.withOpacity(0.6),
                          ),
                        ),
                      ),
                    ))
                .toList(),
          ),
        ],
      ),
    );
  }
}