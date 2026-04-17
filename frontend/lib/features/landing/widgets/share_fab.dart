import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/config/wedding_config.dart';
import '../../../core/theme/app_theme.dart';

class ShareFab extends StatelessWidget {
  const ShareFab({super.key, this.guestSlug, this.guestName});
  final String? guestSlug;
  final String? guestName;

  String get _url {
    if (guestSlug == null || guestSlug!.isEmpty) return WeddingConfig.siteUrl;
    return '${WeddingConfig.siteUrl}/invite?guest=${Uri.encodeQueryComponent(guestSlug!)}';
  }

  String get _shareText =>
      "You're invited to ${WeddingConfig.groom} & ${WeddingConfig.bride}'s wedding! 💍\n$_url";

  @override
  Widget build(BuildContext context) {
    return Positioned(
      right: 20,
      bottom: 20,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _CircleFab(
            color: const Color(0xFF25D366),
            child: const Icon(Icons.send_rounded, color: Colors.white),
            onTap: () => launchUrl(Uri.parse(
                'https://wa.me/?text=${Uri.encodeQueryComponent(_shareText)}')),
          ),
          const SizedBox(height: 12),
          _CircleFab(
            color: Theme.of(context).scaffoldBackgroundColor.withOpacity(.85),
            border: AppPalette.gold.withOpacity(.5),
            child: const Icon(Icons.qr_code_2_rounded, size: 26),
            onTap: () => _showQr(context),
          ),
        ],
      ),
    );
  }

  void _showQr(BuildContext context) {
    showDialog(
      context: context,
      barrierColor: Colors.black87,
      builder: (_) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: AppPalette.gold.withOpacity(.4)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                guestName != null ? "${guestName!}'s invite" : 'Share this invite',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                color: Colors.white,
                child: QrImageView(
                  data: _url,
                  size: 220,
                  backgroundColor: Colors.white,
                  foregroundColor: AppPalette.ink,
                ),
              ),
              const SizedBox(height: 14),
              SelectableText(
                _url,
                style: const TextStyle(fontSize: 11, color: AppPalette.muted),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CircleFab extends StatelessWidget {
  const _CircleFab({
    required this.child,
    required this.onTap,
    required this.color,
    this.border,
  });
  final Widget child;
  final VoidCallback onTap;
  final Color color;
  final Color? border;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(40),
        onTap: onTap,
        child: Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color,
            border: border == null ? null : Border.all(color: border!),
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(.15), blurRadius: 16),
            ],
          ),
          child: Center(child: child),
        ),
      ),
    );
  }
}
