import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:provider/provider.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import '../constants.dart';
import '../models/manga.dart';
import '../providers/manga_provider.dart';
import '../widgets/chapter_list_item.dart';
import '../widgets/related_manga_card.dart';
import 'reading_screen.dart';

class MangaDetailsScreen extends StatefulWidget {
  final Manga manga;

  const MangaDetailsScreen({super.key, required this.manga});

  @override
  State<MangaDetailsScreen> createState() => _MangaDetailsScreenState();
}

class _MangaDetailsScreenState extends State<MangaDetailsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isDescriptionExpanded = false;
  final ScrollController _scrollController = ScrollController();
  bool _showTitle = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _scrollController.addListener(_scrollListener);
  }

  void _scrollListener() {
    if (_scrollController.offset > 200 && !_showTitle) {
      setState(() {
        _showTitle = true;
      });
    } else if (_scrollController.offset <= 200 && _showTitle) {
      setState(() {
        _showTitle = false;
      });
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<MangaProvider>(context);
    final isInLibrary = provider.isInLibrary(widget.manga.id);
    final isReading = provider.isReading(widget.manga.id);
    final isFavorite = provider.isFavorite(widget.manga.id);
    final theme = Theme.of(context);

    return Scaffold(
      body: CustomScrollView(
        controller: _scrollController,
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverAppBar(
            expandedHeight: 350,
            pinned: true,
            backgroundColor: kPrimaryColor,
            elevation: 0,
            title: AnimatedOpacity(
              opacity: _showTitle ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 200),
              child: Text(
                widget.manga.title,
                style: const TextStyle(fontWeight: FontWeight.bold),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Hero(
                tag: 'manga_cover_${widget.manga.id}',
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    CachedNetworkImage(
                      imageUrl: widget.manga.coverImage,
                      fit: BoxFit.cover,
                      placeholder:
                          (_, __) => Container(
                            color: Colors.grey[800],
                            child: const Center(
                              child: CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.white70,
                                ),
                              ),
                            ),
                          ),
                      errorWidget:
                          (_, __, ___) => Container(
                            color: Colors.grey[800],
                            child: const Icon(Icons.error, color: Colors.white),
                          ),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.black.withOpacity(0.4),
                            Colors.black.withOpacity(0.7),
                          ],
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  width: 100,
                                  height: 150,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(8),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.3),
                                        spreadRadius: 1,
                                        blurRadius: 5,
                                        offset: const Offset(0, 3),
                                      ),
                                    ],
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: CachedNetworkImage(
                                      imageUrl: widget.manga.coverImage,
                                      fit: BoxFit.cover,
                                      placeholder:
                                          (_, __) => Container(
                                            color: Colors.grey[800],
                                          ),
                                      errorWidget:
                                          (_, __, ___) =>
                                              const Icon(Icons.error),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        widget.manga.title,
                                        style: const TextStyle(
                                          fontSize: 22,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        'by ${widget.manga.author}',
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.white.withOpacity(0.8),
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Row(
                                        children: [
                                          RatingBar.builder(
                                            initialRating: widget.manga.rating,
                                            minRating: 1,
                                            direction: Axis.horizontal,
                                            allowHalfRating: true,
                                            itemCount: 5,
                                            itemSize: 16,
                                            ignoreGestures: true,
                                            itemBuilder:
                                                (context, _) => const Icon(
                                                  Icons.star,
                                                  color: Colors.amber,
                                                ),
                                            onRatingUpdate: (_) {},
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            '(${widget.manga.rating.toStringAsFixed(1)})',
                                            style: const TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 8),
                                      Row(
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 8,
                                              vertical: 4,
                                            ),
                                            decoration: BoxDecoration(
                                              color:
                                                  widget.manga.status ==
                                                          'Ongoing'
                                                      ? Colors.green
                                                      : Colors.red,
                                              borderRadius:
                                                  BorderRadius.circular(4),
                                            ),
                                            child: Text(
                                              widget.manga.status,
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 12,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 8,
                                              vertical: 4,
                                            ),
                                            decoration: BoxDecoration(
                                              color: Colors.blue,
                                              borderRadius:
                                                  BorderRadius.circular(4),
                                            ),
                                            child: Text(
                                              '${widget.manga.chapters.length} Chapters',
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 12,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              IconButton(
                icon: Icon(
                  isFavorite ? Icons.favorite : Icons.favorite_border,
                  color: isFavorite ? Colors.red : Colors.white,
                ),
                onPressed: () => provider.toggleFavorite(widget.manga.id),
              ),
              IconButton(
                icon: Icon(
                  isInLibrary ? Icons.bookmark : Icons.bookmark_border,
                  color: isInLibrary ? kAccentColor : Colors.white,
                ),
                onPressed: () => provider.toggleLibrary(widget.manga.id),
              ),
              IconButton(
                icon: const Icon(Icons.share, color: Colors.white),
                onPressed: () {
                  // Share functionality would go here
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Sharing manga details...')),
                  );
                },
              ),
            ],
          ),
          SliverToBoxAdapter(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                  child: Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            provider.toggleReading(widget.manga.id);
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (_) => ReadingScreen(manga: widget.manga),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: kAccentColor,
                            foregroundColor: Colors.white,
                            minimumSize: const Size(0, 50),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          icon: const Icon(Icons.play_arrow),
                          label: Text(
                            isReading ? 'Continue Reading' : 'Start Reading',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Synopsis',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      AnimatedCrossFade(
                        firstChild: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.manga.description,
                              style: theme.textTheme.bodyMedium,
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
                            ),
                            TextButton(
                              onPressed: () {
                                setState(() {
                                  _isDescriptionExpanded = true;
                                });
                              },
                              style: TextButton.styleFrom(
                                padding: EdgeInsets.zero,
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                alignment: Alignment.centerLeft,
                              ),
                              child: const Text('Read More'),
                            ),
                          ],
                        ),
                        secondChild: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.manga.description,
                              style: theme.textTheme.bodyMedium,
                            ),
                            TextButton(
                              onPressed: () {
                                setState(() {
                                  _isDescriptionExpanded = false;
                                });
                              },
                              style: TextButton.styleFrom(
                                padding: EdgeInsets.zero,
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                alignment: Alignment.centerLeft,
                              ),
                              child: const Text('Show Less'),
                            ),
                          ],
                        ),
                        crossFadeState:
                            _isDescriptionExpanded
                                ? CrossFadeState.showSecond
                                : CrossFadeState.showFirst,
                        duration: const Duration(milliseconds: 300),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Genres',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children:
                            widget.manga.genres.map((genre) {
                              return Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: kPrimaryColor.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: kPrimaryColor.withOpacity(0.3),
                                  ),
                                ),
                                child: Text(
                                  genre,
                                  style: TextStyle(
                                    color: kPrimaryColor,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              );
                            }).toList(),
                      ),
                    ],
                  ),
                ),
                TabBar(
                  controller: _tabController,
                  labelColor: kAccentColor,
                  unselectedLabelColor: Colors.grey,
                  indicatorColor: kAccentColor,
                  tabs: const [
                    Tab(text: 'Chapters'),
                    Tab(text: 'Details'),
                    Tab(text: 'Related'),
                  ],
                ),
              ],
            ),
          ),
          SliverFillRemaining(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildChaptersTab(),
                _buildDetailsTab(),
                _buildRelatedTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChaptersTab() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: widget.manga.chapters.length,
      itemBuilder: (context, index) {
        final chapter =
            widget.manga.chapters[widget.manga.chapters.length - 1 - index];
        return ChapterListItem(
          chapter: chapter,
          manga: widget.manga,
          isLatest: index == 0,
          isRead: Provider.of<MangaProvider>(
            context,
          ).isChapterRead(widget.manga.id, chapter.id),
        );
      },
    );
  }

  Widget _buildDetailsTab() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: ListView(
        physics: const NeverScrollableScrollPhysics(),
        children: [
          _buildDetailItem('Author', widget.manga.author),
          _buildDetailItem(
            'Artist',
            widget.manga.artist ?? widget.manga.author,
          ),
          _buildDetailItem(
            'Publication',
            widget.manga.publication ?? 'Unknown',
          ),
          _buildDetailItem('Status', widget.manga.status),
          _buildDetailItem('Released', widget.manga.releaseDate ?? 'Unknown'),
          _buildDetailItem('Chapters', widget.manga.chapters.length.toString()),
          _buildDetailItem('Views', '${widget.manga.views}'),
          const SizedBox(height: 16),
          const Text(
            'Information',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'This content is meant for mature audiences and contains graphic violence, gore, strong language and mature themes. Reader discretion is advised.',
            style: TextStyle(color: Colors.grey[600], fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: TextStyle(
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRelatedTab() {
    // This would typically fetch related manga from an API
    // For now, we'll mock some related manga
    final mockRelated = [
      Manga(
        id: 'related1',
        title: 'Similar Manga 1',
        author: widget.manga.author,
        coverImage: widget.manga.coverImage,
        description: 'A related manga by the same author',
        rating: 4.3,
        status: 'Ongoing',
        genres: widget.manga.genres,
        chapters: [],
        views: 120000,
      ),
      Manga(
        id: 'related2',
        title: 'Similar Manga 2',
        author: 'Another Author',
        coverImage: widget.manga.coverImage,
        description: 'A manga with similar themes',
        rating: 4.1,
        status: 'Completed',
        genres: widget.manga.genres,
        chapters: [],
        views: 95000,
      ),
    ];

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Same Author',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 180,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: mockRelated.length,
              itemBuilder: (context, index) {
                return RelatedMangaCard(manga: mockRelated[index]);
              },
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'You May Also Like',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 180,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: mockRelated.length,
              itemBuilder: (context, index) {
                return RelatedMangaCard(manga: mockRelated[index]);
              },
            ),
          ),
        ],
      ),
    );
  }
}

// This would be defined in a separate file
class ChapterListItem extends StatelessWidget {
  final Chapter chapter;
  final Manga manga;
  final bool isLatest;
  final bool isRead;

  const ChapterListItem({
    super.key,
    required this.chapter,
    required this.manga,
    this.isLatest = false,
    this.isRead = false,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: () {
          Provider.of<MangaProvider>(
            context,
            listen: false,
          ).markChapterAsRead(manga.id, chapter.id);
          Navigator.push(
            context,
            MaterialPageRoute(
              builder:
                  (_) => ReadingScreen(manga: manga, initialChapter: chapter),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: kPrimaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Text(
                    'Ch.${chapter.number}',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: isRead ? Colors.grey : kPrimaryColor,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            chapter.title,
                            style: TextStyle(
                              fontWeight: FontWeight.w500,
                              color: isRead ? Colors.grey : null,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (isLatest)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.red,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Text(
                              'NEW',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Released ${chapter.releaseDate}',
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
              isRead
                  ? const Icon(Icons.check_circle, color: Colors.grey, size: 16)
                  : Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: kAccentColor,
                    ),
                  ),
            ],
          ),
        ),
      ),
    );
  }
}

// This would be defined in a separate file
class RelatedMangaCard extends StatelessWidget {
  final Manga manga;

  const RelatedMangaCard({super.key, required this.manga});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 120,
      margin: const EdgeInsets.only(right: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 150,
            width: 120,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  CachedNetworkImage(
                    imageUrl: manga.coverImage,
                    fit: BoxFit.cover,
                    placeholder: (_, __) => Container(color: Colors.grey[800]),
                    errorWidget: (_, __, ___) => const Icon(Icons.error),
                  ),
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black.withOpacity(0.8),
                          ],
                        ),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.star, color: Colors.amber, size: 12),
                          const SizedBox(width: 4),
                          Text(
                            manga.rating.toStringAsFixed(1),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            manga.title,
            style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            manga.author,
            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
