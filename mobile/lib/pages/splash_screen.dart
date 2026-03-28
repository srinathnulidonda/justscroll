// lib/pages/splash_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class SplashScreen extends StatefulWidget {
  final VoidCallback onComplete;
  final bool isExiting;
  
  const SplashScreen({
    super.key,
    required this.onComplete,
    this.isExiting = false,
  });

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with TickerProviderStateMixin {
  late final AnimationController _bottomController;
  late final Animation<double> _bottomOpacity;
  late final Animation<double> _bottomSlideY;

  static const _bg = Color(0xFF09090B);

  @override
  void initState() {
    super.initState();

    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: _bg,
      systemNavigationBarIconBrightness: Brightness.light,
    ));

    _bottomController = AnimationController(vsync: this, duration: const Duration(milliseconds: 500));

    _bottomOpacity = Tween(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _bottomController, curve: Curves.easeOut),
    );
    _bottomSlideY = Tween(begin: 20.0, end: 0.0).animate(
      CurvedAnimation(parent: _bottomController, curve: const Cubic(0.175, 0.885, 0.32, 1.05)),
    );

    _run();
  }

  Future<void> _run() async {
    await Future.delayed(const Duration(milliseconds: 200));
    _bottomController.forward();
    await Future.delayed(const Duration(milliseconds: 1300));
    widget.onComplete();
  }

  @override
  void dispose() {
    _bottomController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    final screenWidth = MediaQuery.of(context).size.width;
    final logoSize = screenWidth * 0.42;

    return AnimatedBuilder(
      animation: _bottomController,
      builder: (context, _) => IgnorePointer(
        ignoring: widget.isExiting,
        child: AnimatedOpacity(
          duration: const Duration(milliseconds: 400),
          opacity: widget.isExiting ? 0.0 : 1.0,
          child: ColoredBox(
            color: _bg,
            child: SizedBox.expand(
              child: Stack(
                children: [
                  Center(
                    child: Image.asset(
                      'assets/images/logo.png',
                      width: logoSize,
                      height: logoSize,
                      fit: BoxFit.contain,
                    ),
                  ),
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: bottomPadding + 48,
                    child: Opacity(
                      opacity: _bottomOpacity.value,
                      child: Transform.translate(
                        offset: Offset(0, _bottomSlideY.value),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text(
                              'JustScroll',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                                letterSpacing: -0.3,
                                decoration: TextDecoration.none,
                                height: 1,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'Scroll. Discover. Repeat.',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w400,
                                color: Colors.white.withOpacity(0.35),
                                letterSpacing: 1.2,
                                decoration: TextDecoration.none,
                              ),
                            ),
                          ],
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
    );
  }
}