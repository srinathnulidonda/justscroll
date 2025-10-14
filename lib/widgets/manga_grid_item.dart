//lib/widgets/manga_grid_item.dart

import 'package:flutter/material.dart';
import 'package:manga_app/models/manga.dart';
import 'package:cached_network_image/cached_network_image.dart';

class MangaGridItem extends StatefulWidget {
  final Manga manga;
  final VoidCallback onTap;

  const MangaGridItem({super.key, required this.manga, required this.onTap});

  @override
  _MangaGridItemState createState() => _MangaGridItemState();
}

class _MangaGridItemState extends State<MangaGridItem> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: MouseRegion(
        onEnter: (_) => setState(() => _isHovered = true),
        onExit: (_) => setState(() => _isHovered = false),
        child: AnimatedScale(
          scale: _isHovered ? 1.05 : 1.0,
          duration: const Duration(milliseconds: 200),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        CachedNetworkImage(
                          imageUrl: widget.manga.coverUrl,
                          fit: BoxFit.cover,
                          placeholder:
                              (context, url) => Center(
                                child: CircularProgressIndicator(
                                  color: Colors.blueAccent,
                                ),
                              ),
                          errorWidget:
                              (context, url, error) => Container(
                                color: Colors.grey[300],
                                child: const Icon(
                                  Icons.error,
                                  color: Colors.red,
                                  size: 40,
                                ),
                              ),
                        ),
                        Positioned(
                          bottom: 0,
                          left: 0,
                          right: 0,
                          child: Container(
                            height: 40,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [Colors.transparent, Colors.black54],
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                          top: 8,
                          right: 8,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors:
                                    widget.manga.isCompleted
                                        ? [Colors.green, Colors.greenAccent]
                                        : [Colors.blue, Colors.blueAccent],
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              widget.manga.isCompleted
                                  ? 'Completed'
                                  : 'Ongoing',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(8),
                    color: Theme.of(context).cardColor,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.manga.title,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            shadows: [
                              Shadow(color: Colors.black26, blurRadius: 2),
                            ],
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          widget.manga.author,
                          style: TextStyle(
                            fontSize: 12,
                            color: Theme.of(context).textTheme.bodySmall?.color,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
