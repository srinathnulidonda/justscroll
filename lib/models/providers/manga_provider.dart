// models/providers/manga_provider.dart

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class MangaProvider extends ChangeNotifier {
  final Set<String> _favorites = {};
  final Set<String> _readingList = {};
  Map<String, int> _readingProgress = {};

  // Getters
  Set<String> get favorites => _favorites;
  Set<String> get readingList => _readingList;
  Map<String, int> get readingProgress => _readingProgress;

  bool isFavorite(String mangaId) => _favorites.contains(mangaId);
  bool isReading(String mangaId) => _readingList.contains(mangaId);
  int getProgress(String mangaId) => _readingProgress[mangaId] ?? 0;

  MangaProvider() {
    _loadFromPrefs();
  }

  // Toggle favorite status
  void toggleFavorite(String mangaId) {
    _favorites.contains(mangaId)
        ? _favorites.remove(mangaId)
        : _favorites.add(mangaId);
    notifyListeners();
    _saveToPrefs();
  }

  // Toggle reading list
  void toggleReading(String mangaId) {
    _readingList.contains(mangaId)
        ? _readingList.remove(mangaId)
        : _readingList.add(mangaId);
    notifyListeners();
    _saveToPrefs();
  }

  // Update reading progress
  void updateProgress(String mangaId, int chapter) {
    _readingProgress[mangaId] = chapter;
    notifyListeners();
    _saveToPrefs();
  }

  // Load data from SharedPreferences
  Future<void> _loadFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();

    final favoritesList = prefs.getStringList('favorites') ?? [];
    _favorites.addAll(favoritesList);

    final readingList = prefs.getStringList('readingList') ?? [];
    _readingList.addAll(readingList);

    final progressJson = prefs.getString('readingProgress');
    if (progressJson != null) {
      final decodedMap = jsonDecode(progressJson) as Map<String, dynamic>;
      _readingProgress = Map.fromEntries(
        decodedMap.entries.map((e) => MapEntry(e.key, e.value as int)),
      );
    }

    notifyListeners();
  }

  // Save data to SharedPreferences
  Future<void> _saveToPrefs() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setStringList('favorites', _favorites.toList());
    await prefs.setStringList('readingList', _readingList.toList());
    await prefs.setString('readingProgress', jsonEncode(_readingProgress));
  }
}
