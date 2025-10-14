import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/manga.dart';
import '../providers/manga_provider.dart';
import '../constants.dart';

class ReadingScreen extends StatefulWidget {
  final Manga manga;
  final Chapter? initialChapter;

  const ReadingScreen({super.key, required this.manga, this.initialChapter});

  @override
  State<ReadingScreen> createState() => _ReadingScreenState();
}

class _ReadingScreenState extends State<ReadingScreen>
    with SingleTickerProviderStateMixin {
  late PdfViewerController _pdfViewerController;
  late int _currentChapter;
  bool _isFullScreen = false;
  bool _isLoading = true;
  double _loadingProgress = 0.0;
  int _currentPage = 0;
  int _totalPages = 0;
  bool _isControlsVisible = true;
  bool _isDarkMode = false;
  bool _isPageTurnAnimationEnabled = true;
  bool _showSettingsPanel = false;
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _pdfViewerController = PdfViewerController();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );

    if (widget.initialChapter != null) {
      _currentChapter = widget.manga.chapters.indexWhere(
        (chapter) => chapter.id == widget.initialChapter!.id,
      );
      if (_currentChapter == -1) _currentChapter = 0;
    } else {
      _loadSavedProgress();
    }

    // Enter fullscreen mode
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

    // Auto-hide controls after 3 seconds
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted && _isControlsVisible) {
        setState(() {
          _isControlsVisible = false;
        });
      }
    });
  }

  void _loadSavedProgress() {
    final provider = Provider.of<MangaProvider>(context, listen: false);
    _currentChapter = provider.getProgress(widget.manga.id) - 1;
    if (_currentChapter < 0) _currentChapter = 0;
  }

  void _toggleControls() {
    setState(() {
      _isControlsVisible = !_isControlsVisible;
    });

    if (_isControlsVisible) {
      _animationController.forward();
      // Auto-hide after 3 seconds
      Future.delayed(const Duration(seconds: 3), () {
        if (mounted && _isControlsVisible) {
          setState(() {
            _isControlsVisible = false;
          });
          _animationController.reverse();
        }
      });
    } else {
      _animationController.reverse();
    }
  }

  void _toggleFullScreen() {
    setState(() {
      _isFullScreen = !_isFullScreen;
    });

    if (_isFullScreen) {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    } else {
      SystemChrome.setEnabledSystemUIMode(
        SystemUiMode.manual,
        overlays: [SystemUiOverlay.top, SystemUiOverlay.bottom],
      );
    }
  }

  void _changeChapter(int newChapter) {
    if (newChapter >= 0 && newChapter < widget.manga.chapters.length) {
      setState(() {
        _isLoading = true;
        _loadingProgress = 0.0;
        _currentChapter = newChapter;
        _currentPage = 0;
      });

      final provider = Provider.of<MangaProvider>(context, listen: false);
      provider.updateProgress(widget.manga.id, _currentChapter + 1);
      provider.markChapterAsRead(
        widget.manga.id,
        widget.manga.chapters[_currentChapter].id,
      );
    }
  }

  void _addBookmark() {
    // Implementation for adding bookmarks
    final bookmarkInfo = {
      'mangaId': widget.manga.id,
      'chapterIndex': _currentChapter,
      'pageNumber': _currentPage,
      'timestamp': DateTime.now().toString(),
    };

    // Implement your bookmark saving logic here

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Bookmarked Chapter ${_currentChapter + 1}, Page ${_currentPage + 1}',
        ),
        duration: const Duration(seconds: 2),
        action: SnackBarAction(
          label: 'View All',
          onPressed: () {
            // Navigate to bookmarks screen
          },
        ),
      ),
    );
  }

  void _toggleDarkMode() {
    setState(() {
      _isDarkMode = !_isDarkMode;
    });
  }

  void _togglePageTurnAnimation() {
    setState(() {
      _isPageTurnAnimationEnabled = !_isPageTurnAnimationEnabled;
    });
  }

  void _downloadChapter() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              strokeWidth: 2,
            ),
            const SizedBox(width: 16),
            Text('Downloading Chapter ${_currentChapter + 1}...'),
          ],
        ),
        duration: const Duration(seconds: 3),
      ),
    );

    // Implement actual download logic here

    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Chapter ${_currentChapter + 1} downloaded successfully',
            ),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    });
  }

  Widget _buildChapterNavigationButton({
    required IconData icon,
    required bool isEnabled,
    required VoidCallback? onPressed,
    required bool isNext,
  }) {
    final theme = Theme.of(context);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: isEnabled ? onPressed : null,
        borderRadius: BorderRadius.circular(30),
        child: Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color:
                isEnabled
                    ? theme.primaryColor.withOpacity(0.9)
                    : Colors.grey.withOpacity(0.3),
            boxShadow:
                isEnabled
                    ? [
                      BoxShadow(
                        color: theme.primaryColor.withOpacity(0.3),
                        blurRadius: 8,
                        spreadRadius: 1,
                      ),
                    ]
                    : null,
          ),
          child: Icon(
            icon,
            color: isEnabled ? Colors.white : Colors.grey,
            size: 24,
          ),
        ),
      ),
    );
  }

  Widget _buildSettingsPanel() {
    return AnimatedPositioned(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      right: _showSettingsPanel ? 0 : -280,
      top: 0,
      bottom: 0,
      width: 280,
      child: Container(
        decoration: BoxDecoration(
          color: _isDarkMode ? Colors.grey[900] : Colors.white,
          boxShadow: [
            BoxShadow(color: Colors.black26, blurRadius: 10, spreadRadius: 2),
          ],
        ),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Reading Settings',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: _isDarkMode ? Colors.white : Colors.black87,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () {
                        setState(() {
                          _showSettingsPanel = false;
                        });
                      },
                      color: _isDarkMode ? Colors.white70 : Colors.black54,
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              ListTile(
                leading: Icon(
                  _isDarkMode ? Icons.nightlight_round : Icons.wb_sunny,
                  color: _isDarkMode ? Colors.white70 : Colors.orange,
                ),
                title: Text(
                  'Dark Mode',
                  style: TextStyle(
                    color: _isDarkMode ? Colors.white : Colors.black87,
                  ),
                ),
                trailing: Switch(
                  value: _isDarkMode,
                  onChanged: (_) => _toggleDarkMode(),
                  activeColor: kAccentColor,
                ),
              ),
              ListTile(
                leading: Icon(
                  Icons.animation,
                  color: _isDarkMode ? Colors.white70 : Colors.black87,
                ),
                title: Text(
                  'Page Turn Animation',
                  style: TextStyle(
                    color: _isDarkMode ? Colors.white : Colors.black87,
                  ),
                ),
                trailing: Switch(
                  value: _isPageTurnAnimationEnabled,
                  onChanged: (_) => _togglePageTurnAnimation(),
                  activeColor: kAccentColor,
                ),
              ),
              ListTile(
                leading: Icon(
                  Icons.download,
                  color: _isDarkMode ? Colors.white70 : Colors.black87,
                ),
                title: Text(
                  'Download Chapter',
                  style: TextStyle(
                    color: _isDarkMode ? Colors.white : Colors.black87,
                  ),
                ),
                onTap: _downloadChapter,
              ),
              ListTile(
                leading: Icon(
                  Icons.bookmark,
                  color: _isDarkMode ? Colors.white70 : Colors.black87,
                ),
                title: Text(
                  'Add Bookmark',
                  style: TextStyle(
                    color: _isDarkMode ? Colors.white : Colors.black87,
                  ),
                ),
                onTap: _addBookmark,
              ),
              ListTile(
                leading: Icon(
                  Icons.fullscreen,
                  color: _isDarkMode ? Colors.white70 : Colors.black87,
                ),
                title: Text(
                  'Fullscreen Mode',
                  style: TextStyle(
                    color: _isDarkMode ? Colors.white : Colors.black87,
                  ),
                ),
                trailing: Switch(
                  value: _isFullScreen,
                  onChanged: (_) => _toggleFullScreen(),
                  activeColor: kAccentColor,
                ),
              ),
              const Spacer(),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  'Chapter ${_currentChapter + 1}: ${widget.manga.chapters[_currentChapter].title}',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: _isDarkMode ? Colors.white70 : Colors.black87,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final systemDarkMode = theme.brightness == Brightness.dark;
    final effectiveDarkMode = _isDarkMode || systemDarkMode;
    final provider = Provider.of<MangaProvider>(context);

    return WillPopScope(
      onWillPop: () async {
        if (_showSettingsPanel) {
          setState(() {
            _showSettingsPanel = false;
          });
          return false;
        }

        // Exit fullscreen mode when leaving
        SystemChrome.setEnabledSystemUIMode(
          SystemUiMode.manual,
          overlays: [SystemUiOverlay.top, SystemUiOverlay.bottom],
        );
        return true;
      },
      child: Scaffold(
        backgroundColor: effectiveDarkMode ? Colors.black : Colors.white,
        body: Stack(
          children: [
            // PDF Viewer
            GestureDetector(
              onTap: _toggleControls,
              child: SfPdfViewer.network(
                widget.manga.chapters[_currentChapter].pdfUrl,
                controller: _pdfViewerController,
                enableDoubleTapZooming: true,
                pageSpacing: 0,
                canShowScrollHead: false,
                canShowScrollStatus: false,
                canShowPaginationDialog: false,
                enableTextSelection: false,
                pageLayoutMode: PdfPageLayoutMode.single,
                scrollDirection: PdfScrollDirection.horizontal,
                enableDocumentLinkAnnotation: false,
                interactionMode: PdfInteractionMode.pan,
                onDocumentLoaded: (details) {
                  setState(() {
                    _isLoading = false;
                    _totalPages = details.document.pages.count;
                  });
                },
                onDocumentLoadFailed: (details) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Failed to load chapter: ${details.error}'),
                      backgroundColor: Colors.red,
                    ),
                  );
                  setState(() {
                    _isLoading = false;
                  });
                },
                onPageChanged: (details) {
                  setState(() {
                    _currentPage = details.newPageNumber - 1;
                  });
                  provider.updateProgress(widget.manga.id, _currentChapter + 1);
                },
              ),
            ),

            // Loading Indicator
            if (_isLoading)
              Container(
                color:
                    effectiveDarkMode
                        ? Colors.black.withOpacity(0.8)
                        : Colors.white.withOpacity(0.8),
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        width: 100,
                        height: 100,
                        child: CircularProgressIndicator(
                          value: _loadingProgress > 0 ? _loadingProgress : null,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            kAccentColor,
                          ),
                          strokeWidth: 4,
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'Loading Chapter ${_currentChapter + 1}...',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                          color:
                              effectiveDarkMode ? Colors.white : Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 8),
                      CachedNetworkImage(
                        imageUrl: widget.manga.coverImage,
                        width: 80,
                        height: 120,
                        fit: BoxFit.cover,
                        placeholder:
                            (_, __) => Container(color: Colors.grey[800]),
                        errorWidget: (_, __, ___) => const Icon(Icons.error),
                        imageBuilder:
                            (context, imageProvider) => Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.3),
                                    blurRadius: 8,
                                    spreadRadius: 1,
                                  ),
                                ],
                                image: DecorationImage(
                                  image: imageProvider,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                      ),
                    ],
                  ),
                ),
              ),

            // Top Controls (AppBar)
            AnimatedPositioned(
              duration: const Duration(milliseconds: 200),
              top: _isControlsVisible ? 0 : -80,
              left: 0,
              right: 0,
              child: FadeTransition(
                opacity: _animation,
                child: Container(
                  height: 80 + MediaQuery.of(context).padding.top,
                  padding: EdgeInsets.only(
                    top: MediaQuery.of(context).padding.top,
                  ),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        effectiveDarkMode
                            ? Colors.black.withOpacity(0.9)
                            : Colors.white.withOpacity(0.9),
                        effectiveDarkMode
                            ? Colors.black.withOpacity(0.6)
                            : Colors.white.withOpacity(0.6),
                        effectiveDarkMode
                            ? Colors.black.withOpacity(0.0)
                            : Colors.white.withOpacity(0.0),
                      ],
                    ),
                  ),
                  child: Row(
                    children: [
                      IconButton(
                        icon: Icon(
                          Icons.arrow_back,
                          color:
                              effectiveDarkMode ? Colors.white : Colors.black87,
                        ),
                        onPressed: () {
                          Navigator.pop(context);
                        },
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              widget.manga.title,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color:
                                    effectiveDarkMode
                                        ? Colors.white
                                        : Colors.black87,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Chapter ${_currentChapter + 1}: ${widget.manga.chapters[_currentChapter].title}',
                              style: TextStyle(
                                fontSize: 14,
                                color:
                                    effectiveDarkMode
                                        ? Colors.white70
                                        : Colors.black54,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: Icon(
                          Icons.bookmark_border,
                          color:
                              effectiveDarkMode ? Colors.white : Colors.black87,
                        ),
                        onPressed: _addBookmark,
                      ),
                      IconButton(
                        icon: Icon(
                          Icons.settings,
                          color:
                              effectiveDarkMode ? Colors.white : Colors.black87,
                        ),
                        onPressed: () {
                          setState(() {
                            _showSettingsPanel = true;
                          });
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Bottom Controls
            AnimatedPositioned(
              duration: const Duration(milliseconds: 200),
              bottom: _isControlsVisible ? 0 : -160,
              left: 0,
              right: 0,
              child: FadeTransition(
                opacity: _animation,
                child: Container(
                  padding: EdgeInsets.only(
                    left: 16,
                    right: 16,
                    bottom: 16 + MediaQuery.of(context).padding.bottom,
                    top: 16,
                  ),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      colors: [
                        effectiveDarkMode
                            ? Colors.black.withOpacity(0.9)
                            : Colors.white.withOpacity(0.9),
                        effectiveDarkMode
                            ? Colors.black.withOpacity(0.6)
                            : Colors.white.withOpacity(0.6),
                        effectiveDarkMode
                            ? Colors.black.withOpacity(0.0)
                            : Colors.white.withOpacity(0.0),
                      ],
                    ),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (_totalPages > 0)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color:
                                      effectiveDarkMode
                                          ? Colors.grey[800]
                                          : Colors.grey[200],
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Text(
                                  'Page ${_currentPage + 1} of $_totalPages',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w500,
                                    color:
                                        effectiveDarkMode
                                            ? Colors.white
                                            : Colors.black87,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _buildChapterNavigationButton(
                            icon: Icons.arrow_back_ios_new,
                            isEnabled: _currentChapter > 0,
                            onPressed:
                                () => _changeChapter(_currentChapter - 1),
                            isNext: false,
                          ),
                          Expanded(
                            child: Column(
                              children: [
                                SliderTheme(
                                  data: SliderTheme.of(context).copyWith(
                                    trackHeight: 4,
                                    thumbShape: const RoundSliderThumbShape(
                                      enabledThumbRadius: 6,
                                    ),
                                    overlayShape: const RoundSliderOverlayShape(
                                      overlayRadius: 16,
                                    ),
                                    trackShape:
                                        const RoundedRectSliderTrackShape(),
                                    activeTrackColor: kAccentColor,
                                    inactiveTrackColor:
                                        effectiveDarkMode
                                            ? Colors.grey[700]
                                            : Colors.grey[300],
                                    thumbColor: kAccentColor,
                                    overlayColor: kAccentColor.withOpacity(0.3),
                                  ),
                                  child: Slider(
                                    value: _currentPage.toDouble(),
                                    min: 0,
                                    max: (_totalPages - 1).toDouble().clamp(
                                      0,
                                      double.infinity,
                                    ),
                                    onChanged: (value) {
                                      _pdfViewerController.jumpToPage(
                                        value.toInt() + 1,
                                      );
                                    },
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                  ),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        'Start',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color:
                                              effectiveDarkMode
                                                  ? Colors.white70
                                                  : Colors.black54,
                                        ),
                                      ),
                                      Text(
                                        'End',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color:
                                              effectiveDarkMode
                                                  ? Colors.white70
                                                  : Colors.black54,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          _buildChapterNavigationButton(
                            icon: Icons.arrow_forward_ios,
                            isEnabled:
                                _currentChapter <
                                widget.manga.chapters.length - 1,
                            onPressed:
                                () => _changeChapter(_currentChapter + 1),
                            isNext: true,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Chapter Selector - Only visible when controls are shown
            AnimatedPositioned(
              duration: const Duration(milliseconds: 200),
              top: 80 + MediaQuery.of(context).padding.top,
              left: _isControlsVisible ? 16 : -200,
              child: FadeTransition(
                opacity: _animation,
                child: Container(
                  decoration: BoxDecoration(
                    color: effectiveDarkMode ? Colors.grey[850] : Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 4,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  child: DropdownButton<int>(
                    value: _currentChapter,
                    icon: Icon(
                      Icons.arrow_drop_down,
                      color:
                          effectiveDarkMode ? Colors.white70 : Colors.black87,
                    ),
                    underline: const SizedBox(),
                    dropdownColor:
                        effectiveDarkMode ? Colors.grey[850] : Colors.white,
                    items: List.generate(
                      widget.manga.chapters.length,
                      (index) => DropdownMenuItem(
                        value: index,
                        child: Text(
                          'Chapter ${index + 1}',
                          style: TextStyle(
                            color:
                                effectiveDarkMode
                                    ? Colors.white
                                    : Colors.black87,
                            fontWeight:
                                index == _currentChapter
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                          ),
                        ),
                      ),
                    ),
                    onChanged: (value) {
                      if (value != null) {
                        _changeChapter(value);
                      }
                    },
                  ),
                ),
              ),
            ),

            // Settings Panel
            _buildSettingsPanel(),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _pdfViewerController.dispose();
    _animationController.dispose();
    // Restore system UI
    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.manual,
      overlays: [SystemUiOverlay.top, SystemUiOverlay.bottom],
    );
    super.dispose();
  }
}
