import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/manga_provider.dart';
import '../services/firebase_service.dart';
import '../models/manga.dart';

class ProfileTab extends StatelessWidget {
  const ProfileTab({super.key});

  @override
  Widget build(BuildContext context) {
    final mangaProvider = Provider.of<MangaProvider>(context);
    final firebaseService = FirebaseService();

    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Favorites',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            FutureBuilder<List<Manga>>(
              future: firebaseService.getMangaByIds(
                mangaProvider.favorites.toList(),
              ),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                final favorites = snapshot.data!;
                return SizedBox(
                  height: 200,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: favorites.length,
                    itemBuilder:
                        (context, index) => Padding(
                          padding: const EdgeInsets.only(right: 16),
                          child: Image.network(
                            favorites[index].coverImage,
                            width: 120,
                            fit: BoxFit.cover,
                          ),
                        ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
