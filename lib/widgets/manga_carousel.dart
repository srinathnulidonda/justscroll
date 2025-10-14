import 'package:flutter/material.dart';
import '../utils/routes.dart';

class MangaCarousel extends StatelessWidget {
  final List<Map<String, dynamic>> mangaList;

  const MangaCarousel({super.key, required this.mangaList});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      scrollDirection: Axis.horizontal,
      itemCount: mangaList.length,
      itemBuilder: (context, index) {
        final manga = mangaList[index];
        return GestureDetector(
          onTap: () {
            Navigator.pushNamed(
              context,
              Routes.mangaDetail,
              arguments: {'mangaData': manga},
            );
          },
          child: Container(
            width: 150,
            margin: const EdgeInsets.only(right: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Hero(
                  tag: 'manga-cover-${manga['id']}',
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      manga['coverUrl'] ?? '',
                      height: 150,
                      width: 150,
                      fit: BoxFit.cover,
                      errorBuilder:
                          (context, error, stackTrace) =>
                              const Icon(Icons.broken_image, size: 150),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  manga['title'] ?? 'Unknown Title',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
