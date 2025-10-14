import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart'; // Added import
import 'package:provider/provider.dart';
import 'manga_provider.dart';
import 'reading_screen.dart';

class MangaDetailScreen extends StatelessWidget {
  final Manga manga;

  const MangaDetailScreen({super.key, required this.manga});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: CachedNetworkImage(
                // Fixed: Already imported at the top
                imageUrl: manga.coverImage,
                fit: BoxFit.cover,
                placeholder:
                    (context, url) => Container(color: Colors.grey[800]),
                errorWidget:
                    (context, url, error) => Container(
                      color: kPrimaryColor.withOpacity(0.3),
                      child: const Icon(Icons.error, color: Colors.white),
                    ),
              ),
            ),
            actions: [
              Consumer<MangaProvider>(
                builder: (context, provider, child) {
                  final isFavorite = provider.isFavorite(manga.id);
                  return IconButton(
                    icon: Icon(
                      isFavorite ? Icons.bookmark : Icons.bookmark_border,
                      color: isFavorite ? kAccentColor : Colors.white,
                    ),
                    onPressed: () => provider.toggleFavorite(manga.id),
                  );
                },
              ),
            ],
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    manga.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'By ${manga.author}',
                    style: const TextStyle(color: Colors.white70, fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.star, color: kAccentColor, size: 20),
                      const SizedBox(width: 4),
                      Text(
                        manga.rating.toString(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(width: 16),
                      const Icon(
                        Icons.menu_book,
                        color: Colors.white70,
                        size: 20,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${manga.totalChapters} chapters',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children:
                        manga.genres.map((genre) {
                          return Chip(
                            label: Text(genre),
                            backgroundColor: kPrimaryColor.withOpacity(0.3),
                            labelStyle: const TextStyle(color: Colors.white),
                          );
                        }).toList(),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    manga.description,
                    style: const TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ReadingScreen(manga: manga),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: kPrimaryColor,
                      minimumSize: const Size(double.infinity, 48),
                    ),
                    child: const Text('Start Reading'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
