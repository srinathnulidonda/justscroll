// lib/components/common/optimized_image.dart
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:justscroll/lib/utils.dart' as utils;

class OptimizedImage extends StatelessWidget {
  final String? src;
  final double? width;
  final double? height;
  final BoxFit fit;
  final BorderRadiusGeometry? borderRadius;
  final bool proxy;
  final Widget? placeholder;
  final Widget? errorWidget;

  const OptimizedImage({
    super.key,
    this.src,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius,
    this.proxy = true,
    this.placeholder,
    this.errorWidget,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final url = (proxy && src != null && src!.isNotEmpty)
        ? utils.proxyImage(src)
        : (src ?? '');

    if (url.isEmpty) return _buildFallback(theme);

    // Constrain memory cache to reduce RAM usage
    final dpr = MediaQuery.of(context).devicePixelRatio;
    final memW = width != null ? (width! * dpr).toInt() : 300;
    final memH = height != null ? (height! * dpr).toInt() : 450;

    return RepaintBoundary(
      child: ClipRRect(
        borderRadius: borderRadius ?? BorderRadius.circular(12),
        child: CachedNetworkImage(
          imageUrl: url,
          width: width,
          height: height,
          fit: fit,
          memCacheWidth: memW,
          memCacheHeight: memH,
          maxWidthDiskCache: 600,
          maxHeightDiskCache: 900,
          fadeInDuration: const Duration(milliseconds: 200),
          fadeOutDuration: const Duration(milliseconds: 100),
          placeholder: (_, __) =>
              placeholder ?? _buildPlaceholder(theme),
          errorWidget: (_, __, ___) =>
              errorWidget ?? _buildFallback(theme),
        ),
      ),
    );
  }

  Widget _buildPlaceholder(ThemeData theme) {
    return Container(
      width: width,
      height: height,
      color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.5),
    );
  }

  Widget _buildFallback(ThemeData theme) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: borderRadius ?? BorderRadius.circular(12),
      ),
      child: Icon(
        Icons.broken_image_outlined,
        size: 28,
        color: theme.colorScheme.onSurface.withOpacity(0.15),
      ),
    );
  }
}