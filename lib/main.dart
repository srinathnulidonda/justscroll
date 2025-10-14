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
        cardTheme: CardThemeData(
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
        cardTheme: CardThemeData(
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