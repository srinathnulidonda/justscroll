import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/manga_provider.dart';
import '../services/firebase_service.dart';
import '../widgets/manga_card.dart';
import '../models/manga.dart';

class LibraryTab extends StatelessWidget {
  const LibraryTab({super.key});

  @override
  Widget build(BuildContext context) {
    final mangaProvider = Provider.of<MangaProvider>(context);
    final firebaseService = FirebaseService();

    return Scaffold(
      appBar: AppBar(title: const Text('Library')),
      body: FutureBuilder<List<Manga>>(
        future: firebaseService.getMangaByIds(
          mangaProvider.readingList.toList(),
        ),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Your library is empty'));
          }

          final mangaList = snapshot.data!;
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: mangaList.length,
            itemBuilder: (context, index) {
              final manga = mangaList[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: MangaCard(manga: manga),
              );
            },
          );
        },
      ),
    );
  }
}
