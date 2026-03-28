// lib/components/common/toast.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:justscroll/stores/toast_store.dart';

class ToastOverlay extends ConsumerWidget {
  const ToastOverlay({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final toasts = ref.watch(toastProvider);
    if (toasts.isEmpty) return const SizedBox.shrink();

    final isWide = MediaQuery.of(context).size.width >= 768;
    final bottomOffset =
        MediaQuery.of(context).padding.bottom + (isWide ? 24 : 16);

    return Positioned(
      bottom: bottomOffset,
      left: 0,
      right: 0,
      child: RepaintBoundary(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: toasts
                    .map((t) => _ToastItem(key: ValueKey(t.id), toast: t))
                    .toList(),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ToastItem extends ConsumerStatefulWidget {
  final ToastData toast;
  const _ToastItem({super.key, required this.toast});

  @override
  ConsumerState<_ToastItem> createState() => _ToastItemState();
}

class _ToastItemState extends ConsumerState<_ToastItem>
    with TickerProviderStateMixin {
  late final AnimationController _entryController;
  late final AnimationController _timerController;
  late final Animation<Offset> _slideAnimation;
  late final Animation<double> _scaleAnimation;
  late final Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    _entryController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _entryController,
      curve: const Cubic(0.2, 1.0, 0.3, 1.0), // Smooth spring-like
    ));

    _scaleAnimation = Tween<double>(begin: 0.92, end: 1.0).animate(
      CurvedAnimation(
        parent: _entryController,
        curve: const Cubic(0.2, 1.0, 0.3, 1.0),
      ),
    );

    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _entryController,
        curve: const Interval(0, 0.6, curve: Curves.easeOut),
      ),
    );

    _entryController.forward();

    _timerController = AnimationController(
      vsync: this,
      duration: Duration(
        milliseconds:
            widget.toast.duration > 0 ? widget.toast.duration : 3000,
      ),
    );
    if (widget.toast.duration > 0) _timerController.forward();
  }

  @override
  void dispose() {
    _entryController.dispose();
    _timerController.dispose();
    super.dispose();
  }

  void _dismiss() async {
    await _entryController.reverse();
    if (mounted) {
      ref.read(toastProvider.notifier).remove(widget.toast.id);
    }
  }

  (Color, IconData) _typeStyle(ToastType type) {
    return switch (type) {
      ToastType.success => (
          const Color(0xFF34D399),
          Icons.check_circle_rounded
        ),
      ToastType.error => (const Color(0xFFF87171), Icons.error_rounded),
      ToastType.warning => (
          const Color(0xFFFBBF24),
          Icons.warning_amber_rounded
        ),
      ToastType.info => (const Color(0xFF60A5FA), Icons.info_rounded),
    };
  }

  @override
  Widget build(BuildContext context) {
    final t = widget.toast;
    final (color, icon) = _typeStyle(t.type);

    return RepaintBoundary(
      child: SlideTransition(
        position: _slideAnimation,
        child: ScaleTransition(
          scale: _scaleAnimation,
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: Dismissible(
              key: ValueKey('dismiss-${t.id}'),
              direction: DismissDirection.horizontal,
              onDismissed: (_) =>
                  ref.read(toastProvider.notifier).remove(t.id),
              child: Container(
                margin: const EdgeInsets.only(bottom: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFF1C1C20),
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x40000000),
                      blurRadius: 24,
                      offset: Offset(0, 8),
                      spreadRadius: -4,
                    ),
                  ],
                ),
                clipBehavior: Clip.antiAlias,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Padding(
                      padding:
                          const EdgeInsets.fromLTRB(4, 0, 4, 0),
                      child: IntrinsicHeight(
                        child: Row(
                          children: [
                            // Accent strip
                            Container(
                              width: 3,
                              margin: const EdgeInsets.symmetric(
                                  vertical: 8),
                              decoration: BoxDecoration(
                                color: color,
                                borderRadius:
                                    BorderRadius.circular(2),
                              ),
                            ),
                            const SizedBox(width: 12),

                            // Icon
                            Container(
                              width: 30,
                              height: 30,
                              decoration: BoxDecoration(
                                color: color.withOpacity(0.12),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(icon,
                                  size: 16, color: color),
                            ),
                            const SizedBox(width: 10),

                            // Text
                            Expanded(
                              child: Padding(
                                padding:
                                    const EdgeInsets.symmetric(
                                        vertical: 14),
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      t.title,
                                      maxLines: 2,
                                      overflow:
                                          TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w500,
                                        color: Colors.white,
                                        decoration:
                                            TextDecoration.none,
                                        height: 1.3,
                                      ),
                                    ),
                                    if (t.description !=
                                        null) ...[
                                      const SizedBox(height: 2),
                                      Text(
                                        t.description!,
                                        maxLines: 1,
                                        overflow:
                                            TextOverflow.ellipsis,
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight:
                                              FontWeight.w400,
                                          color: Colors.white
                                              .withOpacity(0.4),
                                          decoration:
                                              TextDecoration.none,
                                          height: 1.3,
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            ),

                            // Close
                            GestureDetector(
                              onTap: _dismiss,
                              behavior:
                                  HitTestBehavior.opaque,
                              child: Padding(
                                padding:
                                    const EdgeInsets.all(10),
                                child: Icon(
                                  Icons.close_rounded,
                                  size: 15,
                                  color: Colors.white
                                      .withOpacity(0.2),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Progress bar
                    if (widget.toast.duration > 0)
                      AnimatedBuilder(
                        animation: _timerController,
                        builder: (_, __) => Container(
                          height: 2.5,
                          alignment: Alignment.centerLeft,
                          color: Colors.white.withOpacity(0.03),
                          child: FractionallySizedBox(
                            widthFactor:
                                1 - _timerController.value,
                            child: Container(
                              decoration: BoxDecoration(
                                color: color.withOpacity(0.35),
                                borderRadius:
                                    BorderRadius.circular(2),
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}