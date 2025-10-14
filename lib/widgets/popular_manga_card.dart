import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/manga.dart';
import '../theme/app_theme.dart';

class PopularMangaCard extends StatelessWidget {
  final Manga manga;
  final int rank;

  const PopularMangaCard({super.key, required this.manga, required this.rank});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(
        backgroundImage: CachedNetworkImageProvider(manga.coverImage),
      ),
      title: Text(
        manga.title,
        style: const TextStyle(color: Colors.white),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text(
        manga.author,
        style: const TextStyle(color: Colors.white70),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.star, color: AppTheme.kAccentColor, size: 16),
          const SizedBox(width: 4),
          Text(
            manga.rating.toStringAsFixed(1),
            style: const TextStyle(color: Colors.white),
          ),
        ],
      ),
      contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
    );
  }
}
