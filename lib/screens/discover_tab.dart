import 'package:flutter/material.dart';
import '../services/firebase_service.dart';
import '../widgets/manga_card.dart';
import '../models/manga.dart';

class DiscoverTab extends StatefulWidget {
  const DiscoverTab({super.key});

  @override
  State<DiscoverTab> createState() => _DiscoverTabState();
}

class _DiscoverTabState extends State<DiscoverTab> {
  final FirebaseService _firebaseService = FirebaseService();
  late Future<List<Manga>> _mangaFuture;

  @override
  void initState() {
    super.initState();
    _mangaFuture = _firebaseService.fetchMangaCollection(
      'rating',
      descending: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Discover')),
      body: FutureBuilder<List<Manga>>(
        future: _mangaFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError || !snapshot.hasData) {
            return const Center(child: Text('Error loading manga'));
          }

          final mangaList = snapshot.data!;
          return GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.7,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
            ),
            itemCount: mangaList.length,
            itemBuilder: (context, index) => MangaCard(manga: mangaList[index]),
          );
        },
      ),
    );
  }
}
