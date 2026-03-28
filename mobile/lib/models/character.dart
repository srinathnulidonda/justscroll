// lib/models/character.dart
class MangaCharacter {
  final int? malId;
  final String name;
  final String? imageUrl;
  final String role;

  const MangaCharacter({
    this.malId,
    required this.name,
    this.imageUrl,
    this.role = 'Supporting',
  });

  factory MangaCharacter.fromJson(Map<String, dynamic> json) {
    return MangaCharacter(
      malId: json['mal_id'],
      name: json['name']?.toString() ?? '',
      imageUrl: json['image_url']?.toString(),
      role: json['role']?.toString() ?? 'Supporting',
    );
  }
}

class CharacterListResponse {
  final List<MangaCharacter> data;
  final int total;

  const CharacterListResponse({required this.data, required this.total});

  factory CharacterListResponse.fromJson(Map<String, dynamic> json) {
    return CharacterListResponse(
      data: (json['data'] as List<dynamic>?)?.map((e) => MangaCharacter.fromJson(e)).toList() ?? [],
      total: json['total'] ?? 0,
    );
  }
}