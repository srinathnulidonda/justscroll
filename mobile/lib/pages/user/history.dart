// lib/pages/user/history.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:justscroll/lib/api.dart';
import 'package:justscroll/lib/utils.dart' as utils;
import 'package:justscroll/models/user.dart';
import 'package:justscroll/components/common/empty_state.dart';
import 'package:justscroll/components/ui/skeleton.dart';

final _historyProvider = FutureProvider<HistoryListResponse>((ref) async {
  final data = await ApiClient.instance.getHistory();
  return HistoryListResponse.fromJson(data);
});

class HistoryPage extends ConsumerWidget {
  const HistoryPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final historyAsync = ref.watch(_historyProvider);

    return RefreshIndicator(
      onRefresh: () async => ref.invalidate(_historyProvider),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Reading History', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700, color: theme.colorScheme.onSurface)),
            const SizedBox(height: 4),
            historyAsync.when(
              loading: () => Column(children: List.generate(8, (_) => Padding(padding: const EdgeInsets.only(top: 8), child: Skeleton(height: 64, borderRadius: BorderRadius.circular(12))))),
              error: (e, _) => EmptyState(icon: Icons.error_outline, title: 'Failed to load history', action: () => ref.invalidate(_historyProvider), actionLabel: 'Retry'),
              data: (response) {
                final history = response.data;
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('${history.length} ${history.length == 1 ? 'entry' : 'entries'}', style: TextStyle(fontSize: 14, color: theme.colorScheme.onSurface.withOpacity(0.5))),
                    const SizedBox(height: 12),
                    if (history.isEmpty)
                      EmptyState(icon: Icons.history, title: 'No reading history', description: 'Start reading manga and your progress will appear here', action: () => context.go('/discover'), actionLabel: 'Browse Manga')
                    else
                      ...history.map((entry) => Padding(
                        padding: const EdgeInsets.only(bottom: 6),
                        child: Material(
                          color: theme.colorScheme.surface,
                          borderRadius: BorderRadius.circular(12),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(12),
                            onTap: () => context.go('/read/${entry.chapterId}?manga=${entry.mangaId}'),
                            child: Container(
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: theme.colorScheme.outline.withOpacity(0.2)),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: 40, height: 40,
                                    decoration: BoxDecoration(
                                      color: theme.colorScheme.primary.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Icon(Icons.menu_book, size: 20, color: theme.colorScheme.primary),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(entry.mangaTitle, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: theme.colorScheme.onSurface)),
                                        const SizedBox(height: 2),
                                        Row(
                                          children: [
                                            if (entry.chapterNumber != null) Text('Ch. ${entry.chapterNumber}', style: TextStyle(fontSize: 12, color: theme.colorScheme.onSurface.withOpacity(0.5))),
                                            if (entry.chapterNumber != null) Text(' · ', style: TextStyle(fontSize: 12, color: theme.colorScheme.onSurface.withOpacity(0.3))),
                                            Text('Page ${entry.pageNumber}', style: TextStyle(fontSize: 12, color: theme.colorScheme.onSurface.withOpacity(0.5))),
                                            Text(' · ', style: TextStyle(fontSize: 12, color: theme.colorScheme.onSurface.withOpacity(0.3))),
                                            Text(utils.formatDate(entry.updatedAt), style: TextStyle(fontSize: 12, color: theme.colorScheme.onSurface.withOpacity(0.5))),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  Icon(Icons.arrow_forward_ios, size: 14, color: theme.colorScheme.onSurface.withOpacity(0.3)),
                                ],
                              ),
                            ),
                          ),
                        ),
                      )),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}