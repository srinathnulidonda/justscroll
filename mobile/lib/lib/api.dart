// lib/lib/api.dart
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:justscroll/lib/config.dart';

class ApiClient {
  static final ApiClient instance = ApiClient._();
  late final Dio _dio;

  ApiClient._() {
    _dio = Dio(BaseOptions(
      baseUrl: AppConfig.apiUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      headers: {'Content-Type': 'application/json'},
    ));
    
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        if (options.extra['auth'] == true) {
          final prefs = await SharedPreferences.getInstance();
          final token = prefs.getString('access_token');
          if (token != null) options.headers['Authorization'] = 'Bearer $token';
        }
        handler.next(options);
      },
      onError: (error, handler) async {
        if (error.response?.statusCode == 401 && error.requestOptions.extra['auth'] == true) {
          final refreshed = await _tryRefresh();
          if (refreshed) {
            final prefs = await SharedPreferences.getInstance();
            final token = prefs.getString('access_token');
            error.requestOptions.headers['Authorization'] = 'Bearer $token';
            final response = await _dio.fetch(error.requestOptions);
            return handler.resolve(response);
          }
        }
        handler.next(error);
      },
    ));
  }

  String proxyImage(String? url) {
    if (url == null || url.isEmpty) return '';
    return '${AppConfig.apiUrl}/api/v1/proxy/image?url=${Uri.encodeComponent(url)}';
  }

  Future<bool> _tryRefresh() async {
    final prefs = await SharedPreferences.getInstance();
    final refresh = prefs.getString('refresh_token');
    if (refresh == null) return false;
    try {
      final res = await Dio().post('${AppConfig.apiUrl}/api/v1/auth/refresh', data: {'refresh_token': refresh});
      if (res.statusCode == 200) {
        await prefs.setString('access_token', res.data['access_token']);
        await prefs.setString('refresh_token', res.data['refresh_token']);
        return true;
      }
    } catch (_) {}
    await prefs.remove('access_token');
    await prefs.remove('refresh_token');
    await prefs.remove('user_data');
    return false;
  }

  Future<Map<String, dynamic>> login({required String username, required String password}) async {
    final res = await _dio.post('/api/v1/auth/login', data: {'username': username, 'password': password});
    return res.data;
  }

  Future<Map<String, dynamic>> register({required String username, required String email, required String password}) async {
    final res = await _dio.post('/api/v1/auth/register', data: {'username': username, 'email': email, 'password': password});
    return res.data;
  }

  Future<Map<String, dynamic>> searchManga(String q, {int limit = 20, int offset = 0}) async {
    final res = await _dio.get('/api/v1/manga/search', queryParameters: {'q': q, 'limit': limit, 'offset': offset});
    return res.data;
  }

  Future<Map<String, dynamic>> getPopular({int limit = 20, int offset = 0}) async {
    final res = await _dio.get('/api/v1/manga/popular', queryParameters: {'limit': limit, 'offset': offset});
    return res.data;
  }

  Future<Map<String, dynamic>> getLatestUpdates({int limit = 20, int offset = 0}) async {
    final res = await _dio.get('/api/v1/manga/latest-updates', queryParameters: {'limit': limit, 'offset': offset});
    return res.data;
  }

  Future<Map<String, dynamic>> getMangaDetail(String id) async {
    final res = await _dio.get('/api/v1/manga/$id');
    return res.data;
  }

  Future<Map<String, dynamic>> getMangaChapters(String id, {String lang = 'en'}) async {
    final res = await _dio.get('/api/v1/manga/$id/chapters', queryParameters: {'lang': lang, 'limit': 10000});
    return res.data;
  }

  Future<Map<String, dynamic>> getMangaCharacters(String id) async {
    final res = await _dio.get('/api/v1/manga/$id/characters');
    return res.data;
  }

  Future<Map<String, dynamic>> getChapterPages(String chapterId, {String quality = 'data'}) async {
    final res = await _dio.get('/api/v1/chapters/$chapterId/pages', queryParameters: {'quality': quality});
    return res.data;
  }

  Future<Map<String, dynamic>> getBookmarks() async {
    final res = await _dio.get('/api/v1/user/bookmarks', options: Options(extra: {'auth': true}));
    return res.data;
  }

  Future<void> addBookmark(String mangaId, {required String mangaTitle, String? coverUrl}) async {
    await _dio.post('/api/v1/user/bookmarks/$mangaId',
      data: {'manga_title': mangaTitle, 'cover_url': coverUrl},
      options: Options(extra: {'auth': true}),
    );
  }

  Future<void> removeBookmark(String mangaId) async {
    await _dio.delete('/api/v1/user/bookmarks/$mangaId', options: Options(extra: {'auth': true}));
  }

  Future<Map<String, dynamic>> getHistory() async {
    final res = await _dio.get('/api/v1/user/history', options: Options(extra: {'auth': true}));
    return res.data;
  }

  Future<void> updateHistory({
    required String mangaId,
    required String chapterId,
    required String mangaTitle,
    String? chapterNumber,
    required int pageNumber,
  }) async {
    await _dio.post('/api/v1/user/history',
      data: {
        'manga_id': mangaId,
        'chapter_id': chapterId,
        'manga_title': mangaTitle,
        'chapter_number': chapterNumber,
        'page_number': pageNumber,
      },
      options: Options(extra: {'auth': true}),
    );
  }
}