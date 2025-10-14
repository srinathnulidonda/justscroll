// In your manga.dart model file
import 'package:cloud_firestore/cloud_firestore.dart';

class Manga {
  final String id;
  final String title;
  final String description;
  final String coverUrl;
  final List<String> genres;
  final String author;
  final DateTime lastUpdated; // Keep as DateTime for Dart usage
  final bool isCompleted;

  Manga({
    required this.id,
    required this.title,
    required this.description,
    required this.coverUrl,
    required this.genres,
    required this.author,
    required this.lastUpdated,
    required this.isCompleted,
  });

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'coverUrl': coverUrl,
      'genres': genres,
      'author': author,
      'lastUpdated': Timestamp.fromDate(
        lastUpdated,
      ), // Convert to Firestore Timestamp here
      'isCompleted': isCompleted,
    };
  }

  factory Manga.fromMap(Map<String, dynamic> map, String docId) {
    return Manga(
      id: docId,
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      coverUrl: map['coverUrl'] ?? '',
      genres: List<String>.from(map['genres'] ?? []),
      author: map['author'] ?? '',
      lastUpdated:
          (map['lastUpdated'] as Timestamp)
              .toDate(), // Convert back to DateTime
      isCompleted: map['isCompleted'] ?? false,
    );
  }
}
