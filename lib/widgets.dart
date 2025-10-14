import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'constants.dart';

class MangaCard extends StatelessWidget {
  final Manga manga;
  final bool isFeatured;

  const MangaCard({super.key, required this.manga, this.isFeatured = false});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<MangaProvider>(context);
    return GestureDetector(
      onTap:
          () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => MangaDetailsScreen(manga: manga),
            ),
          ),
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 8),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Stack(
            children: [
              CachedNetworkImage(
                imageUrl: manga.coverImage,
                fit: BoxFit.cover,
                width: isFeatured ? null : 150,
                height: double.infinity,
                placeholder:
                    (context, url) => Container(color: Colors.grey[800]),
                errorWidget: (context, url, error) => const Icon(Icons.error),
              ),
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.transparent, Colors.black.withOpacity(0.7)],
                  ),
                ),
              ),
              Positioned(
                top: 8,
                right: 8,
                child: IconButton(
                  icon: Icon(
                    provider.isFavorite(manga.id)
                        ? Icons.favorite
                        : Icons.favorite_border,
                    color: Colors.redAccent,
                  ),
                  onPressed: () => provider.toggleFavorite(manga.id),
                ),
              ),
              Positioned(
                bottom: 8,
                left: 8,
                right: 8,
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
                    Row(
                      children: [
                        const Icon(Icons.star, color: kAccentColor, size: 14),
                        const SizedBox(width: 4),
                        Text(
                          manga.rating.toStringAsFixed(1),
                          style: const TextStyle(color: Colors.white70),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              if (manga.hasNewChapter)
                Positioned(
                  top: 8,
                  left: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.redAccent,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Text(
                      'NEW',
                      style: TextStyle(color: Colors.white, fontSize: 10),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class UpdateCard extends StatelessWidget {
  final Manga manga;

  const UpdateCard({super.key, required this.manga});

  @override
  Widget build(BuildContext context) {
    final formattedDate =
        manga.lastUpdated != null
            ? DateFormat('MMM d').format(manga.lastUpdated!.toDate())
            : 'Unknown';
    return Container(
      width: 140,
      margin: const EdgeInsets.only(right: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AspectRatio(
            aspectRatio: 0.7,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: CachedNetworkImage(
                imageUrl: manga.coverImage,
                fit: BoxFit.cover,
                placeholder:
                    (context, url) => Container(color: Colors.grey[800]),
                errorWidget: (context, url, error) => const Icon(Icons.error),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            manga.title,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            formattedDate,
            style: const TextStyle(color: Colors.white70, fontSize: 12),
          ),
        ],
      ),
    );
  }
}

class PopularMangaCard extends StatelessWidget {
  final Manga manga;
  final int rank;

  const PopularMangaCard({super.key, required this.manga, required this.rank});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(
        color: kSurfaceColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 100,
            decoration: BoxDecoration(
              color: rank <= 3 ? Colors.redAccent : kPrimaryColor,
              borderRadius: const BorderRadius.horizontal(
                left: Radius.circular(12),
              ),
            ),
            child: Center(
              child: Text(
                '#$rank',
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ),
          CachedNetworkImage(
            imageUrl: manga.coverImage,
            width: 70,
            height: 100,
            fit: BoxFit.cover,
            placeholder: (context, url) => Container(color: Colors.grey[800]),
            errorWidget: (context, url, error) => const Icon(Icons.error),
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
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    manga.author,
                    style: const TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.star, color: kAccentColor, size: 14),
                      const SizedBox(width: 4),
                      Text(
                        manga.rating.toStringAsFixed(1),
                        style: const TextStyle(color: Colors.white70),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class RecommendedCard extends StatelessWidget {
  final Manga manga;

  const RecommendedCard({super.key, required this.manga});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 160,
      margin: const EdgeInsets.only(right: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AspectRatio(
            aspectRatio: 0.7,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: CachedNetworkImage(
                imageUrl: manga.coverImage,
                fit: BoxFit.cover,
                placeholder:
                    (context, url) => Container(color: Colors.grey[800]),
                errorWidget: (context, url, error) => const Icon(Icons.error),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            manga.title,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            '${manga.totalChapters} Chapters',
            style: const TextStyle(color: Colors.white70),
          ),
        ],
      ),
    );
  }
}

class SearchSheet extends StatelessWidget {
  const SearchSheet({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = TextEditingController();
    const popularSearches = [
      'Action',
      'Romance',
      'Fantasy',
      'Shonen',
      'Isekai',
      'Adventure',
    ];

    return Container(
      decoration: const BoxDecoration(
        color: kSurfaceColor,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        top: 16,
        left: 16,
        right: 16,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(width: 40, height: 4, color: Colors.grey[600]),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: controller,
            decoration: InputDecoration(
              hintText: 'Search manga...',
              prefixIcon: const Icon(Icons.search, color: Colors.white70),
              filled: true,
              fillColor: Colors.white.withOpacity(0.1),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
            style: const TextStyle(color: Colors.white),
            onSubmitted: (value) => _performSearch(context, value),
          ),
          const SizedBox(height: 16),
          const Text(
            'Popular Searches',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children:
                popularSearches
                    .map(
                      (search) => ActionChip(
                        label: Text(search),
                        backgroundColor: kPrimaryColor.withOpacity(0.2),
                        labelStyle: const TextStyle(color: Colors.white),
                        onPressed: () => _performSearch(context, search),
                      ),
                    )
                    .toList(),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  void _performSearch(BuildContext context, String query) {
    Navigator.pop(context);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SearchResultsScreen(query: query),
      ),
    );
  }
}

class SearchResultsScreen extends StatelessWidget {
  final String query;

  const SearchResultsScreen({super.key, required this.query});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Search: $query'),
        backgroundColor: kSurfaceColor,
      ),
      body: FutureBuilder<QuerySnapshot>(
        future:
            FirebaseFirestore.instance
                .collection('manga')
                .where('title', isGreaterThanOrEqualTo: query)
                .where('title', isLessThanOrEqualTo: '$query\uf8ff')
                .get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No results found'));
          }
          final results = snapshot.data!.docs.map(Manga.fromFirestore).toList();
          return ListView.builder(
            itemCount: results.length,
            itemBuilder: (context, index) => MangaCard(manga: results[index]),
          );
        },
      ),
    );
  }
}

class MangaDetailsScreen extends StatelessWidget {
  final Manga manga;

  const MangaDetailsScreen({super.key, required this.manga});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<MangaProvider>(context);
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  CachedNetworkImage(
                    imageUrl: manga.coverImage,
                    fit: BoxFit.cover,
                    placeholder:
                        (context, url) => Container(color: Colors.grey[800]),
                    errorWidget:
                        (context, url, error) => const Icon(Icons.error),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          kBackgroundColor.withOpacity(0.9),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              IconButton(
                icon: Icon(
                  provider.isFavorite(manga.id)
                      ? Icons.favorite
                      : Icons.favorite_border,
                ),
                onPressed: () => provider.toggleFavorite(manga.id),
              ),
            ],
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    manga.title,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'by ${manga.author}',
                    style: const TextStyle(color: Colors.white70, fontSize: 16),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      const Icon(Icons.star, color: kAccentColor, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        manga.rating.toStringAsFixed(1),
                        style: const TextStyle(color: Colors.white),
                      ),
                      const SizedBox(width: 16),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color:
                              manga.status == 'Ongoing'
                                  ? Colors.green
                                  : Colors.red,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          manga.status,
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children:
                        manga.genres
                            .map(
                              (genre) => Chip(
                                label: Text(genre),
                                backgroundColor: kPrimaryColor.withOpacity(0.2),
                                labelStyle: const TextStyle(
                                  color: Colors.white,
                                ),
                              ),
                            )
                            .toList(),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    manga.description,
                    style: const TextStyle(color: Colors.white70),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () {
                      provider.toggleReading(manga.id);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ReadingScreen(manga: manga),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      provider.isReading(manga.id)
                          ? 'Continue Reading'
                          : 'Start Reading',
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ReadingScreen extends StatelessWidget {
  final Manga manga;

  const ReadingScreen({super.key, required this.manga});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(manga.title), backgroundColor: kSurfaceColor),
      body: const Center(
        child: Text(
          'Reading View - Coming Soon',
          style: TextStyle(color: Colors.white),
        ),
      ),
    );
  }
}

class DiscoverTab extends StatelessWidget {
  const DiscoverTab({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Explore Genres',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children:
                [
                      'Action',
                      'Adventure',
                      'Romance',
                      'Fantasy',
                      'Horror',
                      'Mystery',
                    ]
                    .map(
                      (genre) => ActionChip(
                        label: Text(genre),
                        backgroundColor: kPrimaryColor.withOpacity(0.2),
                        labelStyle: const TextStyle(color: Colors.white),
                        onPressed:
                            () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (context) =>
                                        SearchResultsScreen(query: genre),
                              ),
                            ),
                      ),
                    )
                    .toList(),
          ),
        ],
      ),
    );
  }
}

class LibraryTab extends StatelessWidget {
  const LibraryTab({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<MangaProvider>(context);
    final readingList = provider.readingList;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Your Library',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          if (readingList.isEmpty)
            const Center(
              child: Text(
                'Add manga to your library!',
                style: TextStyle(color: Colors.white70),
              ),
            )
          else
            FutureBuilder<QuerySnapshot>(
              future:
                  FirebaseFirestore.instance
                      .collection('manga')
                      .where(
                        FieldPath.documentId,
                        whereIn: readingList.toList(),
                      )
                      .get(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData) {
                  return const Center(child: Text('Error loading library'));
                }
                final mangaList =
                    snapshot.data!.docs.map(Manga.fromFirestore).toList();
                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: mangaList.length,
                  itemBuilder: (context, index) {
                    final manga = mangaList[index];
                    return ListTile(
                      leading: CachedNetworkImage(
                        imageUrl: manga.coverImage,
                        width: 50,
                        height: 70,
                        fit: BoxFit.cover,
                        placeholder:
                            (context, url) =>
                                Container(color: Colors.grey[800]),
                        errorWidget:
                            (context, url, error) => const Icon(Icons.error),
                      ),
                      title: Text(
                        manga.title,
                        style: const TextStyle(color: Colors.white),
                      ),
                      subtitle: Text(
                        'Chapter ${provider.getProgress(manga.id)} / ${manga.totalChapters}',
                        style: const TextStyle(color: Colors.white70),
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete, color: Colors.redAccent),
                        onPressed: () => provider.toggleReading(manga.id),
                      ),
                      onTap:
                          () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ReadingScreen(manga: manga),
                            ),
                          ),
                    );
                  },
                );
              },
            ),
        ],
      ),
    );
  }
}

class ProfileTab extends StatelessWidget {
  const ProfileTab({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<MangaProvider>(context);
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Your Profile',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          Card(
            color: kSurfaceColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  const CircleAvatar(
                    radius: 40,
                    backgroundColor: kPrimaryColor,
                    child: Icon(Icons.person, size: 40, color: Colors.white),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Manga Enthusiast',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Reading: ${provider.readingList.length} titles',
                    style: const TextStyle(color: Colors.white70),
                  ),
                  Text(
                    'Favorites: ${provider.favorites.length} titles',
                    style: const TextStyle(color: Colors.white70),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
