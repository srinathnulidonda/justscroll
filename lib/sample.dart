// lib/main.dart
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'firebase_options.dart';
import 'package:manga_app/screens/splash_screen.dart';
import 'package:manga_app/utils/theme_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await FirebaseAppCheck.instance.activate(
    androidProvider:
        AndroidProvider.debug, // Use 'playIntegrity' for production
  );

  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeProvider = ref.watch(themeProviderNotifier);

    return MaterialApp(
      title: 'Manga Reader',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blueAccent,
          primary: Colors.blueAccent,
          secondary: Colors.redAccent,
          brightness: Brightness.light,
        ),
        scaffoldBackgroundColor: Colors.grey[100],
        textTheme: GoogleFonts.poppinsTextTheme(Theme.of(context).textTheme),
        useMaterial3: true,
        cardTheme: CardTheme(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        appBarTheme: const AppBarTheme(
          elevation: 4,
          shadowColor: Colors.black26,
        ),
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blueAccent,
          primary: Colors.blueAccent,
          secondary: Colors.redAccent,
          brightness: Brightness.dark,
        ),
        scaffoldBackgroundColor: Colors.grey[900],
        textTheme: GoogleFonts.poppinsTextTheme(
          Theme.of(context).textTheme.apply(
            bodyColor: Colors.white,
            displayColor: Colors.white,
          ),
        ),
        useMaterial3: true,
        cardTheme: CardTheme(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        appBarTheme: const AppBarTheme(
          elevation: 4,
          shadowColor: Colors.black26,
        ),
      ),
      themeMode: themeProvider.themeMode,
      home: const SplashScreen(),
    );
  }
}


// lib/models/chapter.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class Chapter {
  final String id;
  final String mangaId;
  final String title;
  final int number;
  final DateTime releaseDate;
  final String pdfUrl;

  Chapter({
    required this.id,
    required this.mangaId,
    required this.title,
    required this.number,
    required this.releaseDate,
    required this.pdfUrl,
  });

  factory Chapter.fromMap(Map<String, dynamic> map, String id) {
    return Chapter(
      id: id,
      mangaId: map['mangaId'] ?? '',
      title: map['title'] ?? '',
      number: map['number'] ?? 0,
      releaseDate:
          map['releaseDate'] != null
              ? (map['releaseDate'] as Timestamp).toDate()
              : DateTime.now(),
      pdfUrl: map['pdfUrl'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'mangaId': mangaId,
      'title': title,
      'number': number,
      'releaseDate': releaseDate,
      'pdfUrl': pdfUrl,
    };
  }
}


//lib/models/manga.dart

import 'package:cloud_firestore/cloud_firestore.dart';

class Manga {
  final String id;
  final String title;
  final String description;
  final String coverUrl;
  final List<String> genres;
  final String author;
  final DateTime lastUpdated;
  final bool isCompleted;

  Manga({
    required this.id,
    required this.title,
    required this.description,
    required this.coverUrl,
    required this.genres,
    required this.author,
    required this.lastUpdated,
    required this.isCompleted,
  });

  factory Manga.fromMap(Map<String, dynamic> map, String id) {
    assert(map['title'] != null, 'Title is required');
    assert(map['coverUrl'] != null, 'Cover URL is required');

    return Manga(
      id: id,
      title: map['title'] as String,
      description: map['description'] as String? ?? '',
      coverUrl: map['coverUrl'] as String,
      genres: List<String>.from(map['genres'] ?? []),
      author: map['author'] as String? ?? 'Unknown',
      lastUpdated:
          map['lastUpdated'] != null
              ? (map['lastUpdated'] as Timestamp).toDate()
              : DateTime.now(),
      isCompleted: map['isCompleted'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'coverUrl': coverUrl,
      'genres': genres,
      'author': author,
      'lastUpdated': lastUpdated,
      'isCompleted': isCompleted,
    };
  }
}


// lib/models/user_profile.dart
class UserProfile {
  final String uid;
  final String username;
  final String email;
  final String profileImageUrl;
  final List<String> favorites;
  final Map<String, int> lastReadChapter; // mangaId: chapterNumber

  UserProfile({
    required this.uid,
    required this.username,
    required this.email,
    required this.profileImageUrl,
    required this.favorites,
    required this.lastReadChapter,
  });

  factory UserProfile.fromMap(Map<String, dynamic> map, String uid) {
    return UserProfile(
      uid: uid,
      username: map['username'] ?? '',
      email: map['email'] ?? '',
      profileImageUrl: map['profileImageUrl'] ?? '',
      favorites: List<String>.from(map['favorites'] ?? []),
      lastReadChapter: Map<String, int>.from(map['lastReadChapter'] ?? {}),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'username': username,
      'email': email,
      'profileImageUrl': profileImageUrl,
      'favorites': favorites,
      'lastReadChapter': lastReadChapter,
    };
  }
}

//lib/screens/auth/login_screen.dart

import 'package:flutter/material.dart';
import 'package:manga_app/screens/auth/signup_screen.dart';
import 'package:manga_app/screens/home_screen.dart';
import 'package:manga_app/services/firebase_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _firebaseService = FirebaseService();
  bool _isLoading = false;
  bool _obscurePassword = true;

  Future<void> _login() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      try {
        await _firebaseService.signIn(
          _emailController.text.trim(),
          _passwordController.text.trim(),
        );

        if (mounted) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const HomeScreen()),
          );
        }
      } catch (e) {
        if (mounted) {
          showDialog(
            context: context,
            builder:
                (_) => AlertDialog(
                  title: const Text('Login Error'),
                  content: Text('Error: ${e.toString()}'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('OK'),
                    ),
                  ],
                ),
          );
        }
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blueAccent.withOpacity(0.1), Colors.grey[100]!],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Icon(Icons.book, size: 80, color: Colors.blueAccent),
                    const SizedBox(height: 24),
                    Text(
                      'Welcome Back',
                      style: Theme.of(context).textTheme.headlineMedium
                          ?.copyWith(fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Sign in to continue',
                      style: Theme.of(context).textTheme.bodyLarge,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 32),
                    TextFormField(
                      controller: _emailController,
                      decoration: InputDecoration(
                        labelText: 'Email',
                        prefixIcon: const Icon(Icons.email),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      keyboardType: TextInputType.emailAddress,
                      validator:
                          (value) =>
                              value!.isEmpty ? 'Please enter your email' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _passwordController,
                      decoration: InputDecoration(
                        labelText: 'Password',
                        prefixIcon: const Icon(Icons.lock),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility
                                : Icons.visibility_off,
                          ),
                          onPressed:
                              () => setState(
                                () => _obscurePassword = !_obscurePassword,
                              ),
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      obscureText: _obscurePassword,
                      validator:
                          (value) =>
                              value!.isEmpty
                                  ? 'Please enter your password'
                                  : null,
                    ),
                    const SizedBox(height: 24),
                    AnimatedScale(
                      scale: _isLoading ? 0.95 : 1.0,
                      duration: const Duration(milliseconds: 200),
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _login,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          backgroundColor: Colors.blueAccent,
                          foregroundColor: Colors.white,
                        ),
                        child:
                            _isLoading
                                ? const CircularProgressIndicator(
                                  color: Colors.white,
                                )
                                : const Text(
                                  'LOGIN',
                                  style: TextStyle(fontSize: 16),
                                ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Don't have an account? ",
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => const SignupScreen(),
                              ),
                            );
                          },
                          child: const Text(
                            'Sign Up',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.blueAccent,
                            ),
                          ),
                        ),
                      ],
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


//lib/screens/auth/signup_screen.dart

import 'package:flutter/material.dart';
import 'package:manga_app/models/user_profile.dart';
import 'package:manga_app/screens/home_screen.dart';
import 'package:manga_app/services/firebase_service.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _firebaseService = FirebaseService();
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  Future<void> _signup() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      try {
        final userCredential = await _firebaseService.signUp(
          _emailController.text.trim(),
          _passwordController.text.trim(),
        );

        final userProfile = UserProfile(
          uid: userCredential.user!.uid,
          username: _usernameController.text.trim(),
          email: _emailController.text.trim(),
          profileImageUrl: '',
          favorites: [],
          lastReadChapter: {},
        );

        await _firebaseService.createUserProfile(userProfile);

        if (mounted) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const HomeScreen()),
          );
        }
      } catch (e) {
        if (mounted) {
          showDialog(
            context: context,
            builder:
                (_) => AlertDialog(
                  title: const Text('Sign Up Error'),
                  content: Text('Error: ${e.toString()}'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('OK'),
                    ),
                  ],
                ),
          );
        }
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blueAccent.withOpacity(0.1), Colors.grey[100]!],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          'Create Account',
                          style: Theme.of(context).textTheme.headlineMedium
                              ?.copyWith(fontWeight: FontWeight.bold),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Sign up to start reading manga',
                          style: Theme.of(context).textTheme.bodyLarge,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 32),
                        TextFormField(
                          controller: _usernameController,
                          decoration: InputDecoration(
                            labelText: 'Username',
                            prefixIcon: const Icon(Icons.person),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          validator:
                              (value) =>
                                  value!.isEmpty
                                      ? 'Please enter a username'
                                      : null,
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _emailController,
                          decoration: InputDecoration(
                            labelText: 'Email',
                            prefixIcon: const Icon(Icons.email),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          keyboardType: TextInputType.emailAddress,
                          validator:
                              (value) =>
                                  value!.isEmpty
                                      ? 'Please enter your email'
                                      : null,
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _passwordController,
                          decoration: InputDecoration(
                            labelText: 'Password',
                            prefixIcon: const Icon(Icons.lock),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscurePassword
                                    ? Icons.visibility
                                    : Icons.visibility_off,
                              ),
                              onPressed:
                                  () => setState(
                                    () => _obscurePassword = !_obscurePassword,
                                  ),
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          obscureText: _obscurePassword,
                          validator: (value) {
                            if (value!.isEmpty)
                              return 'Please enter a password';
                            if (value.length < 6)
                              return 'Password must be at least 6 characters';
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _confirmPasswordController,
                          decoration: InputDecoration(
                            labelText: 'Confirm Password',
                            prefixIcon: const Icon(Icons.lock),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscureConfirmPassword
                                    ? Icons.visibility
                                    : Icons.visibility_off,
                              ),
                              onPressed:
                                  () => setState(
                                    () =>
                                        _obscureConfirmPassword =
                                            !_obscureConfirmPassword,
                                  ),
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          obscureText: _obscureConfirmPassword,
                          validator: (value) {
                            if (value!.isEmpty)
                              return 'Please confirm your password';
                            if (value != _passwordController.text)
                              return 'Passwords do not match';
                            return null;
                          },
                        ),
                        const SizedBox(height: 24),
                        AnimatedScale(
                          scale: _isLoading ? 0.95 : 1.0,
                          duration: const Duration(milliseconds: 200),
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _signup,
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              backgroundColor: Colors.blueAccent,
                              foregroundColor: Colors.white,
                            ),
                            child:
                                _isLoading
                                    ? const CircularProgressIndicator(
                                      color: Colors.white,
                                    )
                                    : const Text(
                                      'SIGN UP',
                                      style: TextStyle(fontSize: 16),
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
        ),
      ),
    );
  }
}


//lib/screens/favorites_screen.dart

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:manga_app/models/manga.dart';
import 'package:manga_app/services/firebase_service.dart';
import 'package:manga_app/widgets/manga_grid_item.dart';
import 'package:manga_app/screens/manga_detail_screen.dart';
import 'package:shimmer/shimmer.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  final FirebaseService _firebaseService = FirebaseService();

  Future<List<Manga>> _getFavorites() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return [];

    final userProfile = await _firebaseService.getUserProfile(user.uid);
    if (userProfile == null) return [];

    final List<Manga> favorites = [];
    for (final mangaId in userProfile.favorites) {
      final manga = await _firebaseService.getMangaById(mangaId);
      if (manga != null) favorites.add(manga);
    }
    return favorites;
  }

  Future<void> _removeFavorite(String mangaId) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await _firebaseService.toggleFavorite(user.uid, mangaId);
      setState(() {});
    }
  }

  Widget _buildLoadingShimmer() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.65,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
        ),
        itemCount: 6,
        itemBuilder:
            (context, index) => Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
            ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<List<Manga>>(
        future: _getFavorites(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return _buildLoadingShimmer();
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final favorites = snapshot.data ?? [];

          if (favorites.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.favorite_border,
                    size: 80,
                    color: Colors.grey,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No favorites yet',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Add manga to your favorites',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed:
                        () => Navigator.pushNamed(context, '/manga_list'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueAccent,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Browse Manga'),
                  ),
                ],
              ),
            );
          }

          return GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.65,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
            ),
            itemCount: favorites.length,
            itemBuilder: (context, index) {
              final manga = favorites[index];
              return Stack(
                children: [
                  MangaGridItem(
                    manga: manga,
                    onTap: () {
                      Navigator.of(context)
                          .push(
                            MaterialPageRoute(
                              builder: (_) => MangaDetailScreen(manga: manga),
                            ),
                          )
                          .then((_) => setState(() {}));
                    },
                  ),
                  Positioned(
                    top: 8,
                    left: 8,
                    child: IconButton(
                      icon: const Icon(Icons.remove_circle, color: Colors.red),
                      onPressed: () => _removeFavorite(manga.id),
                    ),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}

//lib/screens/home_screen.dart


import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:manga_app/screens/auth/login_screen.dart';
import 'package:manga_app/screens/manga_list_screen.dart';
import 'package:manga_app/screens/favorites_screen.dart';
import 'package:manga_app/screens/profile_screen.dart';
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


//lib/screens/manga_detail_screen.dart

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:manga_app/models/manga.dart';
import 'package:manga_app/models/chapter.dart';
import 'package:manga_app/services/firebase_service.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:manga_app/screens/reader_screen.dart';
import 'package:intl/intl.dart';

class MangaDetailScreen extends StatefulWidget {
  final Manga manga;

  const MangaDetailScreen({super.key, required this.manga});

  @override
  State<MangaDetailScreen> createState() => _MangaDetailScreenState();
}

class _MangaDetailScreenState extends State<MangaDetailScreen> {
  final FirebaseService _firebaseService = FirebaseService();
  late Future<List<Chapter>> _chaptersFuture;
  bool _isFavorite = false;

  @override
  void initState() {
    super.initState();
    _chaptersFuture = _firebaseService.getChaptersByMangaId(widget.manga.id);
    _checkIfFavorited();
  }

  Future<void> _checkIfFavorited() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final userProfile = await _firebaseService.getUserProfile(user.uid);
    if (userProfile == null) return;

    setState(
      () => _isFavorite = userProfile.favorites.contains(widget.manga.id),
    );
  }

  Future<void> _toggleFavorite() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    await _firebaseService.toggleFavorite(user.uid, widget.manga.id);
    setState(() => _isFavorite = !_isFavorite);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _isFavorite ? 'Added to favorites' : 'Removed from favorites',
          ),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            actions: [
              AnimatedScale(
                scale: _isFavorite ? 1.2 : 1.0,
                duration: const Duration(milliseconds: 200),
                child: IconButton(
                  icon: Icon(
                    _isFavorite ? Icons.favorite : Icons.favorite_border,
                    color: _isFavorite ? Colors.red : null,
                  ),
                  onPressed: _toggleFavorite,
                ),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  CachedNetworkImage(
                    imageUrl: widget.manga.coverUrl,
                    fit: BoxFit.cover,
                    placeholder:
                        (context, url) => Container(color: Colors.grey[300]),
                    errorWidget:
                        (context, url, error) => Container(
                          color: Colors.grey[300],
                          child: const Icon(Icons.error),
                        ),
                  ),
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      height: 80,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [Colors.transparent, Colors.black54],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.manga.title,
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Author: ${widget.manga.author}',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Status: ${widget.manga.isCompleted ? 'Completed' : 'Ongoing'}',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children:
                        widget.manga.genres
                            .map(
                              (genre) => Chip(
                                label: Text(genre),
                                backgroundColor: Colors.blueAccent.withOpacity(
                                  0.2,
                                ),
                              ),
                            )
                            .toList(),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Description',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.manga.description,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Chapters',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
          FutureBuilder<List<Chapter>>(
            future: _chaptersFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const SliverFillRemaining(
                  child: Center(child: CircularProgressIndicator()),
                );
              }
              if (snapshot.hasError) {
                return SliverFillRemaining(
                  child: Center(child: Text('Error: ${snapshot.error}')),
                );
              }
              final chapters = snapshot.data ?? [];
              if (chapters.isEmpty) {
                return const SliverFillRemaining(
                  child: Center(child: Text('No chapters available')),
                );
              }
              return SliverList(
                delegate: SliverChildBuilderDelegate((context, index) {
                  final chapter = chapters[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 4,
                    ),
                    child: ListTile(
                      title: Text(
                        'Chapter ${chapter.number}: ${chapter.title}',
                      ),
                      subtitle: Text(
                        'Released: ${DateFormat.yMMMd().format(chapter.releaseDate)}',
                      ),
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => ReaderScreen(chapter: chapter),
                          ),
                        );
                      },
                    ),
                  );
                }, childCount: chapters.length),
              );
            },
          ),
        ],
      ),
    );
  }
}


//lib/screens/manga_list_screen.dart


import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:manga_app/models/manga.dart';
import 'package:manga_app/services/firebase_service.dart';
import 'package:manga_app/widgets/manga_grid_item.dart';
import 'package:manga_app/screens/manga_detail_screen.dart';
import 'package:shimmer/shimmer.dart';

class MangaListScreen extends StatefulWidget {
  const MangaListScreen({super.key});

  @override
  State<MangaListScreen> createState() => _MangaListScreenState();
}

class _MangaListScreenState extends State<MangaListScreen> {
  final FirebaseService _firebaseService = FirebaseService();
  late Future<List<Manga>> _mangaFuture;
  String _selectedGenre = 'All';
  String _searchQuery = '';
  final List<String> _genres = [
    'All',
    'Action',
    'Adventure',
    'Comedy',
    'Drama',
    'Fantasy',
    'Horror',
    'Romance',
    'Sci-Fi',
    'Slice of Life',
  ];

  @override
  void initState() {
    super.initState();
    _updateMangaFuture();
  }

  void _updateMangaFuture() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      setState(
        () => _mangaFuture = Future.error('Please log in to view manga.'),
      );
      return;
    }

    setState(() {
      _mangaFuture =
          _selectedGenre == 'All'
              ? _firebaseService.getAllManga().then(
                (list) => list.take(20).toList(),
              )
              : _firebaseService
                  .getMangaByGenre(_selectedGenre)
                  .then((list) => list.take(20).toList());

      if (_searchQuery.isNotEmpty) {
        _mangaFuture = _mangaFuture.then(
          (mangas) =>
              mangas
                  .where(
                    (manga) =>
                        manga.title.toLowerCase().contains(
                          _searchQuery.toLowerCase(),
                        ) ||
                        manga.author.toLowerCase().contains(
                          _searchQuery.toLowerCase(),
                        ),
                  )
                  .toList(),
        );
      }
    });
  }

  void _filterByGenre(String genre) {
    setState(() {
      _selectedGenre = genre;
      _updateMangaFuture();
    });
  }

  void _searchManga(String query) {
    setState(() {
      _searchQuery = query;
      _updateMangaFuture();
    });
  }

  Future<void> _refreshManga() async => _updateMangaFuture();

  Widget _buildLoadingShimmer() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.65,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
        ),
        itemCount: 10,
        itemBuilder:
            (context, index) => Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
            ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search manga...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon:
                    _searchQuery.isNotEmpty
                        ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () => _searchManga(''),
                        )
                        : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                contentPadding: EdgeInsets.zero,
              ),
              onChanged:
                  (value) => Future.delayed(
                    const Duration(milliseconds: 300),
                    () => _searchManga(value),
                  ),
            ),
          ),
          SizedBox(
            height: 50,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _genres.length,
              itemBuilder: (context, index) {
                final genre = _genres[index];
                final isSelected = _selectedGenre == genre;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: AnimatedScale(
                    scale: isSelected ? 1.1 : 1.0,
                    duration: const Duration(milliseconds: 200),
                    child: FilterChip(
                      label: Text(genre),
                      selected: isSelected,
                      onSelected: (_) => _filterByGenre(genre),
                      selectedColor: Colors.blueAccent.withOpacity(0.3),
                      checkmarkColor: Colors.blueAccent,
                    ),
                  ),
                );
              },
            ),
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: _refreshManga,
              child: FutureBuilder<List<Manga>>(
                future: _mangaFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return _buildLoadingShimmer();
                  }

                  if (snapshot.hasError) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Error: ${snapshot.error.toString()}',
                            textAlign: TextAlign.center,
                            style: const TextStyle(color: Colors.red),
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: _refreshManga,
                            child: const Text('Retry'),
                          ),
                        ],
                      ),
                    );
                  }

                  final mangas = snapshot.data ?? [];
                  if (mangas.isEmpty)
                    return const Center(child: Text('No manga found'));

                  return GridView.builder(
                    padding: const EdgeInsets.all(16),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 0.65,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                        ),
                    itemCount: mangas.length,
                    itemBuilder: (context, index) {
                      final manga = mangas[index];
                      return MangaGridItem(
                        manga: manga,
                        onTap:
                            () => Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => MangaDetailScreen(manga: manga),
                              ),
                            ),
                      );
                    },
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

//lib/screens/profile_screen.dart

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:manga_app/models/user_profile.dart';
import 'package:manga_app/services/firebase_service.dart';
import 'package:intl/intl.dart';
import 'package:manga_app/utils/theme_provider.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  final FirebaseService _firebaseService = FirebaseService();
  late Future<UserProfile?> _profileFuture;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  void _loadProfile() {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      _profileFuture = _firebaseService.getUserProfile(user.uid);
    } else {
      _profileFuture = Future.value(null);
    }
  }

  Future<void> _updateUsername(String currentUsername) async {
    final controller = TextEditingController(text: currentUsername);

    await showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Update Username'),
            content: TextField(
              controller: controller,
              decoration: const InputDecoration(labelText: 'Username'),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () async {
                  Navigator.of(context).pop();
                  final user = FirebaseAuth.instance.currentUser;
                  if (user != null) {
                    final profile = await _firebaseService.getUserProfile(
                      user.uid,
                    );
                    if (profile != null) {
                      final updatedProfile = UserProfile(
                        uid: profile.uid,
                        username: controller.text,
                        email: profile.email,
                        profileImageUrl: profile.profileImageUrl,
                        favorites: profile.favorites,
                        lastReadChapter: profile.lastReadChapter,
                      );
                      await _firebaseService.updateUserProfile(updatedProfile);
                      if (mounted) setState(() => _loadProfile());
                    }
                  }
                },
                child: const Text('Update'),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = ref.watch(themeProviderNotifier);

    return Scaffold(
      body: FutureBuilder<UserProfile?>(
        future: _profileFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError)
            return Center(child: Text('Error: ${snapshot.error}'));
          final profile = snapshot.data;
          if (profile == null)
            return const Center(child: Text('Profile not found'));

          final user = FirebaseAuth.instance.currentUser;
          final email = user?.email ?? profile.email;
          final creationTime = user?.metadata.creationTime;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                GestureDetector(
                  onTap: () {
                    // TODO: Implement image upload with Firebase Storage
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Image upload coming soon!'),
                      ),
                    );
                  },
                  child: CircleAvatar(
                    radius: 60,
                    backgroundColor: Colors.blueAccent,
                    child:
                        profile.profileImageUrl.isEmpty
                            ? const Icon(
                              Icons.person,
                              size: 60,
                              color: Colors.white,
                            )
                            : ClipOval(
                              child: Image.network(
                                profile.profileImageUrl,
                                fit: BoxFit.cover,
                              ),
                            ),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      profile.username,
                      style: Theme.of(
                        context,
                      ).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color:
                            themeProvider.themeMode == ThemeMode.dark
                                ? Colors.white
                                : Colors.black,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () => _updateUsername(profile.username),
                    ),
                  ],
                ),
                Text(
                  email,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color:
                        themeProvider.themeMode == ThemeMode.dark
                            ? Colors.grey[300]
                            : Colors.grey[700],
                  ),
                ),
                const SizedBox(height: 8),
                if (creationTime != null)
                  Text(
                    'Member since ${DateFormat.yMMMMd().format(creationTime)}',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color:
                          themeProvider.themeMode == ThemeMode.dark
                              ? Colors.grey[400]
                              : Colors.grey[600],
                    ),
                  ),
                const SizedBox(height: 32),
                Card(
                  child: ListTile(
                    leading: const Icon(Icons.favorite),
                    title: const Text('Favorites'),
                    trailing: Text('${profile.favorites.length}'),
                  ),
                ),
                const SizedBox(height: 8),
                Card(
                  child: ListTile(
                    leading: const Icon(Icons.history),
                    title: const Text('Reading History'),
                    trailing: Text('${profile.lastReadChapter.length}'),
                  ),
                ),
                const SizedBox(height: 8),
                Card(
                  child: ListTile(
                    leading: const Icon(Icons.settings),
                    title: const Text('Settings'),
                    onTap: () {
                      // TODO: Navigate to settings screen
                    },
                  ),
                ),
                const SizedBox(height: 8),
                Card(
                  child: ListTile(
                    leading: const Icon(Icons.help_outline),
                    title: const Text('Help & Support'),
                    onTap: () {
                      // TODO: Navigate to help screen
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}


//lib/screens/reader_screen.dart

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:manga_app/models/chapter.dart';
import 'package:manga_app/services/firebase_service.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

class ReaderScreen extends StatefulWidget {
  final Chapter chapter;

  const ReaderScreen({super.key, required this.chapter});

  @override
  State<ReaderScreen> createState() => _ReaderScreenState();
}

class _ReaderScreenState extends State<ReaderScreen> {
  final FirebaseService _firebaseService = FirebaseService();
  final PdfViewerController _pdfViewerController = PdfViewerController();
  bool _isFullScreen = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _updateLastRead();
  }

  Future<void> _updateLastRead() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    await _firebaseService.updateLastReadChapter(
      user.uid,
      widget.chapter.mangaId,
      widget.chapter.number,
    );
  }

  void _toggleFullScreen() => setState(() => _isFullScreen = !_isFullScreen);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:
          _isFullScreen
              ? null
              : AppBar(
                title: Text(
                  'Chapter ${widget.chapter.number}: ${widget.chapter.title}',
                ),
                actions: [
                  IconButton(
                    icon: const Icon(Icons.fullscreen),
                    onPressed: _toggleFullScreen,
                  ),
                ],
              ),
      body: GestureDetector(
        onHorizontalDragEnd: (details) {
          if (details.primaryVelocity! > 0) {
            _pdfViewerController.previousPage();
          } else if (details.primaryVelocity! < 0) {
            _pdfViewerController.nextPage();
          }
        },
        child: Stack(
          children: [
            SfPdfViewer.network(
              widget.chapter.pdfUrl,
              controller: _pdfViewerController,
              onDocumentLoaded: (details) => setState(() => _isLoading = false),
              onDocumentLoadFailed: (details) {
                setState(() => _isLoading = false);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Error loading PDF: ${details.error}'),
                  ),
                );
              },
            ),
            if (_isLoading) const Center(child: CircularProgressIndicator()),
            if (_isFullScreen) ...[
              Positioned(
                top: 0,
                right: 0,
                child: SafeArea(
                  child: IconButton(
                    icon: const Icon(
                      Icons.fullscreen_exit,
                      color: Colors.white,
                      shadows: [Shadow(blurRadius: 5, color: Colors.black)],
                    ),
                    onPressed: _toggleFullScreen,
                  ),
                ),
              ),
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: SafeArea(
                  child: Container(
                    color: Colors.black54,
                    padding: const EdgeInsets.all(8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        IconButton(
                          icon: const Icon(
                            Icons.arrow_back,
                            color: Colors.white,
                          ),
                          onPressed: () => _pdfViewerController.previousPage(),
                        ),
                        Text(
                          'Page ${_pdfViewerController.pageNumber}/${_pdfViewerController.pageCount}',
                          style: const TextStyle(color: Colors.white),
                        ),
                        IconButton(
                          icon: const Icon(
                            Icons.arrow_forward,
                            color: Colors.white,
                          ),
                          onPressed: () => _pdfViewerController.nextPage(),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

//lib/screens/splash_screen.dart

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:manga_app/screens/auth/login_screen.dart';
import 'package:manga_app/screens/home_screen.dart';
import 'package:google_fonts/google_fonts.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;
  late Animation<double> _subtitleFadeAnimation;
  late Animation<Color?> _backgroundColorAnimation;

  final String title = "MANGA";

  @override
  void initState() {
    super.initState();

    // Animation controller with a 2.5-second duration for a snappier feel
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500),
    );

    // Scale animation for the title (simplified, no elastic curve)
    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.4, curve: Curves.easeInOut),
      ),
    );

    // Opacity animation for the entire content
    _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.3, curve: Curves.easeIn),
      ),
    );

    // Subtitle fade-in animation (simplified, no slide)
    _subtitleFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.4, 0.7, curve: Curves.easeOut),
      ),
    );

    // Background color transition for subtle depth
    _backgroundColorAnimation = ColorTween(
      begin: const Color(0xFF121212), // Darker, modern base color
      end: const Color(0xFF1E1E1E), // Slight shift for elegance
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 1.0, curve: Curves.easeInOut),
      ),
    );

    _controller.forward();

    // Check auth status and navigate after animation
    _checkAuthAndNavigate();
  }

  void _checkAuthAndNavigate() {
    Future.delayed(const Duration(milliseconds: 2500), () {
      if (mounted) {
        final user = FirebaseAuth.instance.currentUser;
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder:
                (_) => user != null ? const HomeScreen() : const LoginScreen(),
          ),
        );
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  _backgroundColorAnimation.value ?? const Color(0xFF121212),
                  const Color(0xFF0A0A0A),
                ],
              ),
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Main title with simplified scale and glow
                  Opacity(
                    opacity: _opacityAnimation.value,
                    child: Transform.scale(
                      scale: _scaleAnimation.value,
                      child: Text(
                        title,
                        style: GoogleFonts.bangers(
                          textStyle: TextStyle(
                            fontSize: 72,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            letterSpacing: 2.0,
                            shadows: [
                              Shadow(
                                color: Colors.purpleAccent.withOpacity(0.4),
                                blurRadius: 12,
                                offset: const Offset(0, 0),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20), // Tighter spacing for modern look
                  // Subtitle with fade-in only
                  Opacity(
                    opacity: _subtitleFadeAnimation.value,
                    child: Text(
                      "READER",
                      style: GoogleFonts.poppins(
                        textStyle: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w400,
                          color: Colors.white.withOpacity(0.8),
                          letterSpacing: 4.0,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 40), // Adjusted for balance
                  // Modern loading indicator
                  Opacity(
                    opacity: _opacityAnimation.value,
                    child: SizedBox(
                      width: 36,
                      height: 36,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          // Pulsing outer ring
                          TweenAnimationBuilder<double>(
                            tween: Tween(begin: 0.8, end: 1.0),
                            duration: const Duration(milliseconds: 800),
                            builder: (context, value, child) {
                              return Transform.scale(
                                scale: value,
                                child: Container(
                                  width: 36,
                                  height: 36,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: Colors.purpleAccent.withOpacity(
                                        0.6,
                                      ),
                                      width: 2,
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                          // Inner dot
                          Container(
                            width: 12,
                            height: 12,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.purpleAccent,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}


// lib/services/firebase_service.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:manga_app/models/manga.dart';
import 'package:manga_app/models/chapter.dart';
import 'package:manga_app/models/user_profile.dart';

class FirebaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Authentication methods
  Future<UserCredential> signIn(String email, String password) async {
    try {
      return await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'user-not-found':
          throw 'No user found with this email';
        case 'wrong-password':
          throw 'Incorrect password';
        case 'invalid-email':
          throw 'Invalid email format';
        case 'user-disabled':
          throw 'This account has been disabled';
        default:
          throw 'Login failed: ${e.message}';
      }
    } catch (e) {
      throw 'An unexpected error occurred: $e';
    }
  }

  Future<UserCredential> signUp(String email, String password) async {
    try {
      return await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'email-already-in-use':
          throw 'This email is already registered';
        case 'invalid-email':
          throw 'Invalid email format';
        case 'weak-password':
          throw 'Password is too weak';
        default:
          throw 'Sign up failed: ${e.message}';
      }
    } catch (e) {
      throw 'An unexpected error occurred: $e';
    }
  }

  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (e) {
      throw 'Sign out failed: $e';
    }
  }

  // User profile methods
  Future<void> createUserProfile(UserProfile profile) async {
    try {
      await _firestore
          .collection('users')
          .doc(profile.uid)
          .set(profile.toMap());
    } catch (e) {
      throw 'Failed to create user profile: $e';
    }
  }

  Future<UserProfile?> getUserProfile(String uid) async {
    try {
      DocumentSnapshot doc =
          await _firestore.collection('users').doc(uid).get();
      if (doc.exists) {
        return UserProfile.fromMap(doc.data() as Map<String, dynamic>, uid);
      }
      return null;
    } catch (e) {
      throw 'Failed to get user profile: $e';
    }
  }

  Future<void> updateUserProfile(UserProfile profile) async {
    try {
      await _firestore
          .collection('users')
          .doc(profile.uid)
          .update(profile.toMap());
    } catch (e) {
      throw 'Failed to update user profile: $e';
    }
  }

  // Manga methods
  Future<List<Manga>> getAllManga() async {
    try {
      QuerySnapshot snapshot = await _firestore.collection('mangas').get();
      return snapshot.docs
          .map(
            (doc) => Manga.fromMap(doc.data() as Map<String, dynamic>, doc.id),
          )
          .toList();
    } catch (e) {
      throw 'Failed to fetch manga list: $e';
    }
  }

  Future<List<Manga>> getMangaByGenre(String genre) async {
    try {
      QuerySnapshot snapshot =
          await _firestore
              .collection('mangas')
              .where('genres', arrayContains: genre)
              .get();
      return snapshot.docs
          .map(
            (doc) => Manga.fromMap(doc.data() as Map<String, dynamic>, doc.id),
          )
          .toList();
    } catch (e) {
      throw 'Failed to fetch manga by genre: $e';
    }
  }

  Future<Manga?> getMangaById(String id) async {
    try {
      DocumentSnapshot doc =
          await _firestore.collection('mangas').doc(id).get();
      if (doc.exists) {
        return Manga.fromMap(doc.data() as Map<String, dynamic>, id);
      }
      return null;
    } catch (e) {
      throw 'Failed to fetch manga: $e';
    }
  }

  // Chapter methods
  Future<List<Chapter>> getChaptersByMangaId(String mangaId) async {
    try {
      QuerySnapshot snapshot =
          await _firestore
              .collection('chapters')
              .where('mangaId', isEqualTo: mangaId)
              .orderBy('number', descending: true)
              .get();
      return snapshot.docs
          .map(
            (doc) =>
                Chapter.fromMap(doc.data() as Map<String, dynamic>, doc.id),
          )
          .toList();
    } catch (e) {
      throw 'Failed to fetch chapters: $e';
    }
  }

  Future<Chapter?> getChapterById(String id) async {
    try {
      DocumentSnapshot doc =
          await _firestore.collection('chapters').doc(id).get();
      if (doc.exists) {
        return Chapter.fromMap(doc.data() as Map<String, dynamic>, id);
      }
      return null;
    } catch (e) {
      throw 'Failed to fetch chapter: $e';
    }
  }

  // Favorites methods
  Future<void> toggleFavorite(String uid, String mangaId) async {
    try {
      DocumentSnapshot userDoc =
          await _firestore.collection('users').doc(uid).get();
      UserProfile userProfile = UserProfile.fromMap(
        userDoc.data() as Map<String, dynamic>,
        uid,
      );

      List<String> updatedFavorites = List.from(userProfile.favorites);
      if (updatedFavorites.contains(mangaId)) {
        updatedFavorites.remove(mangaId);
      } else {
        updatedFavorites.add(mangaId);
      }

      await _firestore.collection('users').doc(uid).update({
        'favorites': updatedFavorites,
      });
    } catch (e) {
      throw 'Failed to update favorites: $e';
    }
  }

  Future<void> updateLastReadChapter(
    String uid,
    String mangaId,
    int chapterNumber,
  ) async {
    try {
      await _firestore.collection('users').doc(uid).update({
        'lastReadChapter.$mangaId': chapterNumber,
      });
    } catch (e) {
      throw 'Failed to update reading progress: $e';
    }
  }
}


// lib/util/theme_provider.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Define the provider globally
final themeProviderNotifier = ChangeNotifierProvider<ThemeProvider>(
  (ref) => ThemeProvider(),
);

class ThemeProvider extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.system;

  ThemeMode get themeMode => _themeMode;

  ThemeProvider() {
    _loadThemeFromPrefs();
  }

  void _loadThemeFromPrefs() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final isDark = prefs.getBool('isDarkMode');
    if (isDark != null) {
      _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
      notifyListeners();
    }
  }

  void toggleTheme() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (_themeMode == ThemeMode.light) {
      _themeMode = ThemeMode.dark;
      prefs.setBool('isDarkMode', true);
    } else {
      _themeMode = ThemeMode.light;
      prefs.setBool('isDarkMode', false);
    }
    notifyListeners();
  }
}

//lib/widgets/manga_grid_item.dart

import 'package:flutter/material.dart';
import 'package:manga_app/models/manga.dart';
import 'package:cached_network_image/cached_network_image.dart';

class MangaGridItem extends StatefulWidget {
  final Manga manga;
  final VoidCallback onTap;

  const MangaGridItem({super.key, required this.manga, required this.onTap});

  @override
  _MangaGridItemState createState() => _MangaGridItemState();
}

class _MangaGridItemState extends State<MangaGridItem> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: MouseRegion(
        onEnter: (_) => setState(() => _isHovered = true),
        onExit: (_) => setState(() => _isHovered = false),
        child: AnimatedScale(
          scale: _isHovered ? 1.05 : 1.0,
          duration: const Duration(milliseconds: 200),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        CachedNetworkImage(
                          imageUrl: widget.manga.coverUrl,
                          fit: BoxFit.cover,
                          placeholder:
                              (context, url) => Center(
                                child: CircularProgressIndicator(
                                  color: Colors.blueAccent,
                                ),
                              ),
                          errorWidget:
                              (context, url, error) => Container(
                                color: Colors.grey[300],
                                child: const Icon(
                                  Icons.error,
                                  color: Colors.red,
                                  size: 40,
                                ),
                              ),
                        ),
                        Positioned(
                          bottom: 0,
                          left: 0,
                          right: 0,
                          child: Container(
                            height: 40,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [Colors.transparent, Colors.black54],
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                          top: 8,
                          right: 8,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors:
                                    widget.manga.isCompleted
                                        ? [Colors.green, Colors.greenAccent]
                                        : [Colors.blue, Colors.blueAccent],
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              widget.manga.isCompleted
                                  ? 'Completed'
                                  : 'Ongoing',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(8),
                    color: Theme.of(context).cardColor,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.manga.title,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            shadows: [
                              Shadow(color: Colors.black26, blurRadius: 2),
                            ],
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          widget.manga.author,
                          style: TextStyle(
                            fontSize: 12,
                            color: Theme.of(context).textTheme.bodySmall?.color,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
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
