// lib/models/chapter.dart
class Chapter {
  final String id;
  final String? chapter;
  final String? title;
  final String? scanlationGroup;
  final int pages;
  final bool readable;
  final String? publishedAt;

  const Chapter({
    required this.id,
    this.chapter,
    this.title,
    this.scanlationGroup,
    this.pages = 0,
    this.readable = true,
    this.publishedAt,
  });

  factory Chapter.fromJson(Map<String, dynamic> json) {
    return Chapter(
      id: json['id']?.toString() ?? '',
      chapter: json['chapter']?.toString(),
      title: json['title']?.toString(),
      scanlationGroup: json['scanlation_group']?.toString(),
      pages: json['pages'] ?? 0,
      readable: json['readable'] ?? true,
      publishedAt: json['published_at']?.toString(),
    );
  }

  String get label {
    final num = chapter;
    final t = title;
    String l = (num != null && num.isNotEmpty) ? 'Ch. $num' : 'Oneshot';
    if (t != null && t.isNotEmpty) l += ' — $t';
    return l;
  }
}

class ChapterListResponse {
  final List<Chapter> data;
  final int total;

  const ChapterListResponse({required this.data, required this.total});

  factory ChapterListResponse.fromJson(Map<String, dynamic> json) {
    return ChapterListResponse(
      data: (json['data'] as List<dynamic>?)?.map((e) => Chapter.fromJson(e)).toList() ?? [],
      total: json['total'] ?? 0,
    );
  }
}

class ChapterPagesResponse {
  final List<String> pages;

  const ChapterPagesResponse({required this.pages});

  factory ChapterPagesResponse.fromJson(Map<String, dynamic> json) {
    return ChapterPagesResponse(
      pages: (json['pages'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
    );
  }
}