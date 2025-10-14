import 'package:flutter/material.dart';
import '../utils/routes.dart';

class MangaGrid extends StatelessWidget {
  final List<Map<String, dynamic>> mangaList;
  final bool smallGrid;

  const MangaGrid({super.key, required this.mangaList, this.smallGrid = false});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: smallGrid ? const NeverScrollableScrollPhysics() : null,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: smallGrid ? 3 : 2,
        childAspectRatio: 0.7,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Hero(
                tag: 'manga-cover-${manga['id']}',
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    manga['coverUrl'] ?? '',
                    height: smallGrid ? 100 : 150,
                    width: double.infinity,
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
        );
      },
    );
  }
}
