import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/manga_service.dart';
import '../utils/routes.dart';

class ChapterList extends StatelessWidget {
  final String mangaId;
  final List<Map<String, dynamic>> chapters;

  const ChapterList({super.key, required this.mangaId, required this.chapters});

  @override
  Widget build(BuildContext context) {
    final mangaService = Provider.of<MangaService>(context);
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: chapters.length,
      itemBuilder: (context, index) {
        final chapter = chapters[index];
        return ListTile(
          title: Text(chapter['title'] ?? 'Chapter ${index + 1}'),
          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
          onTap: () async {
            final progress = await mangaService.getReadingProgress(mangaId);
            Navigator.pushNamed(
              context,
              Routes.reader,
              arguments: {
                'mangaId': mangaId,
                'chapterId': chapter['id'],
                'chapterTitle': chapter['title'],
              },
            );
          },
        );
      },
    );
  }
}
