// lib/screens/admin_screen.dart
import 'package:flutter/material.dart';
import 'package:manga_app/models/manga.dart';
import 'package:manga_app/models/chapter.dart';
import 'package:manga_app/services/firebase_service.dart';

class AdminScreen extends StatefulWidget {
  const AdminScreen({super.key});

  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  final _firebaseService = FirebaseService();
  final _mangaTitleController = TextEditingController();
  final _mangaDescController = TextEditingController();
  final _mangaCoverUrlController = TextEditingController();
  final _mangaAuthorController = TextEditingController();
  final _chapterTitleController = TextEditingController();
  final _chapterNumberController = TextEditingController();
  final _chapterPdfUrlController = TextEditingController();
  String? _selectedMangaId;
  List<Manga> _mangas = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchMangas();
  }

  Future<void> _fetchMangas() async {
    setState(() => _isLoading = true);
    _mangas = await _firebaseService.getAllManga();
    setState(() => _isLoading = false);
  }

  Future<void> _addManga() async {
    if (_mangaTitleController.text.isEmpty ||
        _mangaCoverUrlController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Title and Cover URL are required')),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      final manga = Manga(
        id: '', // Firestore will generate this
        title: _mangaTitleController.text,
        description: _mangaDescController.text,
        coverUrl: _mangaCoverUrlController.text,
        genres: [], // Add genre input if needed
        author: _mangaAuthorController.text,
        lastUpdated: DateTime.now(),
        isCompleted: false,
      );
      await _firebaseService.addManga(manga);
      _mangaTitleController.clear();
      _mangaDescController.clear();
      _mangaCoverUrlController.clear();
      _mangaAuthorController.clear();
      await _fetchMangas();
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Manga added successfully')));
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _addChapter() async {
    if (_selectedMangaId == null ||
        _chapterTitleController.text.isEmpty ||
        _chapterNumberController.text.isEmpty ||
        _chapterPdfUrlController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('All chapter fields and manga selection are required'),
        ),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      final chapter = Chapter(
        id: '', // Firestore will generate this
        mangaId: _selectedMangaId!,
        title: _chapterTitleController.text,
        number: int.parse(_chapterNumberController.text),
        releaseDate: DateTime.now(),
        pdfUrl: _chapterPdfUrlController.text,
      );
      await _firebaseService.addChapter(chapter);
      _chapterTitleController.clear();
      _chapterNumberController.clear();
      _chapterPdfUrlController.clear();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Chapter added successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Admin Panel')),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Add New Manga',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextField(
                      controller: _mangaTitleController,
                      decoration: const InputDecoration(labelText: 'Title'),
                    ),
                    TextField(
                      controller: _mangaDescController,
                      decoration: const InputDecoration(
                        labelText: 'Description',
                      ),
                    ),
                    TextField(
                      controller: _mangaCoverUrlController,
                      decoration: const InputDecoration(labelText: 'Cover URL'),
                    ),
                    TextField(
                      controller: _mangaAuthorController,
                      decoration: const InputDecoration(labelText: 'Author'),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _addManga,
                      child: const Text('Add Manga'),
                    ),
                    const SizedBox(height: 32),
                    const Text(
                      'Add New Chapter',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    DropdownButton<String>(
                      value: _selectedMangaId,
                      hint: const Text('Select Manga'),
                      items:
                          _mangas
                              .map(
                                (manga) => DropdownMenuItem(
                                  value: manga.id,
                                  child: Text(manga.title),
                                ),
                              )
                              .toList(),
                      onChanged:
                          (value) => setState(() => _selectedMangaId = value),
                    ),
                    TextField(
                      controller: _chapterTitleController,
                      decoration: const InputDecoration(
                        labelText: 'Chapter Title',
                      ),
                    ),
                    TextField(
                      controller: _chapterNumberController,
                      decoration: const InputDecoration(
                        labelText: 'Chapter Number',
                      ),
                      keyboardType: TextInputType.number,
                    ),
                    TextField(
                      controller: _chapterPdfUrlController,
                      decoration: const InputDecoration(
                        labelText: 'PDF URL (Google Drive)',
                      ),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _addChapter,
                      child: const Text('Add Chapter'),
                    ),
                  ],
                ),
              ),
    );
  }
}
