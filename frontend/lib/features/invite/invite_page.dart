import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/i18n/translations.dart';
import '../../core/theme/app_theme.dart';
import '../../services/providers.dart';
import '../landing/landing_page.dart';

class InvitePage extends ConsumerWidget {
  const InvitePage({super.key, required this.guestSlug});
  final String? guestSlug;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (guestSlug == null || guestSlug!.isEmpty) {
      return const LandingPage();
    }
    final guestAsync = ref.watch(guestProvider(guestSlug));
    final lang = ref.watch(localeControllerProvider);

    return guestAsync.when(
      loading: () => Scaffold(
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(color: AppPalette.rose),
              const SizedBox(height: 18),
              Text('Preparing your invitation...',
                  style: AppTheme.script(size: 24)),
            ],
          ),
        ),
      ),
      error: (_, __) => LandingPage(guestSlug: guestSlug),
      data: (guest) {
        final name = guest?.name;
        if (name == null || name.isEmpty) {
          return LandingPage(guestSlug: guestSlug);
        }
        return Stack(
          children: [
            LandingPage(guestName: name, guestSlug: guestSlug),
            // brief welcome overlay on first frame
            _WelcomeOverlay(name: name, lang: lang),
          ],
        );
      },
    );
  }
}

class _WelcomeOverlay extends StatefulWidget {
  const _WelcomeOverlay({required this.name, required this.lang});
  final String name;
  final AppLang lang;

  @override
  State<_WelcomeOverlay> createState() => _WelcomeOverlayState();
}

class _WelcomeOverlayState extends State<_WelcomeOverlay> {
  bool _hide = false;

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 2400), () {
      if (mounted) setState(() => _hide = true);
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_hide) return const SizedBox.shrink();
    return Positioned.fill(
      child: IgnorePointer(
        child: Container(
          color: Theme.of(context).scaffoldBackgroundColor.withOpacity(.96),
          alignment: Alignment.center,
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  tr(widget.lang, 'welcome_guest'),
                  style: AppTheme.script(size: 38, color: AppPalette.gold),
                ).animate().fadeIn(duration: 500.ms).slideY(begin: -.2),
                const SizedBox(height: 6),
                Text(
                  widget.name,
                  style: Theme.of(context)
                      .textTheme
                      .displayMedium
                      ?.copyWith(color: AppPalette.roseDeep, fontSize: 56),
                  textAlign: TextAlign.center,
                ).animate().fadeIn(delay: 300.ms).scaleXY(begin: .8),
                const SizedBox(height: 14),
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 460),
                  child: Text(
                    tr(widget.lang, 'we_are_excited'),
                    style: AppTheme.serif(
                      size: 18,
                      color: Theme.of(context).textTheme.bodyMedium?.color,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ).animate().fadeIn(delay: 700.ms),
              ],
            ),
          ),
        )
            .animate(target: _hide ? 1 : 0)
            .fadeOut(duration: 600.ms),
      ),
    );
  }
}
