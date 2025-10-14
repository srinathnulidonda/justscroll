import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../constants.dart';
import '../models/manga.dart';
import '../providers/manga_provider.dart';
import '../screens/reading_screen.dart';

class ChapterListItem extends StatelessWidget {
  final Chapter chapter;
  final Manga manga;
  final bool isLatest;
  final bool isRead;

  const ChapterListItem({
    super.key,
    required this.chapter,
    required this.manga,
    this.isLatest = false,
    this.isRead = false,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: () {
          Provider.of<MangaProvider>(
            context,
            listen: false,
          ).markChapterAsRead(manga.id, chapter.id);
          Navigator.push(
            context,
            MaterialPageRoute(
              builder:
                  (_) => ReadingScreen(manga: manga, initialChapter: chapter),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: kPrimaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Text(
                    'Ch.${chapter.number}',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: isRead ? Colors.grey : kPrimaryColor,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            chapter.title,
                            style: TextStyle(
                              fontWeight: FontWeight.w500,
                              color: isRead ? Colors.grey : null,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (isLatest)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.red,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Text(
                              'NEW',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Released ${chapter.releaseDate}',
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
              isRead
                  ? const Icon(Icons.check_circle, color: Colors.grey, size: 16)
                  : Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: kAccentColor,
                    ),
                  ),
            ],
          ),
        ),
      ),
    );
  }
}
