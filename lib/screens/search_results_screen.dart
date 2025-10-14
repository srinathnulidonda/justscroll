import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../constants.dart';
import '../models/manga.dart';
import '../widgets/manga_card.dart';

class SearchResultsScreen extends StatelessWidget {
  final String query;

  const SearchResultsScreen({super.key, required this.query});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Search: $query'),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [kPrimaryColor.withOpacity(0.8), Colors.transparent],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream:
            FirebaseFirestore.instance
                .collection('manga')
                .where('title', isGreaterThanOrEqualTo: query)
                .where('title', isLessThanOrEqualTo: '$query\uf8ff')
                .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text(
                'No results found',
                style: TextStyle(color: Colors.white70, fontSize: 18),
              ),
            );
          }
          final results = snapshot.data!.docs.map(Manga.fromFirestore).toList();
          return GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.7,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemCount: results.length,
            itemBuilder: (context, index) => MangaCard(manga: results[index]),
          );
        },
      ),
    );
  }
}
