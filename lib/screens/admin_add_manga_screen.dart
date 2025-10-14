// lib/screens/admin_add_manga_screen.dart
import 'package:flutter/material.dart';
import 'package:manga_app/models/manga.dart';
import 'package:manga_app/models/chapter.dart';
import 'package:manga_app/services/firebase_service.dart';
import 'package:manga_app/widgets/loading_overlay.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Import for Timestamp

class AdminAddMangaScreen extends StatefulWidget {
  const AdminAddMangaScreen({super.key});

  @override
  State<AdminAddMangaScreen> createState() => _AdminAddMangaScreenState();
}

class _AdminAddMangaScreenState extends State<AdminAddMangaScreen>
    with SingleTickerProviderStateMixin {
  // Tab Controller
  late TabController _tabController;

  // Form Keys
  final _mangaFormKey = GlobalKey<FormState>();
  final _chapterFormKey = GlobalKey<FormState>();

  // Manga Form Controllers
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _coverUrlController = TextEditingController();
  final _authorController = TextEditingController();
  final _genresController = TextEditingController();

  // Chapter Form Controllers
  final _chapterTitleController = TextEditingController();
  final _chapterNumberController = TextEditingController();
  final _chapterPdfUrlController = TextEditingController();

  // Service and State Variables
  final FirebaseService _firebaseService = FirebaseService();
  bool _isCompleted = false;
  bool _isLoading = false;
  Manga? _selectedManga; // Pre-selected manga for chapter addition
  List<Manga> _mangaList = [];
  List<String> _errors = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadMangaList();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _titleController.dispose();
    _descriptionController.dispose();
    _coverUrlController.dispose();
    _authorController.dispose();
    _genresController.dispose();
    _chapterTitleController.dispose();
    _chapterNumberController.dispose();
    _chapterPdfUrlController.dispose();
    super.dispose();
  }

  Future<void> _loadMangaList() async {
    setState(() {
      _isLoading = true;
      _errors = [];
    });

    try {
      _mangaList = await _firebaseService.getAllManga();
      if (_mangaList.isEmpty) {
        _errors.add('No manga found. Add your first manga!');
      }
    } catch (e) {
      _errors.add('Failed to load manga: $e');
      _showErrorSnackbar('Error loading manga: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showErrorSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showSuccessSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _addManga() async {
    if (!_mangaFormKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errors = [];
    });

    try {
      final manga = Manga(
        id: '',
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        coverUrl: _coverUrlController.text.trim(),
        genres:
            _genresController.text.isEmpty
                ? []
                : _genresController.text
                    .split(',')
                    .map((e) => e.trim())
                    .toList(),
        author: _authorController.text.trim(),
        lastUpdated: Timestamp.now().toDate(),
        isCompleted: _isCompleted,
      );

      final docRef = await _firebaseService.addManga(manga);
      final newManga = Manga.fromMap(manga.toMap(), docRef.id);

      setState(() {
        _selectedManga = newManga; // Auto-select the new manga
        _mangaList.add(newManga);
        _resetMangaForm();
      });

      _showSuccessSnackbar('${newManga.title} added successfully');

      // Switch to chapter tab with the new manga pre-selected
      _tabController.animateTo(1);
    } catch (e) {
      _errors.add('Failed to add manga: $e');
      _showErrorSnackbar('Error adding manga: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _resetMangaForm() {
    _titleController.clear();
    _descriptionController.clear();
    _coverUrlController.clear();
    _authorController.clear();
    _genresController.clear();
    _isCompleted = false;
  }

  Future<void> _addChapter() async {
    if (_selectedManga == null) {
      _showErrorSnackbar('Please select a manga first');
      _tabController.animateTo(0); // Switch to Add Manga tab if no selection
      return;
    }

    if (!_chapterFormKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errors = [];
    });

    try {
      final chapterNumber = int.tryParse(_chapterNumberController.text);
      if (chapterNumber == null) {
        throw 'Invalid chapter number';
      }

      final chapter = Chapter(
        id: '',
        mangaId: _selectedManga!.id,
        title: _chapterTitleController.text.trim(),
        number: chapterNumber,
        releaseDate: Timestamp.now().toDate(),
        pdfUrl: _chapterPdfUrlController.text.trim(),
      );

      await _firebaseService.addChapter(chapter);

      _resetChapterForm();
      _showSuccessSnackbar(
        'Chapter ${chapter.number} added to ${_selectedManga!.title}',
      );
    } catch (e) {
      _errors.add('Failed to add chapter: $e');
      _showErrorSnackbar('Error adding chapter: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _resetChapterForm() {
    _chapterTitleController.clear();
    _chapterNumberController.clear();
    _chapterPdfUrlController.clear();
  }

  Future<void> _deleteManga() async {
    if (_selectedManga == null) {
      _showErrorSnackbar('Please select a manga to delete');
      return;
    }

    // Ask for confirmation
    final bool confirmDelete =
        await showDialog(
          context: context,
          builder:
              (context) => AlertDialog(
                title: const Text('Confirm Delete'),
                content: Text(
                  'Are you sure you want to delete "${_selectedManga!.title}"? This will also delete all chapters and cannot be undone.',
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context, false),
                    child: const Text('Cancel'),
                  ),
                  TextButton(
                    onPressed: () => Navigator.pop(context, true),
                    style: TextButton.styleFrom(foregroundColor: Colors.red),
                    child: const Text('Delete'),
                  ),
                ],
              ),
        ) ??
        false;

    if (!confirmDelete) return;

    setState(() {
      _isLoading = true;
      _errors = [];
    });

    try {
      await _firebaseService.deleteManga(_selectedManga!.id);

      setState(() {
        _mangaList.removeWhere((manga) => manga.id == _selectedManga!.id);
        _selectedManga = null; // Clear selection after deletion
      });

      _showSuccessSnackbar('Manga deleted successfully');
    } catch (e) {
      _errors.add('Failed to delete manga: $e');
      _showErrorSnackbar('Error deleting manga: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Widget _buildMangaDropdown() {
    return DropdownButtonFormField<Manga>(
      value: _selectedManga,
      hint: const Text('Select a manga'),
      isExpanded: true,
      decoration: const InputDecoration(
        labelText: 'Manga',
        border: OutlineInputBorder(),
      ),
      items:
          _mangaList.map((manga) {
            return DropdownMenuItem<Manga>(
              value: manga,
              child: Text(manga.title, overflow: TextOverflow.ellipsis),
            );
          }).toList(),
      onChanged: (value) => setState(() => _selectedManga = value),
    );
  }

  Widget _buildAddMangaForm() {
    return Form(
      key: _mangaFormKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextFormField(
            controller: _titleController,
            decoration: const InputDecoration(
              labelText: 'Manga Title',
              border: OutlineInputBorder(),
            ),
            textCapitalization: TextCapitalization.words,
            validator:
                (value) =>
                    value?.trim().isEmpty ?? true ? 'Title is required' : null,
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _authorController,
            decoration: const InputDecoration(
              labelText: 'Author',
              border: OutlineInputBorder(),
            ),
            textCapitalization: TextCapitalization.words,
            validator:
                (value) =>
                    value?.trim().isEmpty ?? true ? 'Author is required' : null,
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _descriptionController,
            decoration: const InputDecoration(
              labelText: 'Description',
              border: OutlineInputBorder(),
              alignLabelWithHint: true,
            ),
            maxLines: 3,
            textCapitalization: TextCapitalization.sentences,
            validator:
                (value) =>
                    value?.trim().isEmpty ?? true
                        ? 'Description is required'
                        : null,
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _coverUrlController,
            decoration: const InputDecoration(
              labelText: 'Cover Image URL',
              border: OutlineInputBorder(),
              hintText: 'https://example.com/image.jpg',
            ),
            keyboardType: TextInputType.url,
            validator: (value) {
              if (value?.trim().isEmpty ?? true) {
                return 'Cover URL is required';
              }
              if (!Uri.tryParse(value!)!.isAbsolute) {
                return 'Please enter a valid URL';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _genresController,
            decoration: const InputDecoration(
              labelText: 'Genres (comma-separated)',
              border: OutlineInputBorder(),
              hintText: 'Action, Adventure, Fantasy',
            ),
          ),
          const SizedBox(height: 8),
          SwitchListTile(
            title: const Text('Is the series completed?'),
            value: _isCompleted,
            onChanged: (value) => setState(() => _isCompleted = value),
            contentPadding: EdgeInsets.zero,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _isLoading ? null : _addManga,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
            child: const Text('Add Manga', style: TextStyle(fontSize: 16)),
          ),
        ],
      ),
    );
  }

  Widget _buildAddChapterForm() {
    return Form(
      key: _chapterFormKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildMangaDropdown(),
          const SizedBox(height: 16),
          if (_selectedManga != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(
                'Adding chapters to: ${_selectedManga!.title}',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          TextFormField(
            controller: _chapterTitleController,
            decoration: const InputDecoration(
              labelText: 'Chapter Title',
              border: OutlineInputBorder(),
              hintText: 'New Beginning',
            ),
            textCapitalization: TextCapitalization.sentences,
            validator:
                (value) =>
                    value?.trim().isEmpty ?? true
                        ? 'Chapter title is required'
                        : null,
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _chapterNumberController,
            decoration: const InputDecoration(
              labelText: 'Chapter Number',
              border: OutlineInputBorder(),
              hintText: '1',
            ),
            keyboardType: TextInputType.number,
            validator: (value) {
              if (value?.trim().isEmpty ?? true) {
                return 'Chapter number is required';
              }
              if (int.tryParse(value!) == null) {
                return 'Please enter a valid number';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _chapterPdfUrlController,
            decoration: const InputDecoration(
              labelText: 'PDF URL (Google Drive)',
              border: OutlineInputBorder(),
              hintText: 'https://drive.google.com/uc?export=download&id=...',
            ),
            keyboardType: TextInputType.url,
            validator: (value) {
              if (value?.trim().isEmpty ?? true) {
                return 'PDF URL is required';
              }
              if (!Uri.tryParse(value!)!.isAbsolute) {
                return 'Please enter a valid URL';
              }
              return null;
            },
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _isLoading ? null : _addChapter,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
            child: const Text('Add Chapter', style: TextStyle(fontSize: 16)),
          ),
        ],
      ),
    );
  }

  Widget _buildDeleteMangaForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildMangaDropdown(),
        const SizedBox(height: 24),
        ElevatedButton(
          onPressed: _isLoading ? null : _deleteManga,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red,
            padding: const EdgeInsets.symmetric(vertical: 12),
          ),
          child: const Text('Delete Manga', style: TextStyle(fontSize: 16)),
        ),
        const SizedBox(height: 16),
        const Text(
          'Warning: Deleting a manga will also remove all associated chapters. This action cannot be undone.',
          style: TextStyle(color: Colors.red, fontStyle: FontStyle.italic),
        ),
      ],
    );
  }

  Widget _buildErrorWidget() {
    if (_errors.isEmpty) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        border: Border.all(color: Colors.red.shade200),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Errors:',
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red),
          ),
          const SizedBox(height: 4),
          ..._errors
              .map(
                (error) => Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('• ', style: TextStyle(color: Colors.red)),
                      Expanded(
                        child: Text(
                          error,
                          style: const TextStyle(color: Colors.red),
                        ),
                      ),
                    ],
                  ),
                ),
              )
              .toList(),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Manga Management'),
          bottom: TabBar(
            controller: _tabController,
            tabs: const [
              Tab(text: 'Add Manga'),
              Tab(text: 'Add Chapter'),
              Tab(text: 'Delete Manga'),
            ],
          ),
        ),
        body: LoadingOverlay(
          isLoading: _isLoading,
          child: TabBarView(
            controller: _tabController,
            children: [
              // Add Manga Tab
              SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [_buildErrorWidget(), _buildAddMangaForm()],
                ),
              ),

              // Add Chapter Tab
              SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [_buildErrorWidget(), _buildAddChapterForm()],
                ),
              ),

              // Delete Manga Tab
              SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [_buildErrorWidget(), _buildDeleteMangaForm()],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
