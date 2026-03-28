// lib/components/layout/mobile_nav.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:justscroll/stores/auth_store.dart';

class MobileNav extends ConsumerWidget {
  const MobileNav({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final auth = ref.watch(authStoreProvider);
    final location = GoRouterState.of(context).matchedLocation;

    final items = [
      _NavItem(
        path: '/',
        icon: Icons.home_outlined,
        activeIcon: Icons.home_rounded,
        label: 'Home',
      ),
      _NavItem(
        path: '/discover',
        icon: Icons.explore_outlined,
        activeIcon: Icons.explore_rounded,
        label: 'Discover',
        matchPaths: ['/discover', '/search'],
      ),
      _NavItem(
        path: '/bookmarks',
        icon: Icons.bookmark_outline_rounded,
        activeIcon: Icons.bookmark_rounded,
        label: 'Library',
        requireAuth: true,
        matchPaths: ['/bookmarks', '/history'],
      ),
      _NavItem(
        path: auth.isAuthenticated ? '/profile' : '/login',
        icon: Icons.person_outline_rounded,
        activeIcon: Icons.person_rounded,
        label: auth.isAuthenticated ? 'Profile' : 'Account',
        matchPaths: ['/profile', '/login', '/register'],
      ),
    ];

    int activeIndex = 0;
    for (int i = 0; i < items.length; i++) {
      final item = items[i];
      if (location == item.path ||
          (item.matchPaths?.any((p) => location.startsWith(p)) ?? false)) {
        activeIndex = i;
        break;
      }
    }

    return RepaintBoundary(
      child: Container(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
        child: SafeArea(
          top: false,
          child: Container(
            height: 56,
            decoration: BoxDecoration(
              color: theme.scaffoldBackgroundColor,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: theme.colorScheme.outline.withOpacity(0.12),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(
                    theme.brightness == Brightness.dark ? 0.3 : 0.06,
                  ),
                  blurRadius: 16,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: items.asMap().entries.map((entry) {
                final i = entry.key;
                final item = entry.value;
                final isActive = i == activeIndex;

                return Expanded(
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () {
                      if (isActive) return;
                      if (item.requireAuth && !auth.isAuthenticated) {
                        context.go('/login?redirect=${item.path}');
                        return;
                      }
                      context.go(item.path);
                    },
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          isActive ? item.activeIcon : item.icon,
                          size: 22,
                          color: isActive
                              ? theme.colorScheme.primary
                              : theme.colorScheme.onSurface.withOpacity(0.35),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          item.label,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight:
                                isActive ? FontWeight.w600 : FontWeight.w500,
                            color: isActive
                                ? theme.colorScheme.primary
                                : theme.colorScheme.onSurface.withOpacity(0.35),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.clip,
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem {
  final String path;
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final bool requireAuth;
  final List<String>? matchPaths;

  const _NavItem({
    required this.path,
    required this.icon,
    required this.activeIcon,
    required this.label,
    this.requireAuth = false,
    this.matchPaths,
  });
}