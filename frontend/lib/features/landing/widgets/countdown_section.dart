import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/config/wedding_config.dart';
import '../../../core/i18n/translations.dart';
import '../../../core/theme/app_theme.dart';
import '../../../services/providers.dart';
import '../../../widgets/glass_card.dart';
import '../../../widgets/gold_divider.dart';

class CountdownSection extends ConsumerStatefulWidget {
  const CountdownSection({super.key});
  @override
  ConsumerState<CountdownSection> createState() => _CountdownSectionState();
}

class _CountdownSectionState extends ConsumerState<CountdownSection> {
  late Timer _timer;
  Duration _remaining = Duration.zero;

  @override
  void initState() {
    super.initState();
    _tick();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => _tick());
  }

  void _tick() {
    final diff = WeddingConfig.date.difference(DateTime.now());
    setState(() => _remaining = diff.isNegative ? Duration.zero : diff);
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final lang = ref.watch(localeControllerProvider);
    final attending = ref.watch(attendingCountProvider);

    final d = _remaining.inDays;
    final h = _remaining.inHours % 24;
    final m = _remaining.inMinutes % 60;
    final s = _remaining.inSeconds % 60;
    final items = [
      (d, tr(lang, 'days')),
      (h, tr(lang, 'hours')),
      (m, tr(lang, 'minutes')),
      (s, tr(lang, 'seconds')),
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 60),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 900),
        child: Column(
          children: [
            Text(tr(lang, 'countdown'), style: AppTheme.script(size: 32))
                .animate()
                .fadeIn(),
            const GoldDivider(symbol: '❤'),
            const SizedBox(height: 8),
            LayoutBuilder(builder: (context, c) {
              final tile = (c.maxWidth - 36) / 4;
              return Wrap(
                spacing: 12,
                runSpacing: 12,
                children: items.asMap().entries.map((e) {
                  final i = e.key;
                  final v = e.value.$1;
                  final l = e.value.$2;
                  return SizedBox(
                    width: tile.clamp(80, 200),
                    child: GlassCard(
                      padding: const EdgeInsets.symmetric(vertical: 26),
                      child: Column(
                        children: [
                          AnimatedSwitcher(
                            duration: const Duration(milliseconds: 300),
                            child: Text(
                              v.toString().padLeft(2, '0'),
                              key: ValueKey(v),
                              style: Theme.of(context).textTheme.displaySmall?.copyWith(
                                    color: AppPalette.roseDeep,
                                    fontSize: 44,
                                  ),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            l.toUpperCase(),
                            style: TextStyle(
                              fontSize: 11,
                              letterSpacing: 3,
                              color: Theme.of(context).textTheme.bodyMedium?.color
                                  ?.withOpacity(.7),
                            ),
                          ),
                        ],
                      ),
                    ).animate().fadeIn(delay: (i * 100).ms).slideY(begin: .3),
                  );
                }).toList(),
              );
            }),
            const SizedBox(height: 24),
            attending.when(
              loading: () => const SizedBox.shrink(),
              error: (_, __) => const SizedBox.shrink(),
              data: (count) => GlassCard(
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                borderRadius: 100,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _PingDot(),
                    const SizedBox(width: 10),
                    RichText(
                      text: TextSpan(
                        style: Theme.of(context).textTheme.bodyMedium,
                        children: [
                          TextSpan(
                            text: '$count ',
                            style: const TextStyle(
                              color: AppPalette.roseDeep,
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          TextSpan(text: tr(lang, 'attending_now')),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PingDot extends StatefulWidget {
  @override
  State<_PingDot> createState() => _PingDotState();
}

class _PingDotState extends State<_PingDot>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c =
      AnimationController(vsync: this, duration: const Duration(milliseconds: 1400))
        ..repeat();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 12,
      height: 12,
      child: Stack(
        alignment: Alignment.center,
        children: [
          AnimatedBuilder(
            animation: _c,
            builder: (_, __) => Container(
              width: 12 + 12 * _c.value,
              height: 12 + 12 * _c.value,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppPalette.rose.withOpacity(.4 * (1 - _c.value)),
              ),
            ),
          ),
          Container(
            width: 8,
            height: 8,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: AppPalette.rose,
            ),
          ),
        ],
      ),
    );
  }
}
