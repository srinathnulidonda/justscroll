import 'package:flutter/material.dart';
import '../constants.dart';
import '../screens/search_results_screen.dart';

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

    return DraggableScrollableSheet(
      initialChildSize: 0.9,
      minChildSize: 0.5,
      maxChildSize: 0.9,
      builder:
          (_, scrollController) => Container(
            decoration: BoxDecoration(
              color: kSurfaceColor,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(20),
              ),
            ),
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Container(width: 40, height: 4, color: Colors.grey[600]),
                const SizedBox(height: 16),
                TextField(
                  controller: controller,
                  decoration: InputDecoration(
                    hintText: 'Search manga...',
                    prefixIcon: const Icon(Icons.search),
                    filled: true,
                    fillColor: Colors.grey[800],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  onSubmitted: (value) => _performSearch(context, value),
                ),
                const SizedBox(height: 16),
                Text(
                  'Popular Searches',
                  style: Theme.of(context).textTheme.titleLarge,
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
                              onPressed: () => _performSearch(context, search),
                            ),
                          )
                          .toList(),
                ),
              ],
            ),
          ),
    );
  }

  void _performSearch(BuildContext context, String query) {
    if (query.trim().isEmpty) return;
    Navigator.pop(context);
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => SearchResultsScreen(query: query)),
    );
  }
}
