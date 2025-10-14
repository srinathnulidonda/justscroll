//lib/screens/reader_screen.dart

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:manga_app/models/chapter.dart';
import 'package:manga_app/services/firebase_service.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

class ReaderScreen extends StatefulWidget {
  final Chapter chapter;

  const ReaderScreen({super.key, required this.chapter});

  @override
  State<ReaderScreen> createState() => _ReaderScreenState();
}

class _ReaderScreenState extends State<ReaderScreen> {
  final FirebaseService _firebaseService = FirebaseService();
  final PdfViewerController _pdfViewerController = PdfViewerController();
  bool _isFullScreen = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _updateLastRead();
  }

  Future<void> _updateLastRead() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    await _firebaseService.updateLastReadChapter(
      user.uid,
      widget.chapter.mangaId,
      widget.chapter.number,
    );
  }

  void _toggleFullScreen() => setState(() => _isFullScreen = !_isFullScreen);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:
          _isFullScreen
              ? null
              : AppBar(
                title: Text(
                  'Chapter ${widget.chapter.number}: ${widget.chapter.title}',
                ),
                actions: [
                  IconButton(
                    icon: const Icon(Icons.fullscreen),
                    onPressed: _toggleFullScreen,
                  ),
                ],
              ),
      body: GestureDetector(
        onHorizontalDragEnd: (details) {
          if (details.primaryVelocity! > 0) {
            _pdfViewerController.previousPage();
          } else if (details.primaryVelocity! < 0) {
            _pdfViewerController.nextPage();
          }
        },
        child: Stack(
          children: [
            SfPdfViewer.network(
              widget.chapter.pdfUrl,
              controller: _pdfViewerController,
              onDocumentLoaded: (details) => setState(() => _isLoading = false),
              onDocumentLoadFailed: (details) {
                setState(() => _isLoading = false);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Error loading PDF: ${details.error}'),
                  ),
                );
              },
            ),
            if (_isLoading) const Center(child: CircularProgressIndicator()),
            if (_isFullScreen) ...[
              Positioned(
                top: 0,
                right: 0,
                child: SafeArea(
                  child: IconButton(
                    icon: const Icon(
                      Icons.fullscreen_exit,
                      color: Colors.white,
                      shadows: [Shadow(blurRadius: 5, color: Colors.black)],
                    ),
                    onPressed: _toggleFullScreen,
                  ),
                ),
              ),
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: SafeArea(
                  child: Container(
                    color: Colors.black54,
                    padding: const EdgeInsets.all(8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        IconButton(
                          icon: const Icon(
                            Icons.arrow_back,
                            color: Colors.white,
                          ),
                          onPressed: () => _pdfViewerController.previousPage(),
                        ),
                        Text(
                          'Page ${_pdfViewerController.pageNumber}/${_pdfViewerController.pageCount}',
                          style: const TextStyle(color: Colors.white),
                        ),
                        IconButton(
                          icon: const Icon(
                            Icons.arrow_forward,
                            color: Colors.white,
                          ),
                          onPressed: () => _pdfViewerController.nextPage(),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
