// lib/pages/user/bookmarks.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:justscroll/lib/api.dart';
import 'package:justscroll/lib/utils.dart' as utils;
import 'package:justscroll/models/user.dart';
import 'package:justscroll/stores/auth_store.dart';
import 'package:justscroll/stores/toast_store.dart';
import 'package:justscroll/components/common/optimized_image.dart';
import 'package:justscroll/components/common/empty_state.dart';
import 'package:justscroll/components/ui/skeleton.dart';

final _bookmarksProvider = FutureProvider<BookmarkListResponse>((ref) async {
  final data = await ApiClient.instance.getBookmarks();
  return BookmarkListResponse.fromJson(data);
});

class BookmarksPage extends ConsumerWidget {
  const BookmarksPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final bookmarksAsync = ref.watch(_bookmarksProvider);

    return RefreshIndicator(
      onRefresh: () async => ref.invalidate(_bookmarksProvider),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('My Bookmarks', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700, color: theme.colorScheme.onSurface)),
            const SizedBox(height: 4),
            bookmarksAsync.when(
              loading: () => Column(children: [const SizedBox(height: 12), const MangaGridSkeleton(count: 8)]),
              error: (e, _) => EmptyState(icon: Icons.error_outline, title: 'Failed to load bookmarks', action: () => ref.invalidate(_bookmarksProvider), actionLabel: 'Retry'),
              data: (response) {
                final bookmarks = response.data;
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('${bookmarks.length} saved ${bookmarks.length == 1 ? 'title' : 'titles'}', style: TextStyle(fontSize: 14, color: theme.colorScheme.onSurface.withOpacity(0.5))),
                    const SizedBox(height: 16),
                    if (bookmarks.isEmpty)
                      EmptyState(icon: Icons.bookmark_outline, title: 'No bookmarks yet', description: 'Browse manga and bookmark titles you want to read later', action: () => context.go('/discover'), actionLabel: 'Browse Manga')
                    else
                      _buildGrid(context, ref, bookmarks),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGrid(BuildContext context, WidgetRef ref, List<BookmarkEntry> bookmarks) {
    final w = MediaQuery.of(context).size.width;
    final cols = w < 400 ? 2 : w < 640 ? 3 : w < 768 ? 4 : w < 1024 ? 5 : 6;

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: cols,
        childAspectRatio: 0.52,
        crossAxisSpacing: 12,
        mainAxisSpacing: 16,
      ),
      itemCount: bookmarks.length,
      itemBuilder: (_, i) {
        final bk = bookmarks[i];
        return GestureDetector(
          onTap: () => context.go('/manga/${bk.mangaId}'),
          child: Stack(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: OptimizedImage(src: bk.coverUrl, fit: BoxFit.cover, borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(bk.mangaTitle, maxLines: 2, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: Theme.of(context).colorScheme.onSurface)),
                  if (bk.createdAt != null)
                    Text(utils.formatDate(bk.createdAt), style: TextStyle(fontSize: 11, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.4))),
                ],
              ),
              Positioned(
                top: 6,
                right: 6,
                child: Material(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(12),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () async {
                      try {
                        await ApiClient.instance.removeBookmark(bk.mangaId);
                        ref.invalidate(_bookmarksProvider);
                        ref.read(toastProvider.notifier).success('Bookmark removed');
                      } catch (_) {
                        ref.read(toastProvider.notifier).error('Failed to remove');
                      }
                    },
                    child: const Padding(padding: EdgeInsets.all(6), child: Icon(Icons.delete_outline, size: 16, color: Colors.white)),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}