import 'package:flutter/material.dart';
import 'package:manga_app/models/manga.dart';
import 'package:manga_app/models/chapter.dart';
import 'package:manga_app/services/firebase_service.dart';
import 'dart:io';
import 'package:file_picker/file_picker.dart'; // Add this dependency for file picking

class AddMangaScreen extends StatefulWidget {
  const AddMangaScreen({super.key});

  @override
  State<AddMangaScreen> createState() => _AddMangaScreenState();
}

class _AddMangaScreenState extends State<AddMangaScreen> {
  final _firebaseService = FirebaseService();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _authorController = TextEditingController();
  final _genresController = TextEditingController();
  File? _coverImage;
  bool _isCompleted = false;
  bool _isLoading = false;

  Future<void> _pickCoverImage() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.image,
    );
    if (result != null && result.files.single.path != null) {
      setState(() {
        _coverImage = File(result.files.single.path!);
      });
    }
  }

  Future<void> _addManga() async {
    if (_titleController.text.isEmpty || _authorController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Title and Author are required')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final manga = Manga(
        id: '',
        title: _titleController.text,
        description: _descriptionController.text,
        coverUrl: '',
        genres: _genresController.text.split(',').map((e) => e.trim()).toList(),
        author: _authorController.text,
        lastUpdated: DateTime.now(),
        isCompleted: _isCompleted,
      );

      String mangaId = await _firebaseService.addManga(
        manga,
        coverImage: _coverImage,
      );

      // Optionally add an initial chapter (example)
      final chapter = Chapter(
        id: '',
        mangaId: mangaId,
        title: 'Chapter 1',
        number: 1,
        releaseDate: DateTime.now(),
        pdfUrl: '',
      );

      // For chapter PDF, you’d need another file picker; this is a placeholder
      // File? pdfFile = await _pickChapterPdf(); // Implement this if needed
      await _firebaseService.addChapter(
        chapter,
      ); // Add pdfFile parameter if uploading

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Manga added successfully')),
        );
        Navigator.pop(context); // Return to previous screen
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Manga')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Title',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _authorController,
              decoration: const InputDecoration(
                labelText: 'Author',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _genresController,
              decoration: const InputDecoration(
                labelText: 'Genres (comma-separated)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Completed'),
                Switch(
                  value: _isCompleted,
                  onChanged: (value) => setState(() => _isCompleted = value),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _pickCoverImage,
              child: Text(
                _coverImage == null ? 'Pick Cover Image' : 'Image Selected',
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _isLoading ? null : _addManga,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child:
                  _isLoading
                      ? const CircularProgressIndicator()
                      : const Text('Add Manga'),
            ),
          ],
        ),
      ),
    );
  }
}
