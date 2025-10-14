import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:manga_app/models/manga.dart';
import 'package:manga_app/services/firebase_service.dart';
import 'package:manga_app/widgets/manga_grid_item.dart';
import 'package:manga_app/screens/manga_detail_screen.dart';
import 'package:shimmer/shimmer.dart';

class MangaListScreen extends StatefulWidget {
  const MangaListScreen({super.key});

  @override
  State<MangaListScreen> createState() => _MangaListScreenState();
}

class _MangaListScreenState extends State<MangaListScreen> {
  final FirebaseService _firebaseService = FirebaseService();
  late Future<List<Manga>> _mangaFuture;
  String _selectedGenre = 'All';
  String _searchQuery = '';
  final List<String> _genres = [
    'All',
    'Action',
    'Adventure',
    'Comedy',
    'Drama',
    'Fantasy',
    'Horror',
    'Romance',
    'Sci-Fi',
    'Slice of Life',
  ];

  @override
  void initState() {
    super.initState();
    _updateMangaFuture();
  }

  void _updateMangaFuture() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      setState(
        () => _mangaFuture = Future.error('Please log in to view manga.'),
      );
      return;
    }

    setState(() {
      _mangaFuture =
          _selectedGenre == 'All'
              ? _firebaseService.getAllManga().then(
                (list) => list.take(20).toList(),
              )
              : _firebaseService
                  .getMangaByGenre(_selectedGenre)
                  .then((list) => list.take(20).toList());

      if (_searchQuery.isNotEmpty) {
        _mangaFuture = _mangaFuture.then(
          (mangas) =>
              mangas
                  .where(
                    (manga) =>
                        manga.title.toLowerCase().contains(
                          _searchQuery.toLowerCase(),
                        ) ||
                        manga.author.toLowerCase().contains(
                          _searchQuery.toLowerCase(),
                        ),
                  )
                  .toList(),
        );
      }
    });
  }

  void _filterByGenre(String genre) {
    setState(() {
      _selectedGenre = genre;
      _updateMangaFuture();
    });
  }

  void _searchManga(String query) {
    setState(() {
      _searchQuery = query;
      _updateMangaFuture();
    });
  }

  Future<void> _refreshManga() async => _updateMangaFuture();

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
        itemCount: 10,
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
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search manga...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon:
                    _searchQuery.isNotEmpty
                        ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () => _searchManga(''),
                        )
                        : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                contentPadding: EdgeInsets.zero,
              ),
              onChanged:
                  (value) => Future.delayed(
                    const Duration(milliseconds: 300),
                    () => _searchManga(value),
                  ),
            ),
          ),
          SizedBox(
            height: 50,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _genres.length,
              itemBuilder: (context, index) {
                final genre = _genres[index];
                final isSelected = _selectedGenre == genre;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: AnimatedScale(
                    scale: isSelected ? 1.1 : 1.0,
                    duration: const Duration(milliseconds: 200),
                    child: FilterChip(
                      label: Text(genre),
                      selected: isSelected,
                      onSelected: (_) => _filterByGenre(genre),
                      selectedColor: Colors.blueAccent.withOpacity(0.3),
                      checkmarkColor: Colors.blueAccent,
                    ),
                  ),
                );
              },
            ),
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: _refreshManga,
              child: FutureBuilder<List<Manga>>(
                future: _mangaFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return _buildLoadingShimmer();
                  }

                  if (snapshot.hasError) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Error: ${snapshot.error.toString()}',
                            textAlign: TextAlign.center,
                            style: const TextStyle(color: Colors.red),
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: _refreshManga,
                            child: const Text('Retry'),
                          ),
                        ],
                      ),
                    );
                  }

                  final mangas = snapshot.data ?? [];
                  if (mangas.isEmpty)
                    return const Center(child: Text('No manga found'));

                  return GridView.builder(
                    padding: const EdgeInsets.all(16),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 0.65,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                        ),
                    itemCount: mangas.length,
                    itemBuilder: (context, index) {
                      final manga = mangas[index];
                      return MangaGridItem(
                        manga: manga,
                        onTap:
                            () => Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => MangaDetailScreen(manga: manga),
                              ),
                            ),
                      );
                    },
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
