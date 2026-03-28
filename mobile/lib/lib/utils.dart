// lib/lib/utils.dart
import 'package:justscroll/models/manga.dart';
import 'package:justscroll/lib/config.dart';

String proxyImage(String? url) {
  if (url == null || url.isEmpty) return '';
  return '${AppConfig.apiUrl}/api/v1/proxy/image?url=${Uri.encodeComponent(url)}';
}

String truncateStr(String? str, [int length = 120]) {
  if (str == null || str.isEmpty) return '';
  if (str.length <= length) return str;
  return '${str.substring(0, length).trimRight()}…';
}

String stripHtml(String? html) {
  if (html == null || html.isEmpty) return '';
  return html.replaceAll(RegExp(r'<[^>]*>'), '').trim();
}

String formatDate(String? dateStr) {
  if (dateStr == null || dateStr.isEmpty) return '';
  try {
    final d = DateTime.parse(dateStr);
    final now = DateTime.now();
    final diff = now.difference(d);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${months[d.month - 1]} ${d.day}, ${d.year}';
  } catch (_) {
    return '';
  }
}

String formatNumber(int? n) {
  if (n == null) return '';
  if (n >= 1000000) return '${(n / 1000000).toStringAsFixed(1)}M';
  if (n >= 1000) return '${(n / 1000).toStringAsFixed(1)}K';
  return n.toString();
}

List<Manga> deduplicateManga(List<Manga> items) {
  final seenIds = <String>{};
  final seenTitles = <String>{};
  return items.where((item) {
    if (seenIds.contains(item.id)) return false;
    seenIds.add(item.id);
    final title = item.title.toLowerCase().trim();
    if (title.isNotEmpty) {
      if (seenTitles.contains(title)) return false;
      seenTitles.add(title);
    }
    return true;
  }).toList();
}

List<int> generatePageNumbers(int current, int total) {
  if (total <= 7) return List.generate(total, (i) => i + 1);
  final pages = <int>[1];
  if (current > 3) pages.add(-1);
  final start = (current - 1).clamp(2, total - 1);
  final end = (current + 1).clamp(2, total - 1);
  for (int i = start; i <= end; i++) pages.add(i);
  if (current < total - 2) pages.add(-1);
  if (total > 1) pages.add(total);
  return pages;
}