import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:timeago/timeago.dart' as timeago;
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

  void _openChapter(BuildContext context) {
    // Mark as read and navigate in one function for better organization
    Provider.of<MangaProvider>(
      context,
      listen: false,
    ).markChapterAsRead(manga.id, chapter.id);

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ReadingScreen(manga: manga, initialChapter: chapter),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Format relative date (e.g., "2 days ago" instead of static date)
    final formattedDate =
        chapter.releaseDate != null
            ? timeago.format(DateTime.parse(chapter.releaseDate))
            : 'Unknown date';

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      elevation: isRead ? 0 : 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side:
            isRead
                ? BorderSide(color: Colors.grey.withOpacity(0.3), width: 1)
                : BorderSide.none,
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => _openChapter(context),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          child: Row(
            children: [
              // Chapter number with improved visual style
              Hero(
                tag: 'chapter_${manga.id}_${chapter.id}',
                child: Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color:
                        isRead
                            ? Colors.grey.withOpacity(0.2)
                            : kPrimaryColor.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(10),
                    boxShadow:
                        isRead
                            ? null
                            : [
                              BoxShadow(
                                color: kPrimaryColor.withOpacity(0.2),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      if (isRead)
                        Positioned(
                          right: 0,
                          bottom: 0,
                          child: Container(
                            padding: const EdgeInsets.all(2),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.check_circle,
                              color: Colors.grey,
                              size: 12,
                            ),
                          ),
                        ),
                      Text(
                        'Ch.${chapter.number}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                          color: isRead ? Colors.grey : kPrimaryColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 16),

              // Chapter details with better layout
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
                              fontWeight:
                                  isRead ? FontWeight.normal : FontWeight.w600,
                              color:
                                  isRead
                                      ? Colors.grey
                                      : theme.textTheme.bodyLarge?.color,
                              fontSize: 15,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        if (isLatest)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [Colors.red, Colors.redAccent],
                              ),
                              borderRadius: BorderRadius.circular(6),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.red.withOpacity(0.3),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: const Text(
                              'NEW',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.access_time,
                          size: 12,
                          color: Colors.grey[600],
                        ),
                        const SizedBox(width: 4),
                        Text(
                          formattedDate,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                        if (chapter.pages != null) ...[
                          const SizedBox(width: 12),
                          Icon(
                            Icons.image_outlined,
                            size: 12,
                            color: Colors.grey[600],
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${chapter.pages} pages',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),

              // Right actions/indicators
              if (!isRead) ...[
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: kAccentColor.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: kAccentColor,
                      ),
                    ),
                  ),
                ),
              ] else ...[
                IconButton(
                  icon: Icon(
                    Icons.bookmark_border,
                    color: Colors.grey,
                    size: 20,
                  ),
                  onPressed: () {
                    // Functionality to bookmark for later
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Chapter bookmarked'),
                        duration: Duration(seconds: 1),
                      ),
                    );
                  },
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
