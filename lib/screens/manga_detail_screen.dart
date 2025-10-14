//lib/screens/manga_detail_screen.dart

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:manga_app/models/manga.dart';
import 'package:manga_app/models/chapter.dart';
import 'package:manga_app/services/firebase_service.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:manga_app/screens/reader_screen.dart';
import 'package:intl/intl.dart';

class MangaDetailScreen extends StatefulWidget {
  final Manga manga;

  const MangaDetailScreen({super.key, required this.manga});

  @override
  State<MangaDetailScreen> createState() => _MangaDetailScreenState();
}

class _MangaDetailScreenState extends State<MangaDetailScreen> {
  final FirebaseService _firebaseService = FirebaseService();
  late Future<List<Chapter>> _chaptersFuture;
  bool _isFavorite = false;

  @override
  void initState() {
    super.initState();
    _chaptersFuture = _firebaseService.getChaptersByMangaId(widget.manga.id);
    _checkIfFavorited();
  }

  Future<void> _checkIfFavorited() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final userProfile = await _firebaseService.getUserProfile(user.uid);
    if (userProfile == null) return;

    setState(
      () => _isFavorite = userProfile.favorites.contains(widget.manga.id),
    );
  }

  Future<void> _toggleFavorite() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    await _firebaseService.toggleFavorite(user.uid, widget.manga.id);
    setState(() => _isFavorite = !_isFavorite);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _isFavorite ? 'Added to favorites' : 'Removed from favorites',
          ),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            actions: [
              AnimatedScale(
                scale: _isFavorite ? 1.2 : 1.0,
                duration: const Duration(milliseconds: 200),
                child: IconButton(
                  icon: Icon(
                    _isFavorite ? Icons.favorite : Icons.favorite_border,
                    color: _isFavorite ? Colors.red : null,
                  ),
                  onPressed: _toggleFavorite,
                ),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  CachedNetworkImage(
                    imageUrl: widget.manga.coverUrl,
                    fit: BoxFit.cover,
                    placeholder:
                        (context, url) => Container(color: Colors.grey[300]),
                    errorWidget:
                        (context, url, error) => Container(
                          color: Colors.grey[300],
                          child: const Icon(Icons.error),
                        ),
                  ),
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      height: 80,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [Colors.transparent, Colors.black54],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.manga.title,
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Author: ${widget.manga.author}',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Status: ${widget.manga.isCompleted ? 'Completed' : 'Ongoing'}',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children:
                        widget.manga.genres
                            .map(
                              (genre) => Chip(
                                label: Text(genre),
                                backgroundColor: Colors.blueAccent.withOpacity(
                                  0.2,
                                ),
                              ),
                            )
                            .toList(),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Description',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.manga.description,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Chapters',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
          FutureBuilder<List<Chapter>>(
            future: _chaptersFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const SliverFillRemaining(
                  child: Center(child: CircularProgressIndicator()),
                );
              }
              if (snapshot.hasError) {
                return SliverFillRemaining(
                  child: Center(child: Text('Error: ${snapshot.error}')),
                );
              }
              final chapters = snapshot.data ?? [];
              if (chapters.isEmpty) {
                return const SliverFillRemaining(
                  child: Center(child: Text('No chapters available')),
                );
              }
              return SliverList(
                delegate: SliverChildBuilderDelegate((context, index) {
                  final chapter = chapters[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 4,
                    ),
                    child: ListTile(
                      title: Text(
                        'Chapter ${chapter.number}: ${chapter.title}',
                      ),
                      subtitle: Text(
                        'Released: ${DateFormat.yMMMd().format(chapter.releaseDate)}',
                      ),
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => ReaderScreen(chapter: chapter),
                          ),
                        );
                      },
                    ),
                  );
                }, childCount: chapters.length),
              );
            },
          ),
        ],
      ),
    );
  }
}
