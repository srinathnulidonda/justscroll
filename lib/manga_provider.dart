import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// Color constants
const kPrimaryColor = Color(0xFF6200EA);
const kAccentColor = Color(0xFFFFAB00);
const kBackgroundColor = Color(0xFF121212);
const kSurfaceColor = Color(0xFF1E1E1E);
const kCardColor = Color(0xFF2A2A2A);
const kErrorColor = Color(0xFFCF6679);

// State management class
class MangaProvider extends ChangeNotifier {
  final Set<String> _favorites = {};
  final Set<String> _readingList = {};
  Map<String, int> _readingProgress = {};
  Map<String, DateTime> _lastRead = {};

  bool isFavorite(String mangaId) => _favorites.contains(mangaId);
  bool isReading(String mangaId) => _readingList.contains(mangaId);
  int getProgress(String mangaId) => _readingProgress[mangaId] ?? 0;
  DateTime? getLastRead(String mangaId) => _lastRead[mangaId];

  void toggleFavorite(String mangaId) {
    _favorites.contains(mangaId)
        ? _favorites.remove(mangaId)
        : _favorites.add(mangaId);
    notifyListeners();
  }

  void toggleReading(String mangaId) {
    _readingList.contains(mangaId)
        ? _readingList.remove(mangaId)
        : _readingList.add(mangaId);

    if (_readingList.contains(mangaId)) {
      _lastRead[mangaId] = DateTime.now();
    }
    notifyListeners();
  }

  void updateProgress(String mangaId, int chapter) {
    _readingProgress[mangaId] = chapter;
    _lastRead[mangaId] = DateTime.now();
    notifyListeners();
  }

  List<String> getRecentlyRead({int limit = 5}) {
    final sortedEntries =
        _lastRead.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
    return sortedEntries.take(limit).map((e) => e.key).toList();
  }
}

// Manga data model
class Manga {
  final String id;
  final String title;
  final String coverImage;
  final String author;
  final double rating;
  final List<String> genres;
  final String description;
  final int totalChapters;
  final bool hasNewChapter;
  final Timestamp? lastUpdated;
  final int views;
  final String status;
  final int releaseYear;
  final String publisher;
  final List<String>? characters;

  Manga({
    required this.id,
    required this.title,
    required this.coverImage,
    required this.author,
    required this.rating,
    required this.genres,
    required this.description,
    required this.totalChapters,
    required this.hasNewChapter,
    this.lastUpdated,
    this.views = 0,
    this.status = 'Ongoing',
    this.releaseYear = 2020,
    this.publisher = 'Unknown',
    this.characters,
  });

  factory Manga.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return Manga(
      id: doc.id,
      title: data['title'] ?? 'Unknown Title',
      coverImage: data['coverImage'] ?? 'https://picsum.photos/150',
      author: data['author'] ?? 'Unknown',
      rating: (data['rating'] as num?)?.toDouble() ?? 4.0,
      genres: List<String>.from(data['genres'] ?? []),
      description: data['description'] ?? 'No description available.',
      totalChapters: (data['totalChapters'] as num?)?.toInt() ?? 0,
      hasNewChapter: data['hasNewChapter'] ?? false,
      lastUpdated: data['lastUpdated'] as Timestamp?,
      views: (data['views'] as num?)?.toInt() ?? 0,
      status: data['status'] ?? 'Ongoing',
      releaseYear: (data['releaseYear'] as num?)?.toInt() ?? 2020,
      publisher: data['publisher'] ?? 'Unknown',
      characters:
          data['characters'] != null
              ? List<String>.from(data['characters'])
              : null,
    );
  }
}
