//lib/screens/favorites_screen.dart

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:manga_app/models/manga.dart';
import 'package:manga_app/services/firebase_service.dart';
import 'package:manga_app/widgets/manga_grid_item.dart';
import 'package:manga_app/screens/manga_detail_screen.dart';
import 'package:shimmer/shimmer.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  final FirebaseService _firebaseService = FirebaseService();

  Future<List<Manga>> _getFavorites() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return [];

    final userProfile = await _firebaseService.getUserProfile(user.uid);
    if (userProfile == null) return [];

    final List<Manga> favorites = [];
    for (final mangaId in userProfile.favorites) {
      final manga = await _firebaseService.getMangaById(mangaId);
      if (manga != null) favorites.add(manga);
    }
    return favorites;
  }

  Future<void> _removeFavorite(String mangaId) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await _firebaseService.toggleFavorite(user.uid, mangaId);
      setState(() {});
    }
  }

  Widget _buildLoadingShimmer() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.65,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
        ),
        itemCount: 6,
        itemBuilder:
            (context, index) => Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
            ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<List<Manga>>(
        future: _getFavorites(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return _buildLoadingShimmer();
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final favorites = snapshot.data ?? [];

          if (favorites.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.favorite_border,
                    size: 80,
                    color: Colors.grey,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No favorites yet',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Add manga to your favorites',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed:
                        () => Navigator.pushNamed(context, '/manga_list'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueAccent,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Browse Manga'),
                  ),
                ],
              ),
            );
          }

          return GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.65,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
            ),
            itemCount: favorites.length,
            itemBuilder: (context, index) {
              final manga = favorites[index];
              return Stack(
                children: [
                  MangaGridItem(
                    manga: manga,
                    onTap: () {
                      Navigator.of(context)
                          .push(
                            MaterialPageRoute(
                              builder: (_) => MangaDetailScreen(manga: manga),
                            ),
                          )
                          .then((_) => setState(() {}));
                    },
                  ),
                  Positioned(
                    top: 8,
                    left: 8,
                    child: IconButton(
                      icon: const Icon(Icons.remove_circle, color: Colors.red),
                      onPressed: () => _removeFavorite(manga.id),
                    ),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}
