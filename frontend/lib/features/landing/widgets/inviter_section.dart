import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../core/theme/app_theme.dart';
import '../../../widgets/glass_card.dart';
import '../../../widgets/gold_divider.dart';

// ============================================================
//  Edit these to customize the "little inviter" card.
// ------------------------------------------------------------
//  - [inviterName]     → the child's name.
//  - [inviterRelation] → small caption under the name (e.g.
//                        "Niece of the Groom").
//  - [inviterImage]    → a local asset path. Drop the photo at
//                        frontend/assets/images/niece.jpg
//                        (see assets/images/README.md).
//  - [inviterMessage]  → the sweet invitation line.
// ============================================================

const String inviterName = 'Pradya';
const String inviterRelation = 'Niece of the Groom';
const String inviterImage = 'assets/images/gallery/Pradya.jpeg';
const String inviterMessage =
    'With lots of love and joy, I warmly invite you to celebrate '
    "my chinnanna Shiva and Pooja pinni's wedding. "
    'Your blessings will make our family complete!';

class InviterSection extends StatelessWidget {
  const InviterSection({super.key});

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width > 780;

    final photo = _CirclePhoto(imageUrl: inviterImage);

    final textBlock = Column(
      crossAxisAlignment:
          isWide ? CrossAxisAlignment.start : CrossAxisAlignment.center,
      children: [
        Text(
          'A little invitation',
          style: AppTheme.script(size: 30, color: AppPalette.roseDeep),
        ),
        const SizedBox(height: 4),
        Text(
          'from someone very special',
          style: TextStyle(
            letterSpacing: 4,
            fontSize: 12,
            color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(.7),
          ),
        ),
        const SizedBox(height: 18),
        Text(
          inviterName,
          textAlign: isWide ? TextAlign.start : TextAlign.center,
          style: Theme.of(context).textTheme.displaySmall?.copyWith(fontSize: 34),
        ),
        const SizedBox(height: 4),
        Text(
          inviterRelation,
          textAlign: isWide ? TextAlign.start : TextAlign.center,
          style: TextStyle(
            fontStyle: FontStyle.italic,
            fontSize: 14,
            color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(.75),
          ),
        ),
        const SizedBox(height: 16),
        Container(
          height: 1,
          width: 60,
          color: AppPalette.gold.withOpacity(.5),
        ),
        const SizedBox(height: 16),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 460),
          child: Text(
            inviterMessage,
            textAlign: isWide ? TextAlign.start : TextAlign.center,
            style: AppTheme.serif(size: 17),
          ),
        ),
      ],
    );

    final content = isWide
        ? Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              photo,
              const SizedBox(width: 36),
              Expanded(child: textBlock),
            ],
          )
        : Column(
            children: [
              photo,
              const SizedBox(height: 24),
              textBlock,
            ],
          );

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 900),
          child: Column(
            children: [
              const Text('🎀', style: TextStyle(fontSize: 28))
                  .animate(onPlay: (c) => c.repeat(reverse: true))
                  .scaleXY(duration: 2.seconds, end: 1.15),
              const SizedBox(height: 8),
              const GoldDivider(symbol: '❤'),
              const SizedBox(height: 22),
              GlassCard(
                padding: const EdgeInsets.all(28),
                child: content,
              )
                  .animate()
                  .fadeIn(duration: 700.ms)
                  .slideY(begin: .1, curve: Curves.easeOut),
            ],
          ),
        ),
      ),
    );
  }
}

class _CirclePhoto extends StatelessWidget {
  const _CirclePhoto({required this.imageUrl});
  final String imageUrl;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 190,
      height: 190,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const LinearGradient(
          colors: [AppPalette.goldSoft, AppPalette.rose, AppPalette.gold],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: AppPalette.rose.withOpacity(.35),
            blurRadius: 30,
            spreadRadius: 2,
          ),
        ],
      ),
      padding: const EdgeInsets.all(5),
      child: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white, width: 4),
        ),
        child: ClipOval(
          child: Image.asset(
            imageUrl,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => Container(
              color: AppPalette.cardLight,
              alignment: Alignment.center,
              child: const Text('👧', style: TextStyle(fontSize: 80)),
            ),
          ),
        ),
      ),
    )
        .animate(onPlay: (c) => c.repeat(reverse: true))
        .moveY(begin: 0, end: -6, duration: 3.seconds, curve: Curves.easeInOut);
  }
}
