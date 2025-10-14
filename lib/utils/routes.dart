//utils/routers.dart

import 'package:flutter/material.dart';
import '../screens/home_screen.dart';
import '../screens/manga_list_screen.dart';
import '../screens/manga_detail_screen.dart';
import '../screens/reader_screen.dart';
import '../screens/profile_screen.dart';
import '../screens/auth_screen.dart';

// Define route names as constants for easier reference
class Routes {
  static const String home = '/';
  static const String mangaList = '/manga-list';
  static const String mangaDetail = '/manga-detail';
  static const String reader = '/reader';
  static const String profile = '/profile';
  static const String auth = '/auth';
}

// Define app routes
final Map<String, WidgetBuilder> appRoutes = {
  Routes.home: (context) => const HomeScreen(),
  Routes.mangaList: (context) => const MangaListScreen(),
  Routes.mangaDetail: (context) => const MangaDetailScreen(),
  Routes.reader: (context) => const ReaderScreen(),
  Routes.profile: (context) => const ProfileScreen(),
  Routes.auth: (context) => const AuthScreen(),
};
