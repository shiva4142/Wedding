import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/config/wedding_config.dart';
import '../../../core/i18n/translations.dart';
import '../../../core/theme/app_theme.dart';
import '../../../widgets/gold_divider.dart';
import '../../../widgets/primary_button.dart' as ui;
import 'falling_petals.dart';

class HeroSection extends ConsumerWidget {
  const HeroSection({super.key, this.guestName, this.onRsvp, this.onEvents});
  final String? guestName;
  final VoidCallback? onRsvp;
  final VoidCallback? onEvents;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lang = ref.watch(localeControllerProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final dateStr = DateFormat('EEEE · MMMM d, yyyy')
        .format(WeddingConfig.date)
        .toUpperCase();
    final screenH = MediaQuery.of(context).size.height;
    final heroHeight = screenH < 760 ? 760.0 : screenH;

    return ConstrainedBox(
      constraints: BoxConstraints(minHeight: heroHeight),
      child: Stack(
        children: [
          Positioned.fill(child: _AnimatedGradient(isDark: isDark)),
          const Positioned.fill(child: FallingPetals()),
          Padding(
            padding: EdgeInsets.fromLTRB(24, screenH < 760 ? 90 : 110, 24, 80),
            child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 880),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (guestName != null && guestName!.isNotEmpty)
                        ui.Chip(label: 'Dearest, $guestName')
                            .animate()
                            .fadeIn(duration: 600.ms)
                            .slideY(begin: -.3),
                      const SizedBox(height: 18),
                      Text(
                        tr(lang, 'save_the_date'),
                        textAlign: TextAlign.center,
                        style: AppTheme.script(size: 36),
                      ).animate().fadeIn(duration: 800.ms),
                      const SizedBox(height: 14),
                      _CoupleNames(),
                      const SizedBox(height: 8),
                      const GoldDivider(symbol: '✦'),
                      const SizedBox(height: 4),
                      Text(
                        dateStr,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          letterSpacing: 4,
                          fontSize: 14,
                          color: Theme.of(context).textTheme.bodyMedium?.color
                              ?.withOpacity(.85),
                        ),
                      ).animate().fadeIn(delay: 1300.ms, duration: 800.ms),
                      const SizedBox(height: 6),
                      Text(
                        '${WeddingConfig.venueCity} · ${WeddingConfig.hashtag}',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 13,
                          color: Theme.of(context).textTheme.bodyMedium?.color
                              ?.withOpacity(.6),
                        ),
                      ).animate().fadeIn(delay: 1500.ms),
                      const SizedBox(height: 36),
                      Wrap(
                        spacing: 14,
                        runSpacing: 12,
                        alignment: WrapAlignment.center,
                        children: [
                          ui.PrimaryButton(
                            label: tr(lang, 'view_invite'),
                            icon: Icons.favorite,
                            onPressed: onRsvp,
                          ),
                          ui.GhostButton(
                            label: tr(lang, 'view_events'),
                            icon: Icons.calendar_month_outlined,
                            onPressed: onEvents,
                          ),
                        ],
                      ).animate().fadeIn(delay: 1800.ms, duration: 600.ms),
                      const SizedBox(height: 60),
                    ],
                  ),
                ),
              ),
            ),
          Positioned(
            bottom: 22,
            left: 0,
            right: 0,
            child: Center(
              child: Text(
                'SCROLL ↓',
                style: TextStyle(
                  fontSize: 11,
                  letterSpacing: 4,
                  color: AppPalette.gold.withOpacity(.8),
                ),
              )
                  .animate(onPlay: (c) => c.repeat(reverse: true))
                  .moveY(begin: 0, end: 8, duration: 1200.ms, curve: Curves.easeInOut),
            ),
          ),
        ],
      ),
    );
  }
}

class _CoupleNames extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size.width;
    final big = size > 600 ? 96.0 : 64.0;
    return Column(
      children: [
        Text(WeddingConfig.groom,
                style: Theme.of(context)
                    .textTheme
                    .displayLarge
                    ?.copyWith(fontSize: big, height: 1.0))
            .animate()
            .fadeIn(delay: 400.ms, duration: 800.ms)
            .slideY(begin: .3),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Text('&',
                  style: Theme.of(context).textTheme.displayMedium?.copyWith(
                      fontSize: big * 0.7,
                      color: AppPalette.rose,
                      height: 1))
              .animate()
              .scaleXY(begin: .2, duration: 800.ms, delay: 800.ms, curve: Curves.elasticOut),
        ),
        Text(WeddingConfig.bride,
                style: Theme.of(context)
                    .textTheme
                    .displayLarge
                    ?.copyWith(fontSize: big, height: 1.0))
            .animate()
            .fadeIn(delay: 600.ms, duration: 800.ms)
            .slideY(begin: .3),
      ],
    );
  }
}

class _AnimatedGradient extends StatefulWidget {
  const _AnimatedGradient({required this.isDark});
  final bool isDark;
  @override
  State<_AnimatedGradient> createState() => _AnimatedGradientState();
}

class _AnimatedGradientState extends State<_AnimatedGradient>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c =
      AnimationController(vsync: this, duration: const Duration(seconds: 14))
        ..repeat(reverse: true);

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _c,
      builder: (_, __) {
        final t = _c.value;
        final colors = widget.isDark
            ? [
                Color.lerp(const Color(0xFF120B13), const Color(0xFF1F0F1A), t)!,
                Color.lerp(const Color(0xFF1F0F1A), const Color(0xFF2C1A20), 1 - t)!,
              ]
            : [
                Color.lerp(const Color(0xFFFFE5EC), const Color(0xFFFDF6E3), t)!,
                Color.lerp(const Color(0xFFFDF9F3), const Color(0xFFFFF5F7), 1 - t)!,
              ];
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: colors,
            ),
          ),
          child: Stack(
            children: [
              Positioned(
                left: 100 + 60 * t,
                top: 80 + 30 * t,
                child: _blob(AppPalette.rose.withOpacity(.18), 240),
              ),
              Positioned(
                right: 60 + 80 * (1 - t),
                top: 200 + 40 * (1 - t),
                child: _blob(AppPalette.gold.withOpacity(.18), 320),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _blob(Color color, double size) => Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [color, Colors.transparent],
          ),
        ),
      );
}
