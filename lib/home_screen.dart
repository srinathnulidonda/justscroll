import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import 'package:intl/intl.dart';
import 'package:flutter/services.dart';
import 'manga_provider.dart';
import 'search_screen.dart';
import 'reading_screen.dart';
import 'manga_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Future<void> _dataFuture;
  final Map<String, List<Manga>> _mangaCache = {};
  int _selectedIndex = 0;
  bool _showSearchBar = false;
  final TextEditingController _searchController = TextEditingController();

  final List<Map<String, dynamic>> _bannerData = [
    {
      'image': 'https://picsum.photos/800/300?random=1',
      'title': 'New Releases Every Week',
      'subtitle': 'Check back every Friday for new chapters',
    },
    {
      'image': 'https://picsum.photos/800/300?random=2',
      'title': 'Premium Subscription',
      'subtitle': 'Get early access to new chapters',
    },
    {
      'image': 'https://picsum.photos/800/300?random=3',
      'title': 'Community Events',
      'subtitle': 'Join discussions and fan events',
    },
  ];

  @override
  void initState() {
    super.initState();
    _dataFuture = _initializeFirebaseAndFetchData();
    try {
      SystemChrome.setSystemUIOverlayStyle(
        const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.light,
          systemNavigationBarColor: kSurfaceColor,
          systemNavigationBarIconBrightness: Brightness.light,
        ),
      );
    } catch (e) {
      debugPrint('Error setting system UI overlay: $e');
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _initializeFirebaseAndFetchData() async {
    try {
      await _fetchMangaData();
    } catch (e) {
      debugPrint('Initialization error: $e');
      rethrow;
    }
  }

  Future<void> _fetchMangaData() async {
    try {
      setState(() => _mangaCache.clear());
      final firestore = FirebaseFirestore.instance;
      const batchSize = 10;

      final futures = await Future.wait([
        _fetchCachedCollection(
          'trending',
          'popularity',
          descending: true,
          limit: batchSize,
        ),
        _fetchCachedCollection(
          'latest',
          'lastUpdated',
          descending: true,
          limit: batchSize,
        ),
        _fetchCachedCollection(
          'popular',
          'views',
          descending: true,
          limit: batchSize,
        ),
        _fetchCachedCollection(
          'recommended',
          'rating',
          descending: true,
          limit: batchSize,
        ),
      ]);

      if (mounted) {
        setState(() {
          _mangaCache['trending'] = futures[0];
          _mangaCache['latest'] = futures[1];
          _mangaCache['popular'] = futures[2];
          _mangaCache['recommended'] = futures[3];
        });
      }
    } catch (e) {
      debugPrint('Error fetching manga data: $e');
      if (mounted) {
        _loadFallbackData();
      }
    }
  }

  Future<List<Manga>> _fetchCachedCollection(
    String key,
    String orderBy, {
    bool descending = false,
    int limit = 10,
  }) async {
    if (_mangaCache[key]?.isNotEmpty ?? false) return _mangaCache[key]!;

    final query = FirebaseFirestore.instance
        .collection('manga')
        .orderBy(orderBy, descending: descending)
        .limit(limit);

    final snapshot = await query.get(
      const GetOptions(source: Source.serverAndCache),
    );
    return snapshot.docs.map(Manga.fromFirestore).toList();
  }

  void _loadFallbackData() {
    final fallback = [
      Manga(
        id: 'fallback1',
        title: 'Sample Manga',
        coverImage: 'https://picsum.photos/150',
        author: 'Unknown',
        rating: 4.0,
        genres: ['Action'],
        description: 'Sample description',
        totalChapters: 10,
        hasNewChapter: false,
      ),
    ];
    _mangaCache.addAll({
      'trending': fallback,
      'latest': fallback,
      'popular': fallback,
      'recommended': fallback,
    });
  }

  Widget _buildImage(String url, {double? height, double? width}) {
    return CachedNetworkImage(
      imageUrl: url,
      height: height,
      width: width,
      fit: BoxFit.cover,
      placeholder:
          (context, url) => Shimmer.fromColors(
            baseColor: Colors.grey[800]!,
            highlightColor: Colors.grey[700]!,
            child: Container(
              height: height,
              width: width,
              color: Colors.grey[800],
            ),
          ),
      errorWidget:
          (context, url, error) => Container(
            height: height,
            width: width,
            color: kPrimaryColor.withOpacity(0.3),
            child: const Icon(Icons.error, color: Colors.white),
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder(
        future: _dataFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return _buildLoadingScreen();
          }
          return _buildContent();
        },
      ),
      bottomNavigationBar: _buildBottomNavBar(),
      floatingActionButton: FloatingActionButton(
        onPressed: _showSearchDialog,
        backgroundColor: kAccentColor,
        child: const Icon(Icons.search, color: Colors.black87),
        elevation: 4,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      extendBody: true,
    );
  }

  Widget _buildContent() {
    return [
      _buildHomeTab(),
      const DiscoverTab(),
      const LibraryTab(),
      const ProfileTab(),
    ][_selectedIndex];
  }

  Widget _buildBottomNavBar() {
    return Container(
      decoration: BoxDecoration(
        color: kSurfaceColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 10,
            spreadRadius: 1,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        child: BottomAppBar(
          shape: const CircularNotchedRectangle(),
          notchMargin: 8.0,
          color: kSurfaceColor,
          elevation: 0,
          child: SizedBox(
            height: 60,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavItem(Icons.home_rounded, 'Home', 0),
                _buildNavItem(Icons.explore, 'Discover', 1),
                const SizedBox(width: 40),
                _buildNavItem(Icons.library_books_rounded, 'Library', 2),
                _buildNavItem(Icons.person_rounded, 'Profile', 3),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, int index) {
    final isSelected = _selectedIndex == index;
    return InkWell(
      onTap: () {
        if (mounted) {
          setState(() => _selectedIndex = index);
        }
      },
      splashColor: kPrimaryColor.withOpacity(0.2),
      highlightColor: kPrimaryColor.withOpacity(0.1),
      borderRadius: BorderRadius.circular(16),
      child: SizedBox(
        height: 60,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isSelected ? kAccentColor : Colors.white70,
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? kAccentColor : Colors.white70,
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHomeTab() {
    return RefreshIndicator(
      onRefresh: _fetchMangaData,
      color: kAccentColor,
      backgroundColor: kSurfaceColor,
      child: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          _buildAppBar(),
          _buildPromoBanner(),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                _buildContinueReading(),
                const SizedBox(height: 24),
                _buildTrendingSection(),
                const SizedBox(height: 24),
                _buildLatestUpdatesSection(),
                const SizedBox(height: 24),
                _buildPopularSection(),
                const SizedBox(height: 24),
                _buildRecommendedSection(),
                const SizedBox(height: 100),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar() {
    return SliverAppBar(
      expandedHeight: 60,
      floating: true,
      pinned: _showSearchBar,
      backgroundColor: kSurfaceColor,
      leadingWidth: 0,
      leading: const SizedBox.shrink(),
      title:
          _showSearchBar
              ? TextField(
                controller: _searchController,
                cursorColor: kAccentColor,
                autofocus: true,
                decoration: InputDecoration(
                  hintText: 'Search manga...',
                  hintStyle: const TextStyle(color: Colors.white60),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.zero,
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.close, color: Colors.white70),
                    onPressed: () {
                      if (mounted) {
                        setState(() {
                          _showSearchBar = false;
                          _searchController.clear();
                        });
                      }
                    },
                  ),
                ),
                style: const TextStyle(color: Colors.white),
                onSubmitted: (value) {
                  if (mounted && value.isNotEmpty) {
                    setState(() => _showSearchBar = false);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => SearchResultsScreen(query: value),
                      ),
                    );
                  }
                },
              )
              : Row(
                children: [
                  RichText(
                    text: const TextSpan(
                      children: [
                        TextSpan(
                          text: 'Manga',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 22,
                          ),
                        ),
                        TextSpan(
                          text: 'Haven',
                          style: TextStyle(
                            color: kAccentColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 22,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
      actions: [
        if (!_showSearchBar)
          IconButton(
            icon: const Icon(Icons.search_rounded),
            onPressed: () {
              if (mounted) setState(() => _showSearchBar = true);
            },
          ),
        if (!_showSearchBar)
          IconButton(
            icon: const Icon(Icons.notifications_none_rounded),
            onPressed: () {},
          ),
      ],
    );
  }

  Widget _buildPromoBanner() {
    return SliverToBoxAdapter(
      child: CarouselSlider.builder(
        itemCount: _bannerData.length,
        itemBuilder: (context, index, realIndex) {
          final banner = _bannerData[index];
          return Container(
            width: double.infinity,
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  _buildImage(banner['image'], height: 180),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(0.7),
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 16,
                    left: 16,
                    right: 16,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          banner['title'],
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            shadows: [
                              Shadow(
                                color: Colors.black54,
                                blurRadius: 2,
                                offset: Offset(0, 1),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          banner['subtitle'],
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.9),
                            fontSize: 14,
                            shadows: [
                              Shadow(
                                color: Colors.black54,
                                blurRadius: 2,
                                offset: Offset(0, 1),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
        options: CarouselOptions(
          height: 180,
          autoPlay: true,
          enlargeCenterPage: true,
          viewportFraction: 0.92,
          aspectRatio: 16 / 9,
          autoPlayAnimationDuration: const Duration(milliseconds: 800),
          autoPlayInterval: const Duration(seconds: 6),
        ),
      ),
    );
  }

  Widget _buildContinueReading() {
    final provider = Provider.of<MangaProvider>(context);
    final recentIds = provider.getRecentlyRead();

    if (recentIds.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(
          'Continue Reading',
          Icons.play_arrow_rounded,
          Colors.greenAccent,
        ),
        const SizedBox(height: 12),
        FutureBuilder<QuerySnapshot>(
          future:
              FirebaseFirestore.instance
                  .collection('manga')
                  .where(FieldPath.documentId, whereIn: recentIds)
                  .get(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return _buildContinueReadingPlaceholder();
            }

            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return const SizedBox.shrink();
            }

            final mangaList =
                snapshot.data!.docs.map(Manga.fromFirestore).toList();

            return SizedBox(
              height: 130,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: mangaList.length,
                itemBuilder: (context, index) {
                  final manga = mangaList[index];
                  final progress = provider.getProgress(manga.id);
                  final progressPercent =
                      manga.totalChapters > 0
                          ? (progress / manga.totalChapters)
                          : 0.0;

                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ReadingScreen(manga: manga),
                        ),
                      );
                    },
                    child: Container(
                      width: 270,
                      margin: const EdgeInsets.only(right: 16),
                      decoration: BoxDecoration(
                        color: kCardColor,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: Row(
                        children: [
                          ClipRRect(
                            borderRadius: const BorderRadius.horizontal(
                              left: Radius.circular(12),
                            ),
                            child: _buildImage(
                              manga.coverImage,
                              height: 130,
                              width: 90,
                            ),
                          ),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.all(12),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
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
                                      const SizedBox(
                                        height: 4,
                                      ), // Fixed: Removed 'reuni' typo
                                      Text(
                                        'Chapter $progress of ${manga.totalChapters}',
                                        style: const TextStyle(
                                          color: Colors.white70,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(2),
                                        child: LinearProgressIndicator(
                                          value: progressPercent,
                                          backgroundColor: Colors.grey[800],
                                          valueColor:
                                              AlwaysStoppedAnimation<Color>(
                                                progressPercent < 0.3
                                                    ? Colors.redAccent
                                                    : progressPercent < 0.7
                                                    ? Colors.orangeAccent
                                                    : Colors.greenAccent,
                                              ),
                                          minHeight: 5,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 10,
                                          vertical: 4,
                                        ),
                                        decoration: BoxDecoration(
                                          color: kPrimaryColor.withOpacity(0.3),
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                        child: const Text(
                                          'Continue',
                                          style: TextStyle(
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
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildContinueReadingPlaceholder() {
    return SizedBox(
      height: 130,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: 2,
        itemBuilder: (context, index) {
          return Shimmer.fromColors(
            baseColor: Colors.grey[800]!,
            highlightColor: Colors.grey[700]!,
            child: Container(
              width: 270,
              margin: const EdgeInsets.only(right: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTrendingSection() {
    final trending = _mangaCache['trending'] ?? [];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(
          'Trending Now',
          Icons.trending_up_rounded,
          kAccentColor,
        ),
        const SizedBox(height: 12),
        CarouselSlider.builder(
          itemCount: trending.length,
          itemBuilder: (context, index, realIndex) {
            return MangaCard(manga: trending[index], isFeatured: true);
          },
          options: CarouselOptions(
            height: 300,
            autoPlay: true,
            enlargeCenterPage: true,
            viewportFraction: 0.85,
            aspectRatio: 16 / 9,
            autoPlayAnimationDuration: const Duration(milliseconds: 800),
            autoPlayInterval: const Duration(seconds: 5),
          ),
        ),
      ],
    );
  }

  Widget _buildLatestUpdatesSection() {
    final latest = _mangaCache['latest'] ?? [];
    return SectionWidget(
      title: 'Latest Updates',
      icon: Icons.update_rounded,
      color: Colors.blueAccent,
      child: SizedBox(
        height: 220,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          itemCount: latest.length,
          itemBuilder: (context, index) => UpdateCard(manga: latest[index]),
        ),
      ),
    );
  }

  Widget _buildPopularSection() {
    final popular = _mangaCache['popular'] ?? [];
    return SectionWidget(
      title: 'Popular This Week',
      icon: Icons.whatshot_rounded,
      color: Colors.redAccent,
      child: Column(
        children:
            popular
                .take(5)
                .map(
                  (manga) => PopularMangaCard(
                    manga: manga,
                    rank: popular.indexOf(manga) + 1,
                  ),
                )
                .toList(),
      ),
    );
  }

  Widget _buildRecommendedSection() {
    final recommended = _mangaCache['recommended'] ?? [];
    return SectionWidget(
      title: 'Recommended For You',
      icon: Icons.recommend_rounded,
      color: Colors.purpleAccent,
      child: SizedBox(
        height: 250,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          itemCount: recommended.length,
          itemBuilder:
              (context, index) => RecommendedCard(manga: recommended[index]),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(width: 8),
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const Spacer(),
          TextButton(
            onPressed: () {},
            style: TextButton.styleFrom(
              foregroundColor: Colors.white70,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: const Text('See All'),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingScreen() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[800]!,
      highlightColor: Colors.grey[700]!,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 60,
              color: Colors.white,
              margin: const EdgeInsets.only(bottom: 16),
            ),
            Container(
              height: 180,
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(width: 150, height: 20, color: Colors.white),
                  const SizedBox(height: 12),
                  Container(
                    height: 130,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Container(width: 180, height: 20, color: Colors.white),
                  const SizedBox(height: 12),
                  Container(
                    height: 300,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showSearchDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const SearchSheet(),
    );
  }
}

class DiscoverTab extends StatelessWidget {
  const DiscoverTab({super.key});
  @override
  Widget build(BuildContext context) =>
      const Center(child: Text('Discover Tab'));
}

class LibraryTab extends StatelessWidget {
  const LibraryTab({super.key});
  @override
  Widget build(BuildContext context) =>
      const Center(child: Text('Library Tab'));
}

class ProfileTab extends StatelessWidget {
  const ProfileTab({super.key});
  @override
  Widget build(BuildContext context) =>
      const Center(child: Text('Profile Tab'));
}

class SectionWidget extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final Widget child;

  const SectionWidget({
    super.key,
    required this.title,
    required this.icon,
    required this.color,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Row(
            children: [
              Icon(icon, color: color, size: 24),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const Spacer(),
              TextButton(
                onPressed: () {},
                style: TextButton.styleFrom(
                  foregroundColor: Colors.white70,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: const Text('See All'),
              ),
            ],
          ),
        ),
        child,
      ],
    );
  }
}

class MangaCard extends StatelessWidget {
  final Manga manga;
  final bool isFeatured;

  const MangaCard({super.key, required this.manga, this.isFeatured = false});

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
        margin: EdgeInsets.symmetric(horizontal: isFeatured ? 8 : 6),
        decoration: BoxDecoration(
          color: kCardColor,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            if (isFeatured)
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          children: [
            CachedNetworkImage(
              imageUrl: manga.coverImage,
              height: isFeatured ? 300 : 220,
              width: double.infinity,
              fit: BoxFit.cover,
              placeholder: (context, url) => Container(color: Colors.grey[800]),
              errorWidget:
                  (context, url, error) => Container(
                    color: kPrimaryColor.withOpacity(0.3),
                    child: const Icon(Icons.error, color: Colors.white),
                  ),
            ),
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.transparent, Colors.black.withOpacity(0.8)],
                    stops: const [0.5, 1.0],
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (manga.hasNewChapter)
                      Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.redAccent,
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
                    Text(
                      manga.title,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: isFeatured ? 18 : 16,
                        fontWeight: FontWeight.bold,
                        shadows: const [
                          Shadow(color: Colors.black, blurRadius: 2),
                        ],
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    if (isFeatured) ...[
                      Text(
                        manga.author,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.8),
                          fontSize: 14,
                          shadows: const [
                            Shadow(color: Colors.black, blurRadius: 2),
                          ],
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
                          const SizedBox(width: 12),
                          const Icon(
                            Icons.remove_red_eye,
                            color: Colors.white70,
                            size: 16,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            NumberFormat.compact().format(manga.views),
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ],
                    if (!isFeatured) ...[
                      Row(
                        children: [
                          const Icon(Icons.star, color: kAccentColor, size: 14),
                          const SizedBox(width: 4),
                          Text(
                            manga.rating.toString(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ],
                    if (isFeatured) ...[
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
                                  color: kPrimaryColor.withOpacity(0.5),
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
                  ],
                ),
              ),
            ),
            Positioned(
              top: 8,
              right: 8,
              child: Consumer<MangaProvider>(
                builder: (context, provider, child) {
                  final isFavorite = provider.isFavorite(manga.id);
                  return GestureDetector(
                    onTap: () => provider.toggleFavorite(manga.id),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.5),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        isFavorite ? Icons.bookmark : Icons.bookmark_border,
                        color: isFavorite ? kAccentColor : Colors.white,
                        size: 20,
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
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
        width: 150,
        margin: const EdgeInsets.only(right: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: CachedNetworkImage(
                imageUrl: manga.coverImage,
                height: 150,
                width: 150,
                fit: BoxFit.cover,
                placeholder:
                    (context, url) => Container(color: Colors.grey[800]),
                errorWidget:
                    (context, url, error) => Container(
                      color: kPrimaryColor.withOpacity(0.3),
                      child: const Icon(Icons.error, color: Colors.white),
                    ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              manga.title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Text(
              manga.lastUpdated != null
                  ? DateFormat('MMM d').format(manga.lastUpdated!.toDate())
                  : 'Unknown',
              style: const TextStyle(color: Colors.white70, fontSize: 12),
            ),
          ],
        ),
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
        margin: const EdgeInsets.symmetric(vertical: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: kCardColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: kPrimaryColor,
              child: Text(
                '$rank',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: CachedNetworkImage(
                imageUrl: manga.coverImage,
                height: 80,
                width: 60,
                fit: BoxFit.cover,
                placeholder:
                    (context, url) => Container(color: Colors.grey[800]),
                errorWidget:
                    (context, url, error) => Container(
                      color: kPrimaryColor.withOpacity(0.3),
                      child: const Icon(Icons.error, color: Colors.white),
                    ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
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
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    manga.author,
                    style: const TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                  const SizedBox(height: 4),
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
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class RecommendedCard extends StatelessWidget {
  final Manga manga;

  const RecommendedCard({super.key, required this.manga});

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
        width: 150,
        margin: const EdgeInsets.only(right: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: CachedNetworkImage(
                imageUrl: manga.coverImage,
                height: 180,
                width: 150,
                fit: BoxFit.cover,
                placeholder:
                    (context, url) => Container(color: Colors.grey[800]),
                errorWidget:
                    (context, url, error) => Container(
                      color: kPrimaryColor.withOpacity(0.3),
                      child: const Icon(Icons.error, color: Colors.white),
                    ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              manga.title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.star, color: kAccentColor, size: 14),
                const SizedBox(width: 4),
                Text(
                  manga.rating.toString(),
                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
