// lib/stores/reader_store.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ReaderState {
  final String quality;
  final String mode;
  final int currentPage;
  final int totalPages;
  final bool showUI;

  const ReaderState({
    this.quality = 'data',
    this.mode = 'single',
    this.currentPage = 0,
    this.totalPages = 0,
    this.showUI = true,
  });

  ReaderState copyWith({String? quality, String? mode, int? currentPage, int? totalPages, bool? showUI}) {
    return ReaderState(
      quality: quality ?? this.quality,
      mode: mode ?? this.mode,
      currentPage: currentPage ?? this.currentPage,
      totalPages: totalPages ?? this.totalPages,
      showUI: showUI ?? this.showUI,
    );
  }
}

class ReaderNotifier extends StateNotifier<ReaderState> {
  ReaderNotifier() : super(const ReaderState()) {
    _loadPrefs();
  }

  Future<void> _loadPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    state = state.copyWith(
      quality: prefs.getString('reader_quality') ?? 'data',
      mode: prefs.getString('reader_mode') ?? 'single',
    );
  }

  Future<void> setQuality(String q) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('reader_quality', q);
    state = state.copyWith(quality: q);
  }

  Future<void> setMode(String m) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('reader_mode', m);
    state = state.copyWith(mode: m);
  }

  void setCurrentPage(int p) => state = state.copyWith(currentPage: p);
  void setTotalPages(int t) => state = state.copyWith(totalPages: t);
  void toggleUI() => state = state.copyWith(showUI: !state.showUI);
  void reset() => state = state.copyWith(currentPage: 0, totalPages: 0, showUI: true);
}

final readerStoreProvider = StateNotifierProvider<ReaderNotifier, ReaderState>((ref) => ReaderNotifier());