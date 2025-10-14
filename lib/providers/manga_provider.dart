import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/manga.dart';

class MangaProvider extends ChangeNotifier {
  // User preferences collections
  final Set<String> _favorites = {};
  final Set<String> _readingList = {};
  final Map<String, int> _readingProgress = {};
  final Map<String, Map<String, dynamic>> _chapterBookmarks = {};
  final Map<String, DateTime> _historyList = {};

  // Reading settings
  bool _darkModeReading = true;
  double _fontSize = 16.0;
  double _brightness = 0.7;
  bool _keepScreenOn = true;
  String _pageTransition = 'slide';

  // Cached manga data
  final Map<String, Manga> _cachedManga = {};

  // Loading state
  bool _isLoading = false;

  bool get isLoading => _isLoading;
  Set<String> get favorites => _favorites;
  Set<String> get readingList => _readingList;
  Map<String, DateTime> get historyList => _historyList;
  Map<String, int> get readingProgress => _readingProgress;
  Map<String, Map<String, dynamic>> get chapterBookmarks => _chapterBookmarks;

  // Reading settings getters
  bool get darkModeReading => _darkModeReading;
  double get fontSize => _fontSize;
  double get brightness => _brightness;
  bool get keepScreenOn => _keepScreenOn;
  String get pageTransition => _pageTransition;

  // Initialize provider and load saved data
  Future<void> initialize() async {
    _setLoading(true);
    await _loadPreferences();
    _setLoading(false);
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  // Check if manga is in collections
  bool isFavorite(String mangaId) => _favorites.contains(mangaId);
  bool isReading(String mangaId) => _readingList.contains(mangaId);
  int getProgress(String mangaId) => _readingProgress[mangaId] ?? 0;

  // Get bookmark for a specific chapter
  Map<String, dynamic>? getChapterBookmark(String mangaId, int chapterNumber) {
    final key = '$mangaId-$chapterNumber';
    return _chapterBookmarks[key];
  }

  // Toggle favorite status
  Future<void> toggleFavorite(String mangaId) async {
    if (_favorites.contains(mangaId)) {
      _favorites.remove(mangaId);
    } else {
      _favorites.add(mangaId);
      // Also track when manga was added to favorites
      _historyList[mangaId] = DateTime.now();
    }
    await _savePreferences();
    notifyListeners();
  }

  // Toggle reading list status
  Future<void> toggleReading(String mangaId) async {
    if (_readingList.contains(mangaId)) {
      _readingList.remove(mangaId);
    } else {
      _readingList.add(mangaId);
      // Also track when manga was added to reading list
      _historyList[mangaId] = DateTime.now();
    }
    await _savePreferences();
    notifyListeners();
  }

  // Update reading progress for a manga
  Future<void> updateProgress(String mangaId, int chapter) async {
    // Only update if it's a newer chapter
    if ((getProgress(mangaId) < chapter) || getProgress(mangaId) == 0) {
      _readingProgress[mangaId] = chapter;

      // Automatically add to reading list
      if (!_readingList.contains(mangaId)) {
        _readingList.add(mangaId);
      }

      // Update timestamp in history
      _historyList[mangaId] = DateTime.now();

      await _savePreferences();
      notifyListeners();
    }
  }

  // Save bookmark for a chapter
  Future<void> saveChapterBookmark(
    String mangaId,
    int chapterNumber,
    int pageNumber,
    String? note,
  ) async {
    final key = '$mangaId-$chapterNumber';
    _chapterBookmarks[key] = {
      'mangaId': mangaId,
      'chapter': chapterNumber,
      'page': pageNumber,
      'note': note,
      'timestamp': DateTime.now().toIso8601String(),
    };
    await _savePreferences();
    notifyListeners();
  }

  // Remove bookmark for a chapter
  Future<void> removeChapterBookmark(String mangaId, int chapterNumber) async {
    final key = '$mangaId-$chapterNumber';
    if (_chapterBookmarks.containsKey(key)) {
      _chapterBookmarks.remove(key);
      await _savePreferences();
      notifyListeners();
    }
  }

  // Remove manga from history
  Future<void> removeFromHistory(String mangaId) async {
    _historyList.remove(mangaId);
    await _savePreferences();
    notifyListeners();
  }

  // Clear reading history for all manga
  Future<void> clearReadingHistory() async {
    _historyList.clear();
    await _savePreferences();
    notifyListeners();
  }

  // Get manga from cache or add to cache
  Manga? getCachedManga(String mangaId) {
    return _cachedManga[mangaId];
  }

  void cacheManga(Manga manga) {
    _cachedManga[manga.id] = manga;
  }

  // Update reading settings
  Future<void> updateReadingSettings({
    bool? darkMode,
    double? fontSize,
    double? brightness,
    bool? keepScreenOn,
    String? pageTransition,
  }) async {
    if (darkMode != null) _darkModeReading = darkMode;
    if (fontSize != null) _fontSize = fontSize;
    if (brightness != null) _brightness = brightness;
    if (keepScreenOn != null) _keepScreenOn = keepScreenOn;
    if (pageTransition != null) _pageTransition = pageTransition;

    await _savePreferences();
    notifyListeners();
  }

  // Reset reading settings to defaults
  Future<void> resetReadingSettings() async {
    _darkModeReading = true;
    _fontSize = 16.0;
    _brightness = 0.7;
    _keepScreenOn = true;
    _pageTransition = 'slide';

    await _savePreferences();
    notifyListeners();
  }

  // Get recently read manga, sorted by last read time
  List<String> getRecentlyRead({int limit = 10}) {
    final sorted =
        _historyList.entries.toList()
          ..sort((a, b) => b.value.compareTo(a.value));

    return sorted.take(limit).map((entry) => entry.key).toList();
  }

  // Check if user has any saved manga data
  bool get hasUserData {
    return _favorites.isNotEmpty ||
        _readingList.isNotEmpty ||
        _readingProgress.isNotEmpty ||
        _chapterBookmarks.isNotEmpty;
  }

  // Calculate reading progress percentage for a manga
  double getReadingProgressPercentage(String mangaId, int totalChapters) {
    if (totalChapters == 0) return 0.0;
    final currentChapter = getProgress(mangaId);
    return (currentChapter / totalChapters).clamp(0.0, 1.0);
  }

  // Load preferences from persistent storage
  Future<void> _loadPreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Load collections
      final favoritesJson = prefs.getStringList('favorites') ?? [];
      final readingListJson = prefs.getStringList('readingList') ?? [];
      final progressJson = prefs.getString('readingProgress');
      final bookmarksJson = prefs.getString('chapterBookmarks');
      final historyJson = prefs.getString('historyList');

      // Load reading settings
      _darkModeReading = prefs.getBool('darkModeReading') ?? true;
      _fontSize = prefs.getDouble('fontSize') ?? 16.0;
      _brightness = prefs.getDouble('brightness') ?? 0.7;
      _keepScreenOn = prefs.getBool('keepScreenOn') ?? true;
      _pageTransition = prefs.getString('pageTransition') ?? 'slide';

      // Parse data
      _favorites.addAll(favoritesJson);
      _readingList.addAll(readingListJson);

      if (progressJson != null) {
        Map<String, dynamic> progressMap = jsonDecode(progressJson);
        progressMap.forEach((key, value) {
          _readingProgress[key] = value as int;
        });
      }

      if (bookmarksJson != null) {
        Map<String, dynamic> bookmarksMap = jsonDecode(bookmarksJson);
        bookmarksMap.forEach((key, value) {
          _chapterBookmarks[key] = value as Map<String, dynamic>;
        });
      }

      if (historyJson != null) {
        Map<String, dynamic> historyMap = jsonDecode(historyJson);
        historyMap.forEach((key, value) {
          _historyList[key] = DateTime.parse(value as String);
        });
      }
    } catch (e) {
      debugPrint('Error loading preferences: $e');
    }
  }

  // Save preferences to persistent storage
  Future<void> _savePreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Save collections
      await prefs.setStringList('favorites', _favorites.toList());
      await prefs.setStringList('readingList', _readingList.toList());

      // Convert maps to JSON strings
      final progressJson = jsonEncode(_readingProgress);
      final bookmarksJson = jsonEncode(_chapterBookmarks);

      // Convert DateTime map to string map
      final historyStringMap = <String, String>{};
      _historyList.forEach((key, value) {
        historyStringMap[key] = value.toIso8601String();
      });
      final historyJson = jsonEncode(historyStringMap);

      // Save as JSON strings
      await prefs.setString('readingProgress', progressJson);
      await prefs.setString('chapterBookmarks', bookmarksJson);
      await prefs.setString('historyList', historyJson);

      // Save reading settings
      await prefs.setBool('darkModeReading', _darkModeReading);
      await prefs.setDouble('fontSize', _fontSize);
      await prefs.setDouble('brightness', _brightness);
      await prefs.setBool('keepScreenOn', _keepScreenOn);
      await prefs.setString('pageTransition', _pageTransition);
    } catch (e) {
      debugPrint('Error saving preferences: $e');
    }
  }

  // Export user data to JSON
  String exportUserData() {
    final Map<String, dynamic> userData = {
      'favorites': _favorites.toList(),
      'readingList': _readingList.toList(),
      'readingProgress': _readingProgress,
      'chapterBookmarks': _chapterBookmarks,
      'history': _historyList.map(
        (key, value) => MapEntry(key, value.toIso8601String()),
      ),
      'readingSettings': {
        'darkMode': _darkModeReading,
        'fontSize': _fontSize,
        'brightness': _brightness,
        'keepScreenOn': _keepScreenOn,
        'pageTransition': _pageTransition,
      },
    };

    return jsonEncode(userData);
  }

  // Import user data from JSON
  Future<bool> importUserData(String jsonData) async {
    try {
      final Map<String, dynamic> userData = jsonDecode(jsonData);

      // Clear existing data
      _favorites.clear();
      _readingList.clear();
      _readingProgress.clear();
      _chapterBookmarks.clear();
      _historyList.clear();

      // Import collections
      _favorites.addAll(List<String>.from(userData['favorites'] ?? []));
      _readingList.addAll(List<String>.from(userData['readingList'] ?? []));

      // Import maps
      final Map<String, dynamic> progress = userData['readingProgress'] ?? {};
      progress.forEach((key, value) {
        _readingProgress[key] = value as int;
      });

      final Map<String, dynamic> bookmarks = userData['chapterBookmarks'] ?? {};
      bookmarks.forEach((key, value) {
        _chapterBookmarks[key] = value as Map<String, dynamic>;
      });

      final Map<String, dynamic> history = userData['history'] ?? {};
      history.forEach((key, value) {
        _historyList[key] = DateTime.parse(value as String);
      });

      // Import reading settings
      final Map<String, dynamic> settings = userData['readingSettings'] ?? {};
      _darkModeReading = settings['darkMode'] ?? true;
      _fontSize = (settings['fontSize'] as num?)?.toDouble() ?? 16.0;
      _brightness = (settings['brightness'] as num?)?.toDouble() ?? 0.7;
      _keepScreenOn = settings['keepScreenOn'] ?? true;
      _pageTransition = settings['pageTransition'] ?? 'slide';

      await _savePreferences();
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Error importing user data: $e');
      return false;
    }
  }
}
