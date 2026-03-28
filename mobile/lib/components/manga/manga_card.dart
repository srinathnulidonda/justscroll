// lib/components/manga/manga_card.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:justscroll/lib/constants.dart';
import 'package:justscroll/components/common/optimized_image.dart';

class MangaCard extends StatelessWidget {
  final String id;
  final String title;
  final String? coverUrl;
  final String? author;
  final String? status;
  final double? score;
  final int? year;
  final List<String> tags;

  const MangaCard({
    super.key,
    required this.id,
    required this.title,
    this.coverUrl,
    this.author,
    this.status,
    this.score,
    this.year,
    this.tags = const [],
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final statusInfo = status != null ? kStatusMap[status] : null;
    final genres = tags.take(2).toList();
    final scoreStr =
        score != null ? score!.toStringAsFixed(1) : null;

    return RepaintBoundary(
      child: GestureDetector(
        onTap: () => context.go('/manga/$id'),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Cover image
            AspectRatio(
              aspectRatio: 2 / 3,
              child: Stack(
                children: [
                  Positioned.fill(
                    child: OptimizedImage(
                      src: coverUrl,
                      fit: BoxFit.cover,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  if (statusInfo != null)
                    Positioned(
                      top: 6,
                      left: 6,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xB3000000),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          statusInfo.label,
                          style: const TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ),
                  if (scoreStr != null)
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          borderRadius: const BorderRadius.vertical(
                              bottom: Radius.circular(10)),
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              const Color(0xCC000000),
                            ],
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(
                              8, 20, 8, 6),
                          child: Row(
                            mainAxisAlignment:
                                MainAxisAlignment.end,
                            children: [
                              Container(
                                padding:
                                    const EdgeInsets.symmetric(
                                        horizontal: 5,
                                        vertical: 2),
                                decoration: BoxDecoration(
                                  color: const Color(0x99000000),
                                  borderRadius:
                                      BorderRadius.circular(4),
                                ),
                                child: Row(
                                  mainAxisSize:
                                      MainAxisSize.min,
                                  children: [
                                    const Icon(Icons.star,
                                        size: 11,
                                        color:
                                            Color(0xFFF59E0B)),
                                    const SizedBox(width: 2),
                                    Text(
                                      scoreStr,
                                      style: const TextStyle(
                                        fontSize: 10,
                                        fontWeight:
                                            FontWeight.w600,
                                        color:
                                            Color(0xFFF59E0B),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 8),

            // Title
            Text(
              title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: theme.colorScheme.onSurface,
                height: 1.3,
              ),
            ),

            // Meta
            if (year != null || author != null) ...[
              const SizedBox(height: 2),
              Text(
                [
                  if (year != null) year.toString(),
                  if (author != null) author!,
                ].join(' • '),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 11,
                  color: theme.colorScheme.onSurface
                      .withOpacity(0.45),
                ),
              ),
            ],

            // Tags
            if (genres.isNotEmpty) ...[
              const SizedBox(height: 4),
              Wrap(
                spacing: 4,
                runSpacing: 2,
                children: genres
                    .map((tag) => Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 5, vertical: 2),
                          decoration: BoxDecoration(
                            color: theme.colorScheme
                                .surfaceContainerHighest
                                .withOpacity(0.6),
                            borderRadius:
                                BorderRadius.circular(4),
                          ),
                          child: Text(
                            tag,
                            style: TextStyle(
                              fontSize: 9,
                              color: theme.colorScheme.onSurface
                                  .withOpacity(0.5),
                            ),
                          ),
                        ))
                    .toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }
}