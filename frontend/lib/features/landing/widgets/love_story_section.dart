import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/config/love_story.dart';
import '../../../core/i18n/translations.dart';
import '../../../core/theme/app_theme.dart';
import '../../../widgets/glass_card.dart';
import '../../../widgets/gold_divider.dart';
import '../../../widgets/primary_button.dart' as ui;

class LoveStorySection extends ConsumerWidget {
  const LoveStorySection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lang = ref.watch(localeControllerProvider);
    final isWide = MediaQuery.of(context).size.width > 760;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 60),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 980),
          child: Column(
            children: [
              Text(tr(lang, 'how_we_met'), style: AppTheme.script(size: 32)),
              const SizedBox(height: 4),
              Text(tr(lang, 'our_story'),
                  style: Theme.of(context)
                      .textTheme
                      .displaySmall
                      ?.copyWith(fontSize: 38)),
              const GoldDivider(),
              const SizedBox(height: 30),
              for (var i = 0; i < familyEntries.length; i++)
                _StoryRow(
                  entry: familyEntries[i],
                  left: i.isEven,
                  isWide: isWide,
                  isLast: i == familyEntries.length - 1,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StoryRow extends StatelessWidget {
  const _StoryRow({
    required this.entry,
    required this.left,
    required this.isWide,
    required this.isLast,
  });

  final FamilyEntry entry;
  final bool left;
  final bool isWide;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    final card = GlassCard(
      padding: const EdgeInsets.all(22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ui.Chip(label: entry.badge),
          const SizedBox(height: 10),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              if (entry.emoji != null) ...[
                Text(entry.emoji!, style: const TextStyle(fontSize: 26)),
                const SizedBox(width: 10),
              ],
              Expanded(
                child: Text(
                  entry.title,
                  style: Theme.of(context)
                      .textTheme
                      .headlineSmall
                      ?.copyWith(fontSize: 24),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(entry.text, style: AppTheme.serif(size: 17)),
        ],
      ),
    )
        .animate()
        .fadeIn(duration: 700.ms)
        .slideX(begin: left ? -.15 : .15);

    if (!isWide) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 18, left: 30),
        child: Stack(
          children: [
            Positioned(
              left: -22,
              top: 0,
              bottom: isLast ? 30 : -18,
              child: Container(
                width: 1,
                color: AppPalette.gold.withOpacity(.5),
              ),
            ),
            Positioned(
              left: -28,
              top: 14,
              child: _Dot(),
            ),
            card,
          ],
        ),
      );
    }

    final children = [
      Expanded(child: left ? const SizedBox.shrink() : card),
      SizedBox(
        width: 32,
        child: Column(
          children: [
            if (!isLast)
              Container(
                width: 1,
                height: 200,
                color: AppPalette.gold.withOpacity(.45),
              ),
          ],
        ),
      ),
      Expanded(child: left ? card : const SizedBox.shrink()),
    ];

    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Stack(
        alignment: Alignment.topCenter,
        children: [
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: children,
            ),
          ),
          const Positioned(top: 24, child: _Dot()),
        ],
      ),
    );
  }
}

class _Dot extends StatelessWidget {
  const _Dot();
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 14,
      height: 14,
      decoration: BoxDecoration(
        color: AppPalette.rose,
        shape: BoxShape.circle,
        border: Border.all(
          color: Theme.of(context).scaffoldBackgroundColor,
          width: 3,
        ),
        boxShadow: [
          BoxShadow(
            color: AppPalette.rose.withOpacity(.4),
            blurRadius: 12,
          ),
        ],
      ),
    );
  }
}
