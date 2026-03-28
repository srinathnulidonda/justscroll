// lib/components/common/share_sheet.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:justscroll/stores/toast_store.dart';

class ShareSheet extends ConsumerWidget {
  final String url;
  final String title;

  const ShareSheet({super.key, required this.url, required this.title});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final toast = ref.read(toastProvider.notifier);

    final options = [
      _ShareOption('Copy Link', Icons.link, const Color(0xFF71717A), () async {
        await Clipboard.setData(ClipboardData(text: url));
        toast.success('Link copied to clipboard');
        if (context.mounted) Navigator.pop(context);
      }),
      _ShareOption('Twitter / X', Icons.alternate_email, const Color(0xFF1DA1F2), () {
        _openUrl('https://twitter.com/intent/tweet?text=${Uri.encodeComponent(title)}&url=${Uri.encodeComponent(url)}');
        Navigator.pop(context);
      }),
      _ShareOption('WhatsApp', Icons.chat_bubble, const Color(0xFF25D366), () {
        _openUrl('https://wa.me/?text=${Uri.encodeComponent('$title $url')}');
        Navigator.pop(context);
      }),
      _ShareOption('Telegram', Icons.send, const Color(0xFF0088CC), () {
        _openUrl('https://t.me/share/url?url=${Uri.encodeComponent(url)}&text=${Uri.encodeComponent(title)}');
        Navigator.pop(context);
      }),
      _ShareOption('More', Icons.share, theme.colorScheme.primary, () async {
        Navigator.pop(context);
        await Share.share('$title\n$url');
      }),
    ];

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 12),
            Container(width: 36, height: 4, decoration: BoxDecoration(color: theme.colorScheme.onSurface.withOpacity(0.15), borderRadius: BorderRadius.circular(2))),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
              child: Row(
                children: [
                  Text('Share', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: theme.colorScheme.onSurface)),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close, size: 20),
                    onPressed: () => Navigator.pop(context),
                    style: IconButton.styleFrom(foregroundColor: theme.colorScheme.onSurface.withOpacity(0.5)),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(title, style: TextStyle(fontSize: 12, color: theme.colorScheme.onSurface.withOpacity(0.5)), maxLines: 1, overflow: TextOverflow.ellipsis),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Wrap(
                spacing: 16,
                runSpacing: 12,
                children: options.map((o) => _ShareButton(option: o)).toList(),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  void _openUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) await launchUrl(uri, mode: LaunchMode.externalApplication);
  }
}

class _ShareOption {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  const _ShareOption(this.label, this.icon, this.color, this.onTap);
}

class _ShareButton extends StatelessWidget {
  final _ShareOption option;
  const _ShareButton({required this.option});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: option.onTap,
      child: SizedBox(
        width: 64,
        child: Column(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(color: option.color.withOpacity(0.1), borderRadius: BorderRadius.circular(14)),
              child: Icon(option.icon, color: option.color, size: 20),
            ),
            const SizedBox(height: 6),
            Text(option.label, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w500, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6)), textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}

void showShareSheet(BuildContext context, {required String url, required String title}) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => ShareSheet(url: url, title: title),
  );
}