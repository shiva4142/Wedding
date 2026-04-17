import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/i18n/translations.dart';
import '../../../core/theme/app_theme.dart';
import '../../../models/wish.dart';
import '../../../services/api_service.dart';
import '../../../services/providers.dart';
import '../../../widgets/glass_card.dart';
import '../../../widgets/gold_divider.dart';
import '../../../widgets/primary_button.dart' as ui;

class WishesSection extends ConsumerStatefulWidget {
  const WishesSection({super.key});
  @override
  ConsumerState<WishesSection> createState() => _WishesSectionState();
}

class _WishesSectionState extends ConsumerState<WishesSection> {
  final _name = TextEditingController();
  final _msg = TextEditingController();
  bool _sending = false;

  static const _palette = [
    [Color(0xFFFFC2D1), Color(0xFFE55A7E)],
    [Color(0xFFFFE082), Color(0xFFD4AF37)],
    [Color(0xFFA5D6A7), Color(0xFF66BB6A)],
    [Color(0xFFCE93D8), Color(0xFFAB47BC)],
    [Color(0xFF90CAF9), Color(0xFF5C6BC0)],
  ];

  Future<void> _send() async {
    if (_name.text.trim().isEmpty || _msg.text.trim().isEmpty) return;
    setState(() => _sending = true);
    try {
      await ref.read(apiServiceProvider).sendWish(_name.text.trim(), _msg.text.trim());
      _msg.clear();
    } finally {
      setState(() => _sending = false);
    }
  }

  @override
  void dispose() {
    _name.dispose();
    _msg.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final lang = ref.watch(localeControllerProvider);
    final wishes = ref.watch(wishesProvider);
    final w = MediaQuery.of(context).size.width;
    final cols = w > 1000 ? 3 : (w > 640 ? 2 : 1);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 60),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1100),
          child: Column(
            children: [
              Text(tr(lang, 'wishes_sub'), style: AppTheme.script(size: 32)),
              const SizedBox(height: 4),
              Text(tr(lang, 'wishes'),
                  style: Theme.of(context).textTheme.displaySmall?.copyWith(fontSize: 38)),
              const GoldDivider(),
              const SizedBox(height: 18),
              GlassCard(
                padding: const EdgeInsets.all(16),
                child: LayoutBuilder(builder: (context, c) {
                  final wide = c.maxWidth > 720;
                  final nameField = TextField(
                    controller: _name,
                    decoration: const InputDecoration(
                      hintText: 'Your name',
                      border: OutlineInputBorder(),
                    ),
                  );
                  final msgField = TextField(
                    controller: _msg,
                    decoration: InputDecoration(
                      hintText: tr(lang, 'your_wish'),
                      border: const OutlineInputBorder(),
                    ),
                  );
                  final btn = ui.PrimaryButton(
                    label: _sending ? '...' : tr(lang, 'send_wish'),
                    icon: Icons.favorite,
                    onPressed: _sending ? null : _send,
                  );
                  if (wide) {
                    return Row(
                      children: [
                        SizedBox(width: 200, child: nameField),
                        const SizedBox(width: 12),
                        Expanded(child: msgField),
                        const SizedBox(width: 12),
                        btn,
                      ],
                    );
                  }
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      nameField,
                      const SizedBox(height: 10),
                      msgField,
                      const SizedBox(height: 10),
                      Align(alignment: Alignment.centerRight, child: btn),
                    ],
                  );
                }),
              ),
              const SizedBox(height: 22),
              wishes.when(
                loading: () => const Padding(
                  padding: EdgeInsets.all(40),
                  child: CircularProgressIndicator(color: AppPalette.rose),
                ),
                error: (_, __) => const Text("Couldn't load wishes."),
                data: (list) {
                  if (list.isEmpty) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 30),
                      child: Text('Be the first to leave a wish ❤',
                          style: TextStyle(
                              color: Theme.of(context).textTheme.bodyMedium?.color
                                  ?.withOpacity(.7))),
                    );
                  }
                  return GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: cols,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      mainAxisExtent: 200,
                    ),
                    itemCount: list.length,
                    itemBuilder: (_, i) => _WishCard(
                      wish: list[i],
                      colors: _palette[i % _palette.length],
                      tilt: ((i % 3) - 1) * 1.2,
                    ).animate().fadeIn(delay: (i * 60).ms).scale(begin: const Offset(.92, .92)),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _WishCard extends StatelessWidget {
  const _WishCard({required this.wish, required this.colors, required this.tilt});
  final Wish wish;
  final List<Color> colors;
  final double tilt;

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: tilt * pi / 180,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: colors,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: colors.first.withOpacity(.4),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Align(
              alignment: Alignment.topRight,
              child: Text('❤', style: TextStyle(fontSize: 18)),
            ),
            Expanded(
              child: Text(
                '"${wish.message}"',
                style: AppTheme.serif(size: 18, color: AppPalette.ink),
                overflow: TextOverflow.ellipsis,
                maxLines: 5,
              ),
            ),
            const SizedBox(height: 8),
            Text('— ${wish.name}',
                style: AppTheme.script(size: 28, color: AppPalette.ink)),
          ],
        ),
      ),
    );
  }
}
