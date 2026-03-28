// lib/models/manga.dart
class Manga {
  final String id;
  final String title;
  final String? description;
  final String? coverUrl;
  final String? author;
  final String? artist;
  final String? status;
  final String? source;
  final double? score;
  final int? members;
  final int? year;
  final String? contentRating;
  final List<String> tags;

  const Manga({
    required this.id,
    required this.title,
    this.description,
    this.coverUrl,
    this.author,
    this.artist,
    this.status,
    this.source,
    this.score,
    this.members,
    this.year,
    this.contentRating,
    this.tags = const [],
  });

  factory Manga.fromJson(Map<String, dynamic> json) {
    return Manga(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      description: json['description']?.toString(),
      coverUrl: json['cover_url']?.toString(),
      author: json['author']?.toString(),
      artist: json['artist']?.toString(),
      status: json['status']?.toString(),
      source: json['source']?.toString(),
      score: (json['score'] is num) ? (json['score'] as num).toDouble() : double.tryParse(json['score']?.toString() ?? ''),
      members: json['members'] is int ? json['members'] : int.tryParse(json['members']?.toString() ?? ''),
      year: json['year'] is int ? json['year'] : int.tryParse(json['year']?.toString() ?? ''),
      contentRating: json['content_rating']?.toString(),
      tags: (json['tags'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
    );
  }
}

class MangaListResponse {
  final List<Manga> data;
  final int total;

  const MangaListResponse({required this.data, required this.total});

  factory MangaListResponse.fromJson(Map<String, dynamic> json) {
    return MangaListResponse(
      data: (json['data'] as List<dynamic>?)?.map((e) => Manga.fromJson(e)).toList() ?? [],
      total: json['total'] ?? 0,
    );
  }
}