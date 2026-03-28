// lib/components/manga/reader_view.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:justscroll/stores/reader_store.dart';
import 'package:justscroll/stores/auth_store.dart';
import 'package:justscroll/lib/api.dart';
import 'package:justscroll/lib/utils.dart' as utils;
import 'package:justscroll/models/chapter.dart';
import 'package:justscroll/components/common/optimized_image.dart';
import 'package:justscroll/components/ui/button.dart';

class ReaderView extends ConsumerStatefulWidget {
  final List<String> pages;
  final String chapterId;
  final List<Chapter> chapters;
  final String mangaTitle;
  final String chapterTitle;
  final String chapterNumber;
  final String mangaId;

  const ReaderView({
    super.key,
    required this.pages,
    required this.chapterId,
    required this.chapters,
    required this.mangaTitle,
    required this.chapterTitle,
    required this.chapterNumber,
    required this.mangaId,
  });

  @override
  ConsumerState<ReaderView> createState() => _ReaderViewState();
}

class _ReaderViewState extends ConsumerState<ReaderView> {
  bool _showUI = true;
  int _currentPage = 0;
  bool _settingsOpen = false;
  String _bgColor = 'black';
  String _direction = 'ltr';
  Timer? _hideTimer;
  final ScrollController _scrollController = ScrollController();
  final PageController _pageController = PageController();

  int get _totalPages => widget.pages.length;
  String get _chapterDisplay => widget.chapterNumber.isNotEmpty ? 'Ch. ${widget.chapterNumber}' : (widget.chapterTitle.isNotEmpty ? widget.chapterTitle : 'Chapter');

  int get _currentChapterIndex => widget.chapters.indexWhere((c) => c.id == widget.chapterId);
  Chapter? get _prevChapter => _currentChapterIndex > 0 ? widget.chapters[_currentChapterIndex - 1] : null;
  Chapter? get _nextChapter => _currentChapterIndex < widget.chapters.length - 1 ? widget.chapters[_currentChapterIndex + 1] : null;

  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    _resetHideTimer();
    _saveProgress();
  }

  @override
  void dispose() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    _hideTimer?.cancel();
    _scrollController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  void _resetHideTimer() {
    _hideTimer?.cancel();
    _hideTimer = Timer(const Duration(seconds: 4), () {
      if (mounted && _showUI && !_settingsOpen) setState(() => _showUI = false);
    });
  }

  void _toggleUI() {
    setState(() => _showUI = !_showUI);
    if (_showUI) _resetHideTimer();
  }

  void _goToChapter(String id) {
    context.go('/read/$id?manga=${widget.mangaId}');
  }

  void _goPage(int dir) {
    final reader = ref.read(readerStoreProvider);
    if (reader.mode == 'continuous') return;
    final actualDir = _direction == 'rtl' ? -dir : dir;
    final next = _currentPage + actualDir;
    if (next < 0) {
      if (_prevChapter != null) _goToChapter(_prevChapter!.id);
      return;
    }
    if (next >= _totalPages) {
      if (_nextChapter != null) _goToChapter(_nextChapter!.id);
      return;
    }
    setState(() => _currentPage = next);
    _pageController.animateToPage(next, duration: const Duration(milliseconds: 200), curve: Curves.easeOut);
    _saveProgress();
    _resetHideTimer();
  }

  void _saveProgress() {
    final auth = ref.read(authStoreProvider);
    if (auth.isAuthenticated && widget.mangaId.isNotEmpty) {
      ApiClient.instance.updateHistory(
        mangaId: widget.mangaId,
        chapterId: widget.chapterId,
        mangaTitle: widget.mangaTitle,
        chapterNumber: widget.chapterNumber.isNotEmpty ? widget.chapterNumber : null,
        pageNumber: _currentPage + 1,
      ).catchError((_) {});
    }
  }

  Color get _bgColorValue => switch (_bgColor) {
    'dark' => const Color(0xFF18181B),
    'white' => Colors.white,
    _ => Colors.black,
  };

  @override
  Widget build(BuildContext context) {
    final reader = ref.watch(readerStoreProvider);
    final isSingle = reader.mode == 'single';

    return Scaffold(
      backgroundColor: _bgColorValue,
      body: KeyboardListener(
        focusNode: FocusNode()..requestFocus(),
        onKeyEvent: (event) {
          if (event is KeyDownEvent) {
            if (event.logicalKey == LogicalKeyboardKey.arrowLeft) _goPage(-1);
            if (event.logicalKey == LogicalKeyboardKey.arrowRight || event.logicalKey == LogicalKeyboardKey.space) _goPage(1);
            if (event.logicalKey == LogicalKeyboardKey.escape) {
              if (_settingsOpen) { setState(() => _settingsOpen = false); }
              else { context.go(widget.mangaId.isNotEmpty ? '/manga/${widget.mangaId}' : '/'); }
            }
          }
        },
        child: Stack(
          children: [
            GestureDetector(
              onTap: _toggleUI,
              child: isSingle ? _buildSingleMode() : _buildContinuousMode(reader),
            ),
            if (_showUI) _buildTopBar(),
            if (_showUI && isSingle) _buildBottomBar(),
            if (_settingsOpen) _buildSettings(reader),
          ],
        ),
      ),
    );
  }

  Widget _buildSingleMode() {
    return Stack(
      children: [
        PageView.builder(
          controller: _pageController,
          reverse: _direction == 'rtl',
          itemCount: _totalPages,
          onPageChanged: (p) {
            setState(() => _currentPage = p);
            _saveProgress();
            _resetHideTimer();
          },
          itemBuilder: (_, i) {
            final url = utils.proxyImage(widget.pages[i]);
            return InteractiveViewer(
              minScale: 1,
              maxScale: 3,
              child: Center(
                child: Image.network(
                  url,
                  fit: BoxFit.contain,
                  loadingBuilder: (_, child, progress) {
                    if (progress == null) return child;
                    return const Center(child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white30));
                  },
                  errorBuilder: (_, __, ___) => const Center(
                    child: Column(mainAxisSize: MainAxisSize.min, children: [
                      Icon(Icons.broken_image, size: 32, color: Colors.white24),
                      SizedBox(height: 8),
                      Text('Failed to load', style: TextStyle(fontSize: 12, color: Colors.white30)),
                    ]),
                  ),
                ),
              ),
            );
          },
        ),
        Positioned(
          left: 0, top: 0, bottom: 0,
          child: GestureDetector(
            onTap: () => _goPage(-1),
            behavior: HitTestBehavior.translucent,
            child: SizedBox(width: MediaQuery.of(context).size.width * 0.25),
          ),
        ),
        Positioned(
          right: 0, top: 0, bottom: 0,
          child: GestureDetector(
            onTap: () => _goPage(1),
            behavior: HitTestBehavior.translucent,
            child: SizedBox(width: MediaQuery.of(context).size.width * 0.25),
          ),
        ),
      ],
    );
  }

  Widget _buildContinuousMode(ReaderState reader) {
    return ListView.builder(
      controller: _scrollController,
      padding: EdgeInsets.only(top: _showUI ? 64 : 0),
      itemCount: _totalPages + 1,
      itemBuilder: (_, i) {
        if (i == _totalPages) return _buildEndChapter();
        final url = utils.proxyImage(widget.pages[i]);
        return Image.network(
          url,
          fit: BoxFit.fitWidth,
          loadingBuilder: (_, child, progress) {
            if (progress == null) return child;
            return const SizedBox(height: 300, child: Center(child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white24)));
          },
          errorBuilder: (_, __, ___) => SizedBox(
            height: 200,
            child: Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
              const Icon(Icons.broken_image, size: 24, color: Colors.white24),
              Text('Page ${i + 1} failed', style: const TextStyle(fontSize: 11, color: Colors.white30)),
            ])),
          ),
        );
      },
    );
  }

  Widget _buildEndChapter() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 16),
      child: Column(
        children: [
          Text('End of $_chapterDisplay', style: const TextStyle(fontSize: 14, color: Colors.white30)),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (_prevChapter != null)
                AppButton(
                  label: 'Previous',
                  icon: Icons.chevron_left,
                  variant: ButtonVariant.outline,
                  size: ButtonSize.sm,
                  onPressed: () => _goToChapter(_prevChapter!.id),
                ),
              if (_prevChapter != null && _nextChapter != null) const SizedBox(width: 12),
              if (_nextChapter != null)
                AppButton(
                  label: 'Next Chapter',
                  trailingIcon: Icons.chevron_right,
                  onPressed: () => _goToChapter(_nextChapter!.id),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTopBar() {
    return Positioned(
      top: 0, left: 0, right: 0,
      child: AnimatedOpacity(
        opacity: _showUI ? 1 : 0,
        duration: const Duration(milliseconds: 200),
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Color(0xE6000000), Colors.transparent]),
          ),
          child: SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white70, size: 22),
                    onPressed: () => context.go(widget.mangaId.isNotEmpty ? '/manga/${widget.mangaId}' : '/'),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(widget.mangaTitle, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.white)),
                        Text(_chapterDisplay, style: const TextStyle(fontSize: 11, color: Colors.white54)),
                      ],
                    ),
                  ),
                  if (widget.chapters.length > 1)
                    IconButton(
                      icon: const Icon(Icons.list, color: Colors.white60, size: 22),
                      onPressed: () => _showChapterSelector(),
                    ),
                  IconButton(
                    icon: const Icon(Icons.settings, color: Colors.white60, size: 22),
                    onPressed: () => setState(() => _settingsOpen = true),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBottomBar() {
    final pct = _totalPages > 0 ? (_currentPage + 1) / _totalPages : 0.0;
    return Positioned(
      bottom: 0, left: 0, right: 0,
      child: AnimatedOpacity(
        opacity: _showUI ? 1 : 0,
        duration: const Duration(milliseconds: 200),
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(begin: Alignment.bottomCenter, end: Alignment.topCenter, colors: [Color(0xE6000000), Colors.transparent]),
          ),
          child: SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 24, 16, 12),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SliderTheme(
                    data: SliderThemeData(
                      trackHeight: 3,
                      thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
                      overlayShape: const RoundSliderOverlayShape(overlayRadius: 14),
                      activeTrackColor: Theme.of(context).colorScheme.primary,
                      inactiveTrackColor: Colors.white12,
                      thumbColor: Theme.of(context).colorScheme.primary,
                    ),
                    child: Slider(
                      value: _currentPage.toDouble(),
                      min: 0,
                      max: (_totalPages - 1).toDouble().clamp(0, double.infinity),
                      onChanged: (v) {
                        final p = v.round();
                        setState(() => _currentPage = p);
                        _pageController.jumpToPage(p);
                      },
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      GestureDetector(
                        onTap: () => _goPage(-1),
                        child: Padding(
                          padding: const EdgeInsets.all(8),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.chevron_left, size: 18, color: Colors.white70),
                              const Text('Prev', style: TextStyle(fontSize: 13, color: Colors.white70)),
                            ],
                          ),
                        ),
                      ),
                      Row(
                        children: [
                          if (_prevChapter != null)
                            GestureDetector(
                              onTap: () => _goToChapter(_prevChapter!.id),
                              child: const Padding(
                                padding: EdgeInsets.all(8),
                                child: Text('← Prev Ch.', style: TextStyle(fontSize: 10, color: Colors.white38)),
                              ),
                            ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            child: Text(
                              '${_currentPage + 1} / $_totalPages',
                              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.white70, fontFamily: 'monospace'),
                            ),
                          ),
                          if (_nextChapter != null)
                            GestureDetector(
                              onTap: () => _goToChapter(_nextChapter!.id),
                              child: const Padding(
                                padding: EdgeInsets.all(8),
                                child: Text('Next Ch. →', style: TextStyle(fontSize: 10, color: Colors.white38)),
                              ),
                            ),
                        ],
                      ),
                      GestureDetector(
                        onTap: () => _goPage(1),
                        child: Padding(
                          padding: const EdgeInsets.all(8),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Text('Next', style: TextStyle(fontSize: 13, color: Colors.white70)),
                              const Icon(Icons.chevron_right, size: 18, color: Colors.white70),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSettings(ReaderState reader) {
    final theme = Theme.of(context);
    return Positioned.fill(
      child: GestureDetector(
        onTap: () => setState(() => _settingsOpen = false),
        child: Container(
          color: Colors.black54,
          child: Align(
            alignment: Alignment.bottomCenter,
            child: GestureDetector(
              onTap: () {},
              child: Container(
                constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.8),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                ),
                child: SafeArea(
                  top: false,
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Center(child: Container(width: 36, height: 4, decoration: BoxDecoration(color: theme.colorScheme.onSurface.withOpacity(0.15), borderRadius: BorderRadius.circular(2)))),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Text('Reader Settings', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: theme.colorScheme.onSurface)),
                            const Spacer(),
                            IconButton(icon: const Icon(Icons.close, size: 20), onPressed: () => setState(() => _settingsOpen = false)),
                          ],
                        ),
                        const SizedBox(height: 20),
                        _settingSection('Image Quality', [
                          _settingOption('High', Icons.image, reader.quality == 'data', () => ref.read(readerStoreProvider.notifier).setQuality('data')),
                          _settingOption('Data Saver', Icons.flash_on, reader.quality == 'dataSaver', () => ref.read(readerStoreProvider.notifier).setQuality('dataSaver')),
                        ]),
                        const SizedBox(height: 16),
                        _settingSection('Reading Mode', [
                          _settingOption('Single Page', Icons.view_column, reader.mode == 'single', () => ref.read(readerStoreProvider.notifier).setMode('single')),
                          _settingOption('Long Strip', Icons.view_agenda, reader.mode == 'continuous', () => ref.read(readerStoreProvider.notifier).setMode('continuous')),
                        ]),
                        if (reader.mode == 'single') ...[
                          const SizedBox(height: 16),
                          _settingSection('Direction', [
                            _settingOption('Left → Right', Icons.chevron_right, _direction == 'ltr', () => setState(() => _direction = 'ltr')),
                            _settingOption('Right → Left', Icons.chevron_left, _direction == 'rtl', () => setState(() => _direction = 'rtl')),
                          ]),
                        ],
                        const SizedBox(height: 16),
                        _settingSection('Background', [
                          _settingOption('Black', Icons.dark_mode, _bgColor == 'black', () => setState(() => _bgColor = 'black')),
                          _settingOption('Dark', Icons.monitor, _bgColor == 'dark', () => setState(() => _bgColor = 'dark')),
                          _settingOption('White', Icons.light_mode, _bgColor == 'white', () => setState(() => _bgColor = 'white')),
                        ]),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _settingSection(String title, List<Widget> options) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5), letterSpacing: 0.5)),
        const SizedBox(height: 8),
        Wrap(spacing: 8, runSpacing: 8, children: options),
      ],
    );
  }

  Widget _settingOption(String label, IconData icon, bool active, VoidCallback onTap) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: active ? theme.colorScheme.primary : theme.colorScheme.surfaceContainerHighest.withOpacity(0.5),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: active ? theme.colorScheme.onPrimary : theme.colorScheme.onSurface.withOpacity(0.6)),
            const SizedBox(width: 6),
            Text(label, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: active ? theme.colorScheme.onPrimary : theme.colorScheme.onSurface.withOpacity(0.7))),
            if (active) ...[
              const SizedBox(width: 6),
              Icon(Icons.check, size: 14, color: theme.colorScheme.onPrimary),
            ],
          ],
        ),
      ),
    );
  }

  void _showChapterSelector() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) {
        final theme = Theme.of(ctx);
        final readable = widget.chapters.where((c) => c.readable && c.pages > 0).toList();
        return Container(
          constraints: BoxConstraints(maxHeight: MediaQuery.of(ctx).size.height * 0.7),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: SafeArea(
            top: false,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 12),
                Container(width: 36, height: 4, decoration: BoxDecoration(color: theme.colorScheme.onSurface.withOpacity(0.15), borderRadius: BorderRadius.circular(2))),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                  child: Text('Chapters', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: theme.colorScheme.onSurface)),
                ),
                Flexible(
                  child: ListView.builder(
                    shrinkWrap: true,
                    padding: const EdgeInsets.fromLTRB(12, 0, 12, 16),
                    itemCount: readable.length,
                    itemBuilder: (_, i) {
                      final ch = readable[i];
                      final isCurrent = ch.id == widget.chapterId;
                      return ListTile(
                        dense: true,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        selected: isCurrent,
                        selectedTileColor: theme.colorScheme.primary.withOpacity(0.1),
                        leading: Icon(Icons.menu_book, size: 18, color: isCurrent ? theme.colorScheme.primary : theme.colorScheme.onSurface.withOpacity(0.4)),
                        title: Text(ch.label, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 13, fontWeight: isCurrent ? FontWeight.w600 : FontWeight.w500, color: isCurrent ? theme.colorScheme.primary : null)),
                        trailing: isCurrent ? Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(color: theme.colorScheme.primary.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
                          child: Text('Current', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: theme.colorScheme.primary)),
                        ) : null,
                        onTap: () {
                          Navigator.pop(ctx);
                          _goToChapter(ch.id);
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}