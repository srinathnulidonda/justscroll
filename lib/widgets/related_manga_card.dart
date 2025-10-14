import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/manga.dart';

class RelatedMangaCard extends StatelessWidget {
  final Manga manga;

  const RelatedMangaCard({super.key, required this.manga});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 120,
      margin: const EdgeInsets.only(right: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 150,
            width: 120,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  CachedNetworkImage(
                    imageUrl: manga.coverImage,
                    fit: BoxFit.cover,
                    placeholder: (_, __) => Container(color: Colors.grey[800]),
                    errorWidget: (_, __, ___) => const Icon(Icons.error),
                  ),
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black.withOpacity(0.8),
                          ],
                        ),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.star, color: Colors.amber, size: 12),
                          const SizedBox(width: 4),
                          Text(
                            manga.rating.toStringAsFixed(1),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            manga.title,
            style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            manga.author,
            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
