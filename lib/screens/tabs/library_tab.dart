import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import '../../constants.dart';
import '../../models/manga.dart';
import '../../providers/manga_provider.dart';
import '../../screens/reading_screen.dart';
import 'package:cached_network_image/cached_network_image.dart';

class LibraryTab extends StatelessWidget {
  const LibraryTab({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<MangaProvider>(context);
    final readingList = provider.readingList;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            title: const Text('Library'),
            flexibleSpace: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [kPrimaryColor.withOpacity(0.8), Colors.transparent],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
            floating: true,
          ),
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver:
                readingList.isEmpty
                    ? SliverToBoxAdapter(
                      child: Center(
                        child: Text(
                          'Add manga to your library!',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ),
                    )
                    : SliverList(
                      delegate: SliverChildBuilderDelegate((context, index) {
                        return StreamBuilder<QuerySnapshot>(
                          stream:
                              FirebaseFirestore.instance
                                  .collection('manga')
                                  .where(
                                    FieldPath.documentId,
                                    whereIn: readingList.toList(),
                                  )
                                  .snapshots(),
                          builder: (context, snapshot) {
                            if (!snapshot.hasData) {
                              return const Center(
                                child: CircularProgressIndicator(),
                              );
                            }
                            final mangaList =
                                snapshot.data!.docs
                                    .map(Manga.fromFirestore)
                                    .toList();
                            final manga = mangaList[index];
                            return Dismissible(
                              key: Key(manga.id),
                              direction: DismissDirection.endToStart,
                              onDismissed:
                                  (_) => provider.toggleReading(manga.id),
                              background: Container(
                                color: Colors.redAccent,
                                alignment: Alignment.centerRight,
                                padding: const EdgeInsets.only(right: 16),
                                child: const Icon(
                                  Icons.delete,
                                  color: Colors.white,
                                ),
                              ),
                              child: ListTile(
                                leading: ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: CachedNetworkImage(
                                    imageUrl: manga.coverImage,
                                    width: 50,
                                    height: 70,
                                    fit: BoxFit.cover,
                                    placeholder:
                                        (_, __) =>
                                            Container(color: Colors.grey[800]),
                                    errorWidget:
                                        (_, __, ___) => const Icon(Icons.error),
                                  ),
                                ),
                                title: Text(manga.title),
                                subtitle: Text(
                                  'Chapter ${provider.getProgress(manga.id)} / ${manga.totalChapters}',
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                                onTap:
                                    () => Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder:
                                            (_) => ReadingScreen(manga: manga),
                                      ),
                                    ),
                              ),
                            );
                          },
                        );
                      }, childCount: readingList.length),
                    ),
          ),
        ],
      ),
    );
  }
}
