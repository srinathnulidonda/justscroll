import 'package:flutter/material.dart';
import '../../constants.dart';
import '../../screens/search_results_screen.dart';

class DiscoverTab extends StatelessWidget {
  const DiscoverTab({super.key});

  @override
  Widget build(BuildContext context) {
    final genres = [
      'Action',
      'Adventure',
      'Romance',
      'Fantasy',
      'Horror',
      'Mystery',
      'Shonen',
      'Isekai',
    ];

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            title: const Text('Discover'),
            flexibleSpace: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [kPrimaryColor.withOpacity(0.8), Colors.transparent],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
            floating: true,
          ),
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                Text(
                  'Explore Genres',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children:
                      genres
                          .map(
                            (genre) => GestureDetector(
                              onTap:
                                  () => Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder:
                                          (_) =>
                                              SearchResultsScreen(query: genre),
                                    ),
                                  ),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  color: kPrimaryColor.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(20),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.1),
                                      blurRadius: 8,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Text(
                                  genre,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ),
                          )
                          .toList(),
                ),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}
