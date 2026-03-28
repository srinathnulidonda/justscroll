// lib/components/layout/layout.dart
import 'package:flutter/material.dart';
import 'package:justscroll/components/layout/navbar.dart';
import 'package:justscroll/components/layout/mobile_nav.dart';

class AppLayout extends StatelessWidget {
  final Widget child;
  const AppLayout({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width >= 768;

    return Scaffold(
      body: Column(
        children: [
          const RepaintBoundary(child: AppNavbar()),
          Expanded(
            child: RepaintBoundary(child: child),
          ),
        ],
      ),
      bottomNavigationBar: isWide ? null : const MobileNav(),
    );
  }
}