import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // Added import
import 'manga_provider.dart';

class ReadingScreen extends StatefulWidget {
  final Manga manga;

  const ReadingScreen({super.key, required this.manga});

  @override
  State<ReadingScreen> createState() => _ReadingScreenState();
}

class _ReadingScreenState extends State<ReadingScreen> {
  int currentChapter = 0;

  @override
  void initState() {
    super.initState();
    currentChapter = Provider.of<MangaProvider>(
      context,
      listen: false,
    ).getProgress(widget.manga.id);
  }

  void _updateProgress(int chapter) {
    Provider.of<MangaProvider>(
      context,
      listen: false,
    ).updateProgress(widget.manga.id, chapter);
    if (mounted) setState(() => currentChapter = chapter);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.manga.title),
        backgroundColor: kSurfaceColor,
      ),
      body: Column(
        children: [
          Expanded(
            child: Center(
              child: Text(
                'Reading Chapter $currentChapter of ${widget.manga.title}',
                style: const TextStyle(color: Colors.white, fontSize: 18),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton(
                  onPressed:
                      currentChapter > 0
                          ? () => _updateProgress(currentChapter - 1)
                          : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kPrimaryColor,
                  ),
                  child: const Text('Previous'),
                ),
                ElevatedButton(
                  onPressed:
                      currentChapter < widget.manga.totalChapters - 1
                          ? () => _updateProgress(currentChapter + 1)
                          : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kPrimaryColor,
                  ),
                  child: const Text('Next'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
