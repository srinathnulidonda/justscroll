// lib/pages/manga/reader_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:justscroll/lib/api.dart';
import 'package:justscroll/models/manga.dart';
import 'package:justscroll/models/chapter.dart';
import 'package:justscroll/stores/reader_store.dart';
import 'package:justscroll/components/manga/reader_view.dart';
import 'package:justscroll/components/common/empty_state.dart';

final _pagesProvider = FutureProvider.family<List<String>, ({String chapterId, String quality})>((ref, params) async {
  final data = await ApiClient.instance.getChapterPages(params.chapterId, quality: params.quality);
  return (data['pages'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [];
});

final _readerChaptersProvider = FutureProvider.family<List<Chapter>, String>((ref, mangaId) async {
  if (mangaId.isEmpty) return [];
  final data = await ApiClient.instance.getMangaChapters(mangaId);
  return ChapterListResponse.fromJson(data).data;
});

final _readerMangaProvider = FutureProvider.family<Manga?, String>((ref, mangaId) async {
  if (mangaId.isEmpty) return null;
  final data = await ApiClient.instance.getMangaDetail(mangaId);
  return Manga.fromJson(data);
});

class ReaderPage extends ConsumerWidget {
  final String chapterId;
  final String mangaId;

  const ReaderPage({super.key, required this.chapterId, required this.mangaId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final quality = ref.watch(readerStoreProvider).quality;
    final pagesAsync = ref.watch(_pagesProvider((chapterId: chapterId, quality: quality)));
    final chaptersAsync = ref.watch(_readerChaptersProvider(mangaId));
    final mangaAsync = ref.watch(_readerMangaProvider(mangaId));

    return pagesAsync.when(
      loading: () => const Scaffold(
        backgroundColor: Colors.black,
        body: Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
          CircularProgressIndicator(strokeWidth: 2, color: Colors.white30),
          SizedBox(height: 12),
          Text('Loading chapter…', style: TextStyle(fontSize: 13, color: Colors.white30)),
        ])),
      ),
      error: (e, _) => Scaffold(
        backgroundColor: Colors.black,
        body: EmptyState(
          icon: Icons.error_outline,
          title: 'Unable to load chapter',
          description: 'This chapter may not be available.',
          action: () => context.go(mangaId.isNotEmpty ? '/manga/$mangaId' : '/'),
          actionLabel: 'Go Back',
        ),
      ),
      data: (pages) {
        if (pages.isEmpty) {
          return Scaffold(
            backgroundColor: Colors.black,
            body: EmptyState(
              icon: Icons.error_outline,
              title: 'No pages found',
              action: () => context.go(mangaId.isNotEmpty ? '/manga/$mangaId' : '/'),
              actionLabel: 'Go Back',
            ),
          );
        }

        final chapters = chaptersAsync.valueOrNull ?? [];
        final manga = mangaAsync.valueOrNull;
        final currentChapter = chapters.cast<Chapter?>().firstWhere((c) => c!.id == chapterId, orElse: () => null);

        return ReaderView(
          pages: pages,
          chapterId: chapterId,
          chapters: chapters,
          mangaTitle: manga?.title ?? '',
          chapterTitle: currentChapter?.title ?? '',
          chapterNumber: currentChapter?.chapter ?? '',
          mangaId: mangaId,
        );
      },
    );
  }
}