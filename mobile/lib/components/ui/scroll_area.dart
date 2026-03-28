// lib/components/ui/scroll_area.dart
import 'package:flutter/material.dart';

class AppScrollArea extends StatelessWidget {
  final Widget child;
  final Axis scrollDirection;
  final ScrollController? controller;
  final EdgeInsetsGeometry? padding;
  final ScrollPhysics? physics;

  const AppScrollArea({
    super.key,
    required this.child,
    this.scrollDirection = Axis.vertical,
    this.controller,
    this.padding,
    this.physics,
  });

  @override
  Widget build(BuildContext context) {
    return RawScrollbar(
      thumbColor: Theme.of(context).colorScheme.outline.withOpacity(0.3),
      radius: const Radius.circular(20),
      thickness: 4,
      controller: controller,
      child: SingleChildScrollView(
        controller: controller,
        scrollDirection: scrollDirection,
        padding: padding,
        physics: physics ?? const BouncingScrollPhysics(),
        child: child,
      ),
    );
  }
}