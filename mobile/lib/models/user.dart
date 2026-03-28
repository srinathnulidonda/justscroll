// lib/models/user.dart
class AppUser {
  final String username;
  final String? email;

  const AppUser({required this.username, this.email});

  factory AppUser.fromJson(Map<String, dynamic> json) {
    return AppUser(
      username: json['username']?.toString() ?? '',
      email: json['email']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {'username': username, 'email': email};
}

class BookmarkEntry {
  final String id;
  final String mangaId;
  final String mangaTitle;
  final String? coverUrl;
  final String? createdAt;

  const BookmarkEntry({
    required this.id,
    required this.mangaId,
    required this.mangaTitle,
    this.coverUrl,
    this.createdAt,
  });

  factory BookmarkEntry.fromJson(Map<String, dynamic> json) {
    return BookmarkEntry(
      id: json['id']?.toString() ?? '',
      mangaId: json['manga_id']?.toString() ?? '',
      mangaTitle: json['manga_title']?.toString() ?? '',
      coverUrl: json['cover_url']?.toString(),
      createdAt: json['created_at']?.toString(),
    );
  }
}

class HistoryEntry {
  final String id;
  final String mangaId;
  final String chapterId;
  final String mangaTitle;
  final String? chapterNumber;
  final int pageNumber;
  final String? updatedAt;

  const HistoryEntry({
    required this.id,
    required this.mangaId,
    required this.chapterId,
    required this.mangaTitle,
    this.chapterNumber,
    this.pageNumber = 1,
    this.updatedAt,
  });

  factory HistoryEntry.fromJson(Map<String, dynamic> json) {
    return HistoryEntry(
      id: json['id']?.toString() ?? '',
      mangaId: json['manga_id']?.toString() ?? '',
      chapterId: json['chapter_id']?.toString() ?? '',
      mangaTitle: json['manga_title']?.toString() ?? '',
      chapterNumber: json['chapter_number']?.toString(),
      pageNumber: json['page_number'] ?? 1,
      updatedAt: json['updated_at']?.toString(),
    );
  }
}

class BookmarkListResponse {
  final List<BookmarkEntry> data;
  final int total;
  const BookmarkListResponse({required this.data, required this.total});
  factory BookmarkListResponse.fromJson(Map<String, dynamic> json) {
    return BookmarkListResponse(
      data: (json['data'] as List<dynamic>?)?.map((e) => BookmarkEntry.fromJson(e)).toList() ?? [],
      total: json['total'] ?? 0,
    );
  }
}

class HistoryListResponse {
  final List<HistoryEntry> data;
  final int total;
  const HistoryListResponse({required this.data, required this.total});
  factory HistoryListResponse.fromJson(Map<String, dynamic> json) {
    return HistoryListResponse(
      data: (json['data'] as List<dynamic>?)?.map((e) => HistoryEntry.fromJson(e)).toList() ?? [],
      total: json['total'] ?? 0,
    );
  }
}