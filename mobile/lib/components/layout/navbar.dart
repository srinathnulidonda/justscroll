// lib/components/layout/navbar.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:justscroll/stores/auth_store.dart';
import 'package:justscroll/stores/theme_store.dart';
import 'package:justscroll/stores/toast_store.dart';

class AppNavbar extends ConsumerStatefulWidget {
  const AppNavbar({super.key});

  @override
  ConsumerState<AppNavbar> createState() => _AppNavbarState();
}

class _AppNavbarState extends ConsumerState<AppNavbar> {
  bool _searchOpen = false;
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _handleSearch() {
    final q = _searchController.text.trim();
    if (q.isNotEmpty) {
      context.go('/search?q=${Uri.encodeComponent(q)}');
      _searchController.clear();
      setState(() => _searchOpen = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final auth = ref.watch(authStoreProvider);
    final themeNotifier = ref.read(themeNotifierProvider.notifier);
    final isDark = theme.brightness == Brightness.dark;
    final isWide = MediaQuery.of(context).size.width >= 768;

    return Container(
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor.withOpacity(0.9),
        border: Border(bottom: BorderSide(color: theme.colorScheme.outline.withOpacity(0.3))),
      ),
      child: SafeArea(
        bottom: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              height: 56,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => context.go('/'),
                      child: Image.asset('assets/images/logo.png', height: 28, fit: BoxFit.contain, errorBuilder: (_, __, ___) => Text('JustScroll', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: theme.colorScheme.primary))),
                    ),
                    if (isWide) ...[
                      const SizedBox(width: 24),
                      Expanded(
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 400),
                          child: SizedBox(
                            height: 36,
                            child: TextField(
                              controller: _searchController,
                              onSubmitted: (_) => _handleSearch(),
                              style: const TextStyle(fontSize: 14),
                              decoration: InputDecoration(
                                hintText: 'Search manga, comics, manhwa...',
                                prefixIcon: const Icon(Icons.search, size: 18),
                                suffixIcon: _searchController.text.isNotEmpty
                                    ? IconButton(icon: const Icon(Icons.close, size: 16), onPressed: () { _searchController.clear(); setState(() {}); })
                                    : null,
                                contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 12),
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                                filled: true,
                                fillColor: theme.colorScheme.surfaceContainerHighest.withOpacity(0.5),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ] else
                      const Spacer(),
                    if (!isWide)
                      _NavIconButton(
                        icon: _searchOpen ? Icons.close : Icons.search,
                        active: _searchOpen,
                        onTap: () => setState(() => _searchOpen = !_searchOpen),
                      ),
                    _NavIconButton(
                      icon: isDark ? Icons.wb_sunny_outlined : Icons.dark_mode_outlined,
                      onTap: () => themeNotifier.toggle(),
                      tooltip: isDark ? 'Light mode' : 'Dark mode',
                    ),
                    if (auth.isAuthenticated) ...[
                      const SizedBox(width: 4),
                      _UserMenuButton(username: auth.user?.username ?? 'U'),
                    ] else ...[
                      if (isWide) ...[
                        const SizedBox(width: 4),
                        TextButton(onPressed: () => context.go('/login'), child: Text('Sign in', style: TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.7)))),
                        const SizedBox(width: 4),
                        FilledButton(onPressed: () => context.go('/register'), child: const Text('Sign up')),
                      ] else ...[
                        const SizedBox(width: 4),
                        _NavIconButton(icon: Icons.person_outline, onTap: () => context.go('/login')),
                      ],
                    ],
                  ],
                ),
              ),
            ),
            if (_searchOpen && !isWide)
              Container(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                child: SizedBox(
                  height: 40,
                  child: TextField(
                    controller: _searchController,
                    autofocus: true,
                    onSubmitted: (_) => _handleSearch(),
                    style: const TextStyle(fontSize: 14),
                    decoration: InputDecoration(
                      hintText: 'Search manga...',
                      prefixIcon: const Icon(Icons.search, size: 18),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: theme.colorScheme.outline.withOpacity(0.3))),
                      filled: true,
                      fillColor: theme.colorScheme.surfaceContainerHighest.withOpacity(0.5),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _NavIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final bool active;
  final String? tooltip;

  const _NavIconButton({required this.icon, required this.onTap, this.active = false, this.tooltip});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final w = Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2),
      child: Material(
        color: active ? theme.colorScheme.primary.withOpacity(0.1) : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(8),
          child: SizedBox(
            width: 36,
            height: 36,
            child: Icon(icon, size: 20, color: active ? theme.colorScheme.primary : theme.colorScheme.onSurface.withOpacity(0.6)),
          ),
        ),
      ),
    );
    if (tooltip != null) return Tooltip(message: tooltip!, child: w);
    return w;
  }
}

class _UserMenuButton extends ConsumerWidget {
  final String username;
  const _UserMenuButton({required this.username});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    return PopupMenuButton<String>(
      offset: const Offset(0, 44),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      onSelected: (value) {
        switch (value) {
          case 'bookmarks': context.go('/bookmarks');
          case 'history': context.go('/history');
          case 'profile': context.go('/profile');
          case 'logout':
            ref.read(authStoreProvider.notifier).logout();
            ref.read(toastProvider.notifier).info('Signed out');
            context.go('/');
        }
      },
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: theme.colorScheme.primary.withOpacity(0.1),
          shape: BoxShape.circle,
        ),
        child: Center(
          child: Text(
            username.isNotEmpty ? username[0].toUpperCase() : 'U',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: theme.colorScheme.primary),
          ),
        ),
      ),
      itemBuilder: (_) => [
        PopupMenuItem(enabled: false, child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(username, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
            const SizedBox(height: 2),
          ],
        )),
        const PopupMenuDivider(),
        const PopupMenuItem(value: 'bookmarks', child: _MenuRow(icon: Icons.bookmark_outline, label: 'Bookmarks')),
        const PopupMenuItem(value: 'history', child: _MenuRow(icon: Icons.history, label: 'History')),
        const PopupMenuItem(value: 'profile', child: _MenuRow(icon: Icons.person_outline, label: 'Profile')),
        const PopupMenuDivider(),
        PopupMenuItem(value: 'logout', child: _MenuRow(icon: Icons.logout, label: 'Sign out', destructive: true)),
      ],
    );
  }
}

class _MenuRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool destructive;
  const _MenuRow({required this.icon, required this.label, this.destructive = false});

  @override
  Widget build(BuildContext context) {
    final color = destructive ? Theme.of(context).colorScheme.error : Theme.of(context).colorScheme.onSurface.withOpacity(0.7);
    return Row(children: [
      Icon(icon, size: 18, color: color),
      const SizedBox(width: 10),
      Text(label, style: TextStyle(fontSize: 14, color: destructive ? Theme.of(context).colorScheme.error : null)),
    ]);
  }
}