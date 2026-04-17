import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/config/wedding_config.dart';
import '../../../core/i18n/translations.dart';
import '../../../core/theme/app_theme.dart';
import '../../../widgets/gold_divider.dart';

class FooterSection extends ConsumerWidget {
  const FooterSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lang = ref.watch(localeControllerProvider);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 50),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: AppPalette.gold.withOpacity(.2)),
        ),
      ),
      child: Center(
        child: Column(
          children: [
            Text('${WeddingConfig.groom} & ${WeddingConfig.bride}',
                style: AppTheme.script(size: 36, color: AppPalette.roseDeep)),
            const SizedBox(height: 6),
            Text(WeddingConfig.hashtag,
                style: const TextStyle(
                    fontSize: 11, letterSpacing: 4, color: AppPalette.muted)),
            const GoldDivider(),
            Wrap(
              alignment: WrapAlignment.center,
              spacing: 6,
              children: [
                Text('${tr(lang, 'made_with_love')} ❤  ·  © ${DateTime.now().year}  ·  ',
                    style: TextStyle(
                        color: Theme.of(context).textTheme.bodyMedium?.color
                            ?.withOpacity(.7))),
                InkWell(
                  onTap: () => context.go('/admin/login'),
                  child: const Text(
                    'Admin',
                    style: TextStyle(
                      decoration: TextDecoration.underline,
                      color: AppPalette.roseDeep,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
