// lib/lib/config.dart
import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppConfig {
  static late String apiUrl;

  static Future<void> initialize() async {
    await dotenv.load(fileName: ".env");
    apiUrl = dotenv.env['API_URL'] ?? 'https://apijustscroll.up.railway.app';
  }
}