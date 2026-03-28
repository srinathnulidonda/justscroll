// lib/pages/user/profile.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:justscroll/lib/api.dart';
import 'package:justscroll/lib/utils.dart' as utils;
import 'package:justscroll/models/user.dart';
import 'package:justscroll/stores/auth_store.dart';
import 'package:justscroll/stores/theme_store.dart';
import 'package:justscroll/stores/reader_store.dart';
import 'package:justscroll/stores/toast_store.dart';
import 'package:justscroll/components/common/optimized_image.dart';
import 'package:justscroll/components/ui/button.dart';

final _profileBookmarksProvider = FutureProvider<BookmarkListResponse>((ref) async {
  final auth = ref.watch(authStoreProvider);
  if (!auth.isAuthenticated) return const BookmarkListResponse(data: [], total: 0);
  final data = await ApiClient.instance.getBookmarks();
  return BookmarkListResponse.fromJson(data);
});

final _profileHistoryProvider = FutureProvider<HistoryListResponse>((ref) async {
  final auth = ref.watch(authStoreProvider);
  if (!auth.isAuthenticated) return const HistoryListResponse(data: [], total: 0);
  final data = await ApiClient.instance.getHistory();
  return HistoryListResponse.fromJson(data);
});

class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final auth = ref.watch(authStoreProvider);
    final user = auth.user;
    if (user == null) return const SizedBox.shrink();

    final bookmarks = ref.watch(_profileBookmarksProvider);
    final history = ref.watch(_profileHistoryProvider);
    final themeNotifier = ref.read(themeNotifierProvider.notifier);
    final reader = ref.watch(readerStoreProvider);
    final isDark = theme.brightness == Brightness.dark;

    final bookmarkCount = bookmarks.valueOrNull?.total ?? 0;
    final historyCount = history.valueOrNull?.total ?? 0;
    final recentHistory = (history.valueOrNull?.data ?? []).take(4).toList();
    final recentBookmarks = (bookmarks.valueOrNull?.data ?? []).take(6).toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _ProfileHeader(user: user, bookmarkCount: bookmarkCount, historyCount: historyCount),
          const SizedBox(height: 16),
          Row(
            children: [
              _StatCard(icon: Icons.bookmark, label: 'Bookmarks', value: bookmarkCount.toString(), color: theme.colorScheme.primary, onTap: () => context.go('/bookmarks')),
              const SizedBox(width: 10),
              _StatCard(icon: Icons.schedule, label: 'Chapters', value: historyCount.toString(), color: const Color(0xFF10B981), onTap: () => context.go('/history')),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _QuickAction(icon: Icons.bookmark_outline, label: 'Library', color: theme.colorScheme.primary, onTap: () => context.go('/bookmarks')),
              _QuickAction(icon: Icons.history, label: 'History', color: const Color(0xFFF59E0B), onTap: () => context.go('/history')),
              _QuickAction(icon: Icons.trending_up, label: 'Popular', color: const Color(0xFF10B981), onTap: () => context.go('/discover')),
              _QuickAction(icon: Icons.flash_on, label: 'Latest', color: const Color(0xFF8B5CF6), onTap: () => context.go('/discover?tab=latest')),
            ],
          ),
          if (recentHistory.isNotEmpty) ...[
            const SizedBox(height: 16),
            _SectionCard(
              title: 'Continue Reading',
              action: historyCount > 4 ? () => context.go('/history') : null,
              child: Column(
                children: recentHistory.map((entry) => _ContinueCard(entry: entry, onTap: () => context.go('/read/${entry.chapterId}?manga=${entry.mangaId}'))).toList(),
              ),
            ),
          ],
          if (recentBookmarks.isNotEmpty) ...[
            const SizedBox(height: 12),
            _SectionCard(
              title: 'Saved Manga',
              action: bookmarkCount > 6 ? () => context.go('/bookmarks') : null,
              child: SizedBox(
                height: 120,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  itemCount: recentBookmarks.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (_, i) {
                    final bk = recentBookmarks[i];
                    return GestureDetector(
                      onTap: () => context.go('/manga/${bk.mangaId}'),
                      child: SizedBox(
                        width: 56,
                        child: Column(
                          children: [
                            AspectRatio(aspectRatio: 2 / 3, child: ClipRRect(borderRadius: BorderRadius.circular(8), child: OptimizedImage(src: bk.coverUrl, fit: BoxFit.cover, borderRadius: BorderRadius.circular(8)))),
                            const SizedBox(height: 4),
                            Text(bk.mangaTitle, maxLines: 1, overflow: TextOverflow.ellipsis, textAlign: TextAlign.center, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w500)),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
          const SizedBox(height: 12),
          _SectionCard(
            title: 'Appearance',
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  _ThemeOption(icon: Icons.wb_sunny, label: 'Light', active: !isDark, onTap: () => themeNotifier.setTheme(ThemeMode.light)),
                  const SizedBox(width: 8),
                  _ThemeOption(icon: Icons.dark_mode, label: 'Dark', active: isDark, onTap: () => themeNotifier.setTheme(ThemeMode.dark)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          _SectionCard(
            title: 'Reader Settings',
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Image Quality', style: TextStyle(fontSize: 11, color: theme.colorScheme.onSurface.withOpacity(0.5))),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      _SettingChip(icon: Icons.image, label: 'High', active: reader.quality == 'data', onTap: () => ref.read(readerStoreProvider.notifier).setQuality('data')),
                      const SizedBox(width: 8),
                      _SettingChip(icon: Icons.flash_on, label: 'Saver', active: reader.quality == 'dataSaver', onTap: () => ref.read(readerStoreProvider.notifier).setQuality('dataSaver')),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text('Reading Mode', style: TextStyle(fontSize: 11, color: theme.colorScheme.onSurface.withOpacity(0.5))),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      _SettingChip(icon: Icons.view_column, label: 'Page', active: reader.mode == 'single', onTap: () => ref.read(readerStoreProvider.notifier).setMode('single')),
                      const SizedBox(width: 8),
                      _SettingChip(icon: Icons.view_agenda, label: 'Scroll', active: reader.mode == 'continuous', onTap: () => ref.read(readerStoreProvider.notifier).setMode('continuous')),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          _SectionCard(
            title: 'Account',
            child: Column(
              children: [
                _MenuItem(icon: Icons.person_outline, label: 'Account Details', desc: user.email ?? 'Manage your account', onTap: () {}),
                _MenuItem(icon: Icons.shield_outlined, label: 'Privacy & Security', desc: 'Password, sessions', onTap: () {}),
              ],
            ),
          ),
          const SizedBox(height: 12),
          _SectionCard(
            child: _MenuItem(
              icon: Icons.logout,
              label: 'Sign Out',
              desc: 'Signed in as ${user.username}',
              destructive: true,
              onTap: () {
                ref.read(authStoreProvider.notifier).logout();
                ref.read(toastProvider.notifier).info('Signed out successfully');
                context.go('/');
              },
            ),
          ),
          const SizedBox(height: 24),
          Image.asset('assets/images/logo.png', height: 20, opacity: const AlwaysStoppedAnimation(0.4), errorBuilder: (_, __, ___) => const SizedBox.shrink()),
          const SizedBox(height: 4),
          Text('v1.0.0 · Powered by MangaDex, Jikan & ComicVine', style: TextStyle(fontSize: 10, color: theme.colorScheme.onSurface.withOpacity(0.2))),
          const SizedBox(height: 40),
        ],
      ),
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  final AppUser user;
  final int bookmarkCount;
  final int historyCount;
  const _ProfileHeader({required this.user, required this.bookmarkCount, required this.historyCount});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.colorScheme.outline.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Container(
            width: 56, height: 56,
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [theme.colorScheme.primary, theme.colorScheme.primary.withOpacity(0.7)]),
              shape: BoxShape.circle,
            ),
            child: Center(child: Text(user.username.isNotEmpty ? user.username.substring(0, 2).toUpperCase() : 'U', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: theme.colorScheme.onPrimary))),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(user.username, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: theme.colorScheme.onSurface)),
                if (user.email != null) Text(user.email!, style: TextStyle(fontSize: 12, color: theme.colorScheme.onSurface.withOpacity(0.5))),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(color: theme.colorScheme.primary.withOpacity(0.05), borderRadius: BorderRadius.circular(10), border: Border.all(color: theme.colorScheme.primary.withOpacity(0.1))),
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    Icon(Icons.shield, size: 10, color: theme.colorScheme.primary),
                    const SizedBox(width: 4),
                    Text('Member', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: theme.colorScheme.primary)),
                  ]),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;
  final VoidCallback onTap;
  const _StatCard({required this.icon, required this.label, required this.value, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(color: theme.colorScheme.surface, borderRadius: BorderRadius.circular(14), border: Border.all(color: theme.colorScheme.outline.withOpacity(0.2))),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(width: 32, height: 32, decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(10)), child: Icon(icon, size: 16, color: color)),
              const SizedBox(height: 8),
              Text(value, style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: theme.colorScheme.onSurface)),
              Text(label, style: TextStyle(fontSize: 12, color: theme.colorScheme.onSurface.withOpacity(0.5))),
            ],
          ),
        ),
      ),
    );
  }
}

class _QuickAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  const _QuickAction({required this.icon, required this.label, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 3),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(color: theme.colorScheme.surface, borderRadius: BorderRadius.circular(12), border: Border.all(color: theme.colorScheme.outline.withOpacity(0.2))),
          child: Column(
            children: [
              Container(width: 32, height: 32, decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(10)), child: Icon(icon, size: 16, color: color)),
              const SizedBox(height: 6),
              Text(label, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w500, color: theme.colorScheme.onSurface)),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String? title;
  final VoidCallback? action;
  final Widget child;
  const _SectionCard({this.title, this.action, required this.child});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(color: theme.colorScheme.surface, borderRadius: BorderRadius.circular(14), border: Border.all(color: theme.colorScheme.outline.withOpacity(0.2))),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 12, 14, 4),
              child: Row(
                children: [
                  Text(title!, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: theme.colorScheme.onSurface.withOpacity(0.5), letterSpacing: 0.5)),
                  const Spacer(),
                  if (action != null) GestureDetector(onTap: action, child: Text('See all', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: theme.colorScheme.primary))),
                ],
              ),
            ),
          child,
        ],
      ),
    );
  }
}

class _ContinueCard extends StatelessWidget {
  final HistoryEntry entry;
  final VoidCallback onTap;
  const _ContinueCard({required this.entry, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            children: [
              Container(
                width: 36, height: 48,
                decoration: BoxDecoration(color: theme.colorScheme.primary.withOpacity(0.05), borderRadius: BorderRadius.circular(6)),
                child: Icon(Icons.menu_book, size: 16, color: theme.colorScheme.primary.withOpacity(0.4)),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(entry.mangaTitle, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
                    Row(
                      children: [
                        if (entry.chapterNumber != null) Text('Ch. ${entry.chapterNumber}', style: TextStyle(fontSize: 11, color: theme.colorScheme.onSurface.withOpacity(0.4))),
                        if (entry.chapterNumber != null) Text(' · ', style: TextStyle(fontSize: 11, color: theme.colorScheme.onSurface.withOpacity(0.2))),
                        Text('p.${entry.pageNumber}', style: TextStyle(fontSize: 11, color: theme.colorScheme.onSurface.withOpacity(0.4))),
                        Text(' · ', style: TextStyle(fontSize: 11, color: theme.colorScheme.onSurface.withOpacity(0.2))),
                        Text(utils.formatDate(entry.updatedAt), style: TextStyle(fontSize: 11, color: theme.colorScheme.onSurface.withOpacity(0.4))),
                      ],
                    ),
                  ],
                ),
              ),
              Icon(Icons.arrow_forward, size: 14, color: theme.colorScheme.primary.withOpacity(0.5)),
            ],
          ),
        ),
      ),
    );
  }
}

class _MenuItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String desc;
  final bool destructive;
  final VoidCallback onTap;
  const _MenuItem({required this.icon, required this.label, required this.desc, this.destructive = false, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = destructive ? theme.colorScheme.error : theme.colorScheme.onSurface;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(
            children: [
              Container(
                width: 34, height: 34,
                decoration: BoxDecoration(
                  color: destructive ? theme.colorScheme.error.withOpacity(0.1) : theme.colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, size: 18, color: destructive ? theme.colorScheme.error : theme.colorScheme.onSurface.withOpacity(0.5)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(label, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: color)),
                    Text(desc, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 11, color: theme.colorScheme.onSurface.withOpacity(0.4))),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, size: 18, color: theme.colorScheme.onSurface.withOpacity(0.2)),
            ],
          ),
        ),
      ),
    );
  }
}

class _ThemeOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool active;
  final VoidCallback onTap;
  const _ThemeOption({required this.icon, required this.label, required this.active, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(width: 2, color: active ? theme.colorScheme.primary : theme.colorScheme.outline.withOpacity(0.2)),
            color: active ? theme.colorScheme.primary.withOpacity(0.05) : Colors.transparent,
          ),
          child: Column(
            children: [
              Container(
                width: 36, height: 36,
                decoration: BoxDecoration(color: active ? theme.colorScheme.primary : theme.colorScheme.surfaceContainerHighest, borderRadius: BorderRadius.circular(10)),
                child: Icon(icon, size: 18, color: active ? theme.colorScheme.onPrimary : theme.colorScheme.onSurface.withOpacity(0.5)),
              ),
              const SizedBox(height: 6),
              Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: active ? theme.colorScheme.primary : theme.colorScheme.onSurface.withOpacity(0.5))),
            ],
          ),
        ),
      ),
    );
  }
}

class _SettingChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool active;
  final VoidCallback onTap;
  const _SettingChip({required this.icon, required this.label, required this.active, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: active ? theme.colorScheme.primary : theme.colorScheme.outline.withOpacity(0.2)),
            color: active ? theme.colorScheme.primary.withOpacity(0.05) : Colors.transparent,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 16, color: active ? theme.colorScheme.primary : theme.colorScheme.onSurface.withOpacity(0.5)),
              const SizedBox(width: 6),
              Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: active ? theme.colorScheme.primary : theme.colorScheme.onSurface.withOpacity(0.5))),
            ],
          ),
        ),
      ),
    );
  }
}