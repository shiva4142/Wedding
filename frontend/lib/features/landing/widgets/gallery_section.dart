import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/config/love_story.dart';
import '../../../core/i18n/translations.dart';
import '../../../core/theme/app_theme.dart';
import '../../../widgets/gold_divider.dart';

class GallerySection extends ConsumerWidget {
  const GallerySection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lang = ref.watch(localeControllerProvider);
    final w = MediaQuery.of(context).size.width;
    final cols = w > 1100 ? 4 : (w > 700 ? 3 : 2);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 60),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: Column(
            children: [
              Text(tr(lang, 'gallery_sub'), style: AppTheme.script(size: 32)),
              const SizedBox(height: 4),
              Text(tr(lang, 'gallery'),
                  style: Theme.of(context).textTheme.displaySmall?.copyWith(fontSize: 38)),
              const GoldDivider(),
              const SizedBox(height: 20),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: cols,
                  crossAxisSpacing: 14,
                  mainAxisSpacing: 14,
                  childAspectRatio: 1,
                ),
                itemCount: galleryImages.length,
                itemBuilder: (_, i) {
                  final src = galleryImages[i];
                  return MouseRegion(
                    cursor: SystemMouseCursors.click,
                    child: GestureDetector(
                      onTap: () => _openLightbox(context, i),
                      child: Hero(
                        tag: 'gal-$i',
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(18),
                          child: Image.asset(
                            src,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) =>
                                _GalleryPlaceholder(index: i),
                          ),
                        ),
                      ),
                    ),
                  ).animate().fadeIn(delay: (i * 60).ms).scale(begin: const Offset(.96, .96));
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _openLightbox(BuildContext context, int initialIndex) {
    Navigator.of(context).push(PageRouteBuilder(
      opaque: false,
      barrierColor: Colors.black87,
      transitionDuration: const Duration(milliseconds: 250),
      pageBuilder: (_, a, __) => _LightboxPage(initialIndex: initialIndex),
      transitionsBuilder: (_, a, __, c) => FadeTransition(opacity: a, child: c),
    ));
  }
}

class _LightboxPage extends StatefulWidget {
  const _LightboxPage({required this.initialIndex});
  final int initialIndex;

  @override
  State<_LightboxPage> createState() => _LightboxPageState();
}

class _LightboxPageState extends State<_LightboxPage> {
  late int _index = widget.initialIndex;
  late final PageController _pc =
      PageController(initialPage: widget.initialIndex);

  @override
  void dispose() {
    _pc.dispose();
    super.dispose();
  }

  void _go(int delta) {
    final n = (_index + delta) % galleryImages.length;
    setState(() => _index = n < 0 ? n + galleryImages.length : n);
    _pc.animateToPage(_index,
        duration: const Duration(milliseconds: 220), curve: Curves.easeOut);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: GestureDetector(
        onTap: () => Navigator.of(context).pop(),
        child: Stack(
          children: [
            Positioned.fill(
              child: PageView.builder(
                controller: _pc,
                onPageChanged: (i) => setState(() => _index = i),
                itemCount: galleryImages.length,
                itemBuilder: (_, i) => Center(
                  child: Hero(
                    tag: 'gal-$i',
                    child: InteractiveViewer(
                      child: Image.asset(
                        galleryImages[i],
                        fit: BoxFit.contain,
                        errorBuilder: (_, __, ___) =>
                            _GalleryPlaceholder(index: i, large: true),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              top: 16,
              right: 16,
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.white, size: 28),
                onPressed: () => Navigator.pop(context),
              ),
            ),
            Positioned(
              left: 8,
              top: 0,
              bottom: 0,
              child: Center(
                child: IconButton(
                  icon: const Icon(Icons.chevron_left, color: Colors.white, size: 44),
                  onPressed: () => _go(-1),
                ),
              ),
            ),
            Positioned(
              right: 8,
              top: 0,
              bottom: 0,
              child: Center(
                child: IconButton(
                  icon: const Icon(Icons.chevron_right, color: Colors.white, size: 44),
                  onPressed: () => _go(1),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GalleryPlaceholder extends StatelessWidget {
  const _GalleryPlaceholder({required this.index, this.large = false});
  final int index;
  final bool large;

  @override
  Widget build(BuildContext context) {
    final path = galleryImages[index];
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppPalette.goldSoft.withOpacity(.55),
            AppPalette.rose.withOpacity(.35),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      alignment: Alignment.center,
      child: Padding(
        padding: EdgeInsets.all(large ? 32 : 14),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('📸', style: TextStyle(fontSize: large ? 64 : 34)),
            SizedBox(height: large ? 18 : 8),
            Text(
              'Photo ${index + 1}',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: large ? 20 : 13,
                color: Colors.white,
              ),
            ),
            if (large) ...[
              const SizedBox(height: 6),
              Text(
                'Drop your image at\n$path',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 13,
                  color: Colors.white70,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
