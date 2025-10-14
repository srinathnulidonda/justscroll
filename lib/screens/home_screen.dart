// lib/screens/home_screen.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:manga_app/screens/auth/login_screen.dart';
import 'package:manga_app/screens/manga_list_screen.dart';
import 'package:manga_app/screens/favorites_screen.dart';
import 'package:manga_app/screens/profile_screen.dart';
import 'package:manga_app/screens/admin_add_manga_screen.dart'; // Add this import
import 'package:manga_app/services/firebase_service.dart';
import 'package:manga_app/utils/theme_provider.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _selectedIndex = 0;
  final _firebaseService = FirebaseService();

  final List<Widget> _screens = [
    const MangaListScreen(),
    const FavoritesScreen(),
    const ProfileScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() => _selectedIndex = index);
  }

  Future<void> _signOut() async {
    try {
      await _firebaseService.signOut();
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const LoginScreen()),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error signing out: ${e.toString()}')),
        );
      }
    }
  }

  bool get _isAdmin =>
      FirebaseAuth.instance.currentUser?.email ==
      'srinathnani09@gmail.com'; // Replace with your admin email

  @override
  Widget build(BuildContext context) {
    final themeProvider = ref.watch(themeProviderNotifier);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Manga Reader',
          style: TextStyle(
            shadows: [Shadow(color: Colors.black26, offset: Offset(1, 1))],
          ),
        ),
        actions: [
          if (_isAdmin)
            IconButton(
              icon: const Icon(Icons.admin_panel_settings),
              onPressed:
                  () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const AdminAddMangaScreen(),
                    ),
                  ),
            ),
          IconButton(
            icon: Icon(
              themeProvider.themeMode == ThemeMode.dark
                  ? Icons.light_mode
                  : Icons.dark_mode,
            ),
            onPressed: () => themeProvider.toggleTheme(),
          ),
          IconButton(icon: const Icon(Icons.logout), onPressed: _signOut),
        ],
      ),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: _screens[_selectedIndex],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: _onItemTapped,
        animationDuration: const Duration(milliseconds: 300),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.book),
            selectedIcon: Icon(Icons.book, color: Colors.blueAccent),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.favorite_border),
            selectedIcon: Icon(Icons.favorite, color: Colors.redAccent),
            label: 'Favorites',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person, color: Colors.blueAccent),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
