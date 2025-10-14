import 'package:flutter/material.dart';
import '../models/manga.dart';
import 'manga_card.dart';

class RecommendedCard extends StatelessWidget {
  final Manga manga;

  const RecommendedCard({super.key, required this.manga});

  @override
  Widget build(BuildContext context) {
    return SizedBox(width: 150, child: MangaCard(manga: manga));
  }
}
