// lib/app.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:justscroll/stores/auth_store.dart';
import 'package:justscroll/stores/theme_store.dart';
import 'package:justscroll/stores/toast_store.dart';
import 'package:justscroll/theme/theme.dart';
import 'package:justscroll/components/common/toast.dart';
import 'package:justscroll/components/layout/layout.dart';
import 'package:justscroll/pages/splash_screen.dart';
import 'package:justscroll/pages/browse/home.dart';
import 'package:justscroll/pages/browse/discover.dart';
import 'package:justscroll/pages/browse/search.dart';
import 'package:justscroll/pages/manga/manga_detail.dart';
import 'package:justscroll/pages/manga/reader_page.dart';
import 'package:justscroll/pages/auth/login.dart';
import 'package:justscroll/pages/auth/register.dart';
import 'package:justscroll/pages/user/bookmarks.dart';
import 'package:justscroll/pages/user/history.dart';
import 'package:justscroll/pages/user/profile.dart';
import 'package:justscroll/pages/not_found.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _shellNavigatorKey = GlobalKey<NavigatorState>();

final navigationHistoryProvider =
    StateNotifierProvider<NavigationHistoryNotifier, List<String>>(
  (ref) => NavigationHistoryNotifier(),
);

class NavigationHistoryNotifier extends StateNotifier<List<String>> {
  NavigationHistoryNotifier() : super(['/']);

  void push(String path) {
    if (state.isEmpty || state.last != path) {
      state = [...state, path];
    }
  }

  String? pop() {
    if (state.length <= 1) return null;
    final newState = [...state];
    newState.removeLast();
    state = newState;
    return state.last;
  }

  bool get canGoBack => state.length > 1;
}

CustomTransitionPage<void> _fadeTransition(
    GoRouterState state, Widget child) {
  return CustomTransitionPage(
    key: state.pageKey,
    child: child,
    transitionDuration: const Duration(milliseconds: 180),
    reverseTransitionDuration: const Duration(milliseconds: 120),
    transitionsBuilder: (_, animation, __, child) {
      return FadeTransition(
        opacity: CurvedAnimation(
          parent: animation,
          curve: Curves.easeOut,
        ),
        child: child,
      );
    },
  );
}

final routerProvider = Provider<GoRouter>((ref) {
  final history = ref.read(navigationHistoryProvider.notifier);

  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/',
    redirect: (context, state) {
      final authState = ref.read(authStoreProvider);
      final isAuth = authState.isAuthenticated;
      final protectedPaths = ['/bookmarks', '/history', '/profile'];
      final isProtected =
          protectedPaths.any((p) => state.matchedLocation.startsWith(p));
      if (isProtected && !isAuth) {
        return '/login?redirect=${state.matchedLocation}';
      }
      final fullPath = state.uri.toString();
      history.push(fullPath);
      return null;
    },
    errorBuilder: (context, state) => const NotFoundPage(),
    routes: [
      ShellRoute(
        navigatorKey: _shellNavigatorKey,
        builder: (context, state, child) => AppLayout(child: child),
        routes: [
          GoRoute(
            path: '/',
            pageBuilder: (context, state) =>
                _fadeTransition(state, const HomePage()),
          ),
          GoRoute(
            path: '/discover',
            pageBuilder: (context, state) =>
                _fadeTransition(state, const DiscoverPage()),
          ),
          GoRoute(
            path: '/search',
            pageBuilder: (context, state) => _fadeTransition(
              state,
              SearchPage(query: state.uri.queryParameters['q'] ?? ''),
            ),
          ),
          GoRoute(
            path: '/manga/:id',
            pageBuilder: (context, state) => _fadeTransition(
              state,
              MangaDetailPage(id: state.pathParameters['id']!),
            ),
          ),
          GoRoute(
            path: '/login',
            pageBuilder: (context, state) => _fadeTransition(
              state,
              LoginPage(redirect: state.uri.queryParameters['redirect']),
            ),
          ),
          GoRoute(
            path: '/register',
            pageBuilder: (context, state) => _fadeTransition(
              state,
              RegisterPage(redirect: state.uri.queryParameters['redirect']),
            ),
          ),
          GoRoute(
            path: '/bookmarks',
            pageBuilder: (context, state) =>
                _fadeTransition(state, const BookmarksPage()),
          ),
          GoRoute(
            path: '/history',
            pageBuilder: (context, state) =>
                _fadeTransition(state, const HistoryPage()),
          ),
          GoRoute(
            path: '/profile',
            pageBuilder: (context, state) =>
                _fadeTransition(state, const ProfilePage()),
          ),
        ],
      ),
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: '/read/:chapterId',
        pageBuilder: (context, state) => _fadeTransition(
          state,
          ReaderPage(
            chapterId: state.pathParameters['chapterId']!,
            mangaId: state.uri.queryParameters['manga'] ?? '',
          ),
        ),
      ),
    ],
  );
});

class JustScrollApp extends ConsumerStatefulWidget {
  const JustScrollApp({super.key});

  @override
  ConsumerState<JustScrollApp> createState() => _JustScrollAppState();
}

class _JustScrollAppState extends ConsumerState<JustScrollApp>
    with WidgetsBindingObserver {
  bool _showSplash = true;
  bool _splashExiting = false;
  DateTime? _lastBackPress;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Future<bool> didPopRoute() async {
    if (_showSplash) return true;
    _handleBackPress();
    return true;
  }

  void _onSplashComplete() {
    setState(() => _splashExiting = true);
    Future.delayed(const Duration(milliseconds: 400), () {
      if (mounted) setState(() => _showSplash = false);
    });
  }

  void _handleBackPress() {
    final router = ref.read(routerProvider);
    final history = ref.read(navigationHistoryProvider.notifier);
    final currentLocation =
        router.routerDelegate.currentConfiguration.uri.toString();

    if (history.canGoBack) {
      final previousPath = history.pop();
      if (previousPath != null && previousPath != currentLocation) {
        router.go(previousPath);
        return;
      }
    }

    if (currentLocation != '/') {
      router.go('/');
      return;
    }

    final now = DateTime.now();
    if (_lastBackPress == null ||
        now.difference(_lastBackPress!) > const Duration(seconds: 2)) {
      _lastBackPress = now;
      ref.read(toastProvider.notifier).info('Press back again to exit');
      return;
    }

    SystemNavigator.pop();
  }

  @override
  Widget build(BuildContext context) {
    final router = ref.watch(routerProvider);
    final themeMode = ref.watch(themeModeProvider);

    return MaterialApp.router(
      title: 'JustScroll',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: themeMode,
      routerConfig: router,
      builder: (context, child) {
        return Stack(
          children: [
            child!,
            const ToastOverlay(),
            if (_showSplash)
              SplashScreen(
                onComplete: _onSplashComplete,
                isExiting: _splashExiting,
              ),
          ],
        );
      },
    );
  }
}