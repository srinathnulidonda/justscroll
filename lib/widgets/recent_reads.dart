import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/manga_service.dart';
import '../utils/routes.dart';

class RecentReads extends StatelessWidget {
  const RecentReads({super.key});

  @override
  Widget build(BuildContext context) {
    final mangaService = Provider.of<MangaService>(context);

    return FutureBuilder<Map<String, List<Map<String, dynamic>>>>(
      future: mangaService.getUserLists(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final readingList = snapshot.data?['reading'] ?? [];
        if (readingList.isEmpty) {
          return const Center(child: Text('No recent reads'));
        }

        return ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: readingList.length,
          itemBuilder: (context, index) {
            final manga = readingList[index];
            return GestureDetector(
              onTap: () async {
                final progress = await mangaService.getReadingProgress(
                  manga['id'],
                );
                Navigator.pushNamed(
                  context,
                  Routes.reader,
                  arguments: {
                    'mangaId': manga['id'],
                    'chapterId':
                        progress?['chapterId'] ?? manga['chapters'][0]['id'],
                    'chapterTitle':
                        progress != null
                            ? manga['chapters'].firstWhere(
                              (c) => c['id'] == progress['chapterId'],
                            )['title']
                            : manga['chapters'][0]['title'],
                  },
                );
              },
              child: Container(
                width: 150,
                margin: const EdgeInsets.only(right: 16),
                child: Column(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        manga['coverUrl'] ?? '',
                        height: 100,
                        width: 150,
                        fit: BoxFit.cover,
                        errorBuilder:
                            (context, error, stackTrace) =>
                                const Icon(Icons.broken_image, size: 100),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      manga['title'] ?? 'Unknown',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
