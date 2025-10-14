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
