import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cached_network_image/cached_network_image.dart'; // Added import
import 'manga_provider.dart';
import 'manga_detail_screen.dart';

class SearchSheet extends StatefulWidget {
  const SearchSheet({super.key});

  @override
  State<SearchSheet> createState() => _SearchSheetState();
}

class _SearchSheetState extends State<SearchSheet> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  List<String> _recentSearches = [];
  List<Map<String, String>> _suggestions = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadRecentSearches();
    _focusNode.requestFocus();
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _loadRecentSearches() {
    if (mounted) {
      setState(() {
        _recentSearches = [
          'One Piece',
          'Attack on Titan',
          'Naruto',
          'Jujutsu Kaisen',
        ];
      });
    }
  }

  void _search(String query) {
    if (query.trim().isEmpty || !mounted) return;

    Navigator.pop(context);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SearchResultsScreen(query: query),
      ),
    );
  }

  void _updateSuggestions(String text) {
    if (!mounted) return;

    setState(() => _isLoading = true);

    Future.delayed(const Duration(milliseconds: 500), () {
      if (!mounted) return;
      final suggestions = [
        {'title': '$text Academy', 'genre': 'Action'},
        {'title': 'The $text Chronicles', 'genre': 'Fantasy'},
        {'title': '$text Hunter', 'genre': 'Adventure'},
        {'title': 'My $text Academia', 'genre': 'School'},
      ];

      setState(() {
        _suggestions = suggestions;
        _isLoading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.9,
      decoration: const BoxDecoration(
        color: kSurfaceColor,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          Container(
            width: 40,
            height: 5,
            margin: const EdgeInsets.symmetric(vertical: 10),
            decoration: BoxDecoration(
              color: Colors.grey[600],
              borderRadius: BorderRadius.circular(5),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: TextField(
              controller: _controller,
              focusNode: _focusNode,
              onChanged: _updateSuggestions,
              onSubmitted: _search,
              decoration: InputDecoration(
                hintText: 'Search for manga, author, or genre...',
                hintStyle: const TextStyle(color: Colors.white60),
                prefixIcon: const Icon(Icons.search, color: Colors.white70),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.clear, color: Colors.white70),
                  onPressed: () => _controller.clear(),
                ),
                filled: true,
                fillColor: kCardColor,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16),
              ),
              style: const TextStyle(color: Colors.white),
            ),
          ),
          Expanded(
            child:
                _controller.text.isEmpty
                    ? _buildRecentSearches()
                    : _buildSuggestions(),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentSearches() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.all(16),
          child: Text(
            'Recent Searches',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: _recentSearches.length,
            itemBuilder: (context, index) {
              return ListTile(
                leading: const Icon(Icons.history, color: Colors.white70),
                title: Text(
                  _recentSearches[index],
                  style: const TextStyle(color: Colors.white),
                ),
                trailing: const Icon(
                  Icons.arrow_forward_ios,
                  color: Colors.white70,
                  size: 16,
                ),
                onTap: () => _search(_recentSearches[index]),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSuggestions() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(kAccentColor),
        ),
      );
    }

    return ListView.builder(
      itemCount: _suggestions.length,
      itemBuilder: (context, index) {
        final suggestion = _suggestions[index];
        return ListTile(
          title: Text(
            suggestion['title']!,
            style: const TextStyle(color: Colors.white),
          ),
          subtitle: Text(
            suggestion['genre']!,
            style: const TextStyle(color: Colors.white70),
          ),
          trailing: const Icon(
            Icons.arrow_forward_ios,
            color: Colors.white70,
            size: 16,
          ),
          onTap: () => _search(suggestion['title']!),
        );
      },
    );
  }
}

class SearchResultsScreen extends StatefulWidget {
  final String query;

  const SearchResultsScreen({super.key, required this.query});

  @override
  State<SearchResultsScreen> createState() => _SearchResultsScreenState();
}

class _SearchResultsScreenState extends State<SearchResultsScreen> {
  late Future<List<Manga>> _searchResults;

  @override
  void initState() {
    super.initState();
    _searchResults = _fetchSearchResults(widget.query);
  }

  Future<List<Manga>> _fetchSearchResults(String query) async {
    try {
      await Future.delayed(const Duration(seconds: 1));
      final firestore = FirebaseFirestore.instance;
      final results =
          await firestore
              .collection('manga')
              .where('title', isGreaterThanOrEqualTo: query)
              .where('title', isLessThanOrEqualTo: '$query\uf8ff')
              .get();

      if (results.docs.isEmpty) {
        final fallbackResults =
            await firestore.collection('manga').limit(10).get();
        return fallbackResults.docs.map(Manga.fromFirestore).toList();
      }

      return results.docs.map(Manga.fromFirestore).toList();
    } catch (e) {
      debugPrint('Error searching: $e');
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Results for "${widget.query}"'),
        backgroundColor: kSurfaceColor,
      ),
      body: FutureBuilder<List<Manga>>(
        future: _searchResults,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(kAccentColor),
              ),
            );
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.search_off,
                    size: 64,
                    color: Colors.white60,
                  ), // Fixed: Changed 'search SALES' to 'search_off'
                  const SizedBox(height: 16),
                  Text(
                    'No results found for "${widget.query}"',
                    style: const TextStyle(color: Colors.white, fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    style: TextButton.styleFrom(foregroundColor: kAccentColor),
                    child: const Text('Try another search'),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              final manga = snapshot.data![index];
              return MangaListItem(manga: manga);
            },
          );
        },
      ),
    );
  }
}

class MangaListItem extends StatelessWidget {
  final Manga manga;

  const MangaListItem({super.key, required this.manga});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => MangaDetailScreen(manga: manga),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: kCardColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.horizontal(
                left: Radius.circular(12),
              ),
              child: CachedNetworkImage(
                // Fixed: Already imported at the top
                imageUrl: manga.coverImage,
                width: 100,
                height: 150,
                fit: BoxFit.cover,
                placeholder:
                    (context, url) => Container(color: Colors.grey[800]),
                errorWidget:
                    (context, url, error) => Container(
                      color: Colors.grey[800],
                      child: const Icon(Icons.error, color: Colors.white),
                    ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      manga.title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'By ${manga.author}',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.star, color: kAccentColor, size: 16),
                        const SizedBox(width: 4),
                        Text(
                          manga.rating.toString(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(width: 16),
                        const Icon(
                          Icons.menu_book,
                          color: Colors.white70,
                          size: 16,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${manga.totalChapters} chapters',
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children:
                          manga.genres.take(3).map((genre) {
                            return Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: kPrimaryColor.withOpacity(0.3),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                genre,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                ),
                              ),
                            );
                          }).toList(),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
