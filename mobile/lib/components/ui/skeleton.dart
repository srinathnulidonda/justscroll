// lib/components/ui/skeleton.dart
import 'package:flutter/material.dart';

class Skeleton extends StatefulWidget {
  final double? width;
  final double? height;
  final BorderRadiusGeometry? borderRadius;

  const Skeleton({super.key, this.width, this.height, this.borderRadius});

  @override
  State<Skeleton> createState() => _SkeletonState();
}

class _SkeletonState extends State<Skeleton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final base = isDark ? const Color(0xFF27272A) : const Color(0xFFE4E4E7);
    final highlight =
        isDark ? const Color(0xFF3F3F46) : const Color(0xFFF4F4F5);

    return RepaintBoundary(
      child: AnimatedBuilder(
        animation: _controller,
        builder: (_, __) => Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            color: Color.lerp(base, highlight, _controller.value),
            borderRadius:
                widget.borderRadius ?? BorderRadius.circular(8),
          ),
        ),
      ),
    );
  }
}

class MangaCardSkeleton extends StatelessWidget {
  const MangaCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AspectRatio(
            aspectRatio: 2 / 3,
            child: Skeleton(borderRadius: BorderRadius.circular(10)),
          ),
          const SizedBox(height: 8),
          const Skeleton(height: 14, width: double.infinity),
          const SizedBox(height: 4),
          const Skeleton(height: 12, width: 80),
        ],
      ),
    );
  }
}

class MangaGridSkeleton extends StatelessWidget {
  final int count;
  const MangaGridSkeleton({super.key, this.count = 12});

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    final cols =
        w < 400 ? 2 : w < 640 ? 3 : w < 768 ? 4 : w < 1024 ? 5 : 6;

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: cols,
        childAspectRatio: 0.52,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: count,
      itemBuilder: (_, __) => const MangaCardSkeleton(),
    );
  }
}

class DetailSkeleton extends StatelessWidget {
  const DetailSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return RepaintBoundary(
      child: SingleChildScrollView(
        physics: const NeverScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Background placeholder
            Container(
              height: 220,
              width: double.infinity,
              color: theme.colorScheme.surfaceContainerHighest
                  .withOpacity(0.4),
            ),

            // Cover + info row aligned with real layout
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
              child: Transform.translate(
                offset: const Offset(0, -120),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    // Cover skeleton
                    SizedBox(
                      width: 110,
                      child: AspectRatio(
                        aspectRatio: 2 / 3,
                        child: Skeleton(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),

                    // Text skeletons
                    Expanded(
                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Skeleton(
                                height: 20,
                                width: 70,
                                borderRadius:
                                    BorderRadius.circular(20),
                              ),
                              const SizedBox(width: 8),
                              Skeleton(
                                height: 20,
                                width: 60,
                                borderRadius:
                                    BorderRadius.circular(20),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          const Skeleton(
                            height: 22,
                            width: double.infinity,
                          ),
                          const SizedBox(height: 6),
                          const Skeleton(height: 22, width: 160),
                          const SizedBox(height: 10),
                          const Skeleton(height: 14, width: 120),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Stats
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
              child: Transform.translate(
                offset: const Offset(0, -100),
                child: Column(
                  children: [
                    Row(
                      children: List.generate(
                        4,
                        (_) => Expanded(
                          child: Container(
                            margin: const EdgeInsets.symmetric(
                                horizontal: 4),
                            child: Skeleton(
                              height: 72,
                              borderRadius:
                                  BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: Skeleton(
                            height: 40,
                            borderRadius:
                                BorderRadius.circular(10),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Skeleton(
                            height: 40,
                            borderRadius:
                                BorderRadius.circular(10),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Skeleton(
                      height: 120,
                      width: double.infinity,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    const SizedBox(height: 16),
                    Skeleton(
                      height: 60,
                      width: double.infinity,
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}