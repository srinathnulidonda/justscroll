// lib/components/manga/character_card.dart
import 'package:flutter/material.dart';
import 'package:justscroll/models/character.dart';
import 'package:justscroll/components/common/optimized_image.dart';
import 'package:justscroll/components/ui/badge.dart';
import 'package:justscroll/components/ui/skeleton.dart';

class CharacterCard extends StatelessWidget {
  final MangaCharacter character;
  const CharacterCard({super.key, required this.character});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.colorScheme.outline.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          ClipOval(
            child: SizedBox(
              width: 48,
              height: 48,
              child: OptimizedImage(src: character.imageUrl, fit: BoxFit.cover, borderRadius: BorderRadius.circular(24)),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(character.name, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
                const SizedBox(height: 4),
                AppBadge(
                  label: character.role,
                  variant: character.role == 'Main' ? BadgeVariant.primary : BadgeVariant.secondary,
                  fontSize: 10,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class CharacterGrid extends StatelessWidget {
  final List<MangaCharacter>? characters;
  final bool loading;

  const CharacterGrid({super.key, this.characters, this.loading = false});

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return Column(
        children: List.generate(6, (_) => Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Skeleton(height: 72, borderRadius: BorderRadius.circular(12)),
        )),
      );
    }

    if (characters == null || characters!.isEmpty) return const SizedBox.shrink();

    final w = MediaQuery.of(context).size.width;
    final cols = w < 640 ? 1 : w < 1024 ? 2 : 3;

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: cols,
        childAspectRatio: 4,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemCount: characters!.length,
      itemBuilder: (_, i) => CharacterCard(character: characters![i]),
    );
  }
}