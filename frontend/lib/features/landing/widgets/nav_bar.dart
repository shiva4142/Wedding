import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/config/wedding_config.dart';
import '../../../core/i18n/translations.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/theme_controller.dart';

class NavLink {
  const NavLink(this.label, this.onTap);
  final String label;
  final VoidCallback onTap;
}

class TopNavBar extends ConsumerStatefulWidget {
  const TopNavBar({super.key, required this.links, required this.scrollOffset});
  final List<NavLink> links;
  final double scrollOffset;

  @override
  ConsumerState<TopNavBar> createState() => _TopNavBarState();
}

class _TopNavBarState extends ConsumerState<TopNavBar> {
  bool _menuOpen = false;

  @override
  Widget build(BuildContext context) {
    final scrolled = widget.scrollOffset > 30;
    final lang = ref.watch(localeControllerProvider);
    final mode = ref.watch(themeControllerProvider);
    final isWide = MediaQuery.of(context).size.width > 760;

    return Column(
      children: [
        ClipRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: scrolled ? 18 : 0, sigmaY: scrolled ? 18 : 0),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              padding: EdgeInsets.symmetric(
                  horizontal: 24, vertical: scrolled ? 10 : 18),
              decoration: BoxDecoration(
                color: scrolled
                    ? Theme.of(context).scaffoldBackgroundColor.withOpacity(.7)
                    : Colors.transparent,
                border: scrolled
                    ? Border(
                        bottom: BorderSide(
                          color: AppPalette.gold.withOpacity(.2),
                        ),
                      )
                    : null,
              ),
              child: Row(
                children: [
                  Text('${WeddingConfig.groom[0]}&${WeddingConfig.bride[0]}',
                      style: AppTheme.script(size: 28, color: AppPalette.roseDeep)),
                  const SizedBox(width: 10),
                  if (isWide)
                    Text(
                      '${WeddingConfig.groom}  &  ${WeddingConfig.bride}',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 18),
                    ),
                  const Spacer(),
                  if (isWide)
                    for (final l in widget.links)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: TextButton(
                          onPressed: l.onTap,
                          child: Text(l.label,
                              style: TextStyle(
                                color: Theme.of(context).textTheme.bodyMedium?.color,
                                fontWeight: FontWeight.w500,
                              )),
                        ),
                      ),
                  const SizedBox(width: 8),
                  _LangMenuButton(
                    current: lang,
                    onChange: (l) =>
                        ref.read(localeControllerProvider.notifier).setLang(l),
                  ),
                  const SizedBox(width: 8),
                  _circleBtn(
                    icon: mode == ThemeMode.dark ? Icons.wb_sunny_outlined : Icons.nightlight_outlined,
                    onTap: () => ref.read(themeControllerProvider.notifier).toggle(),
                  ),
                  if (!isWide) ...[
                    const SizedBox(width: 8),
                    _circleBtn(
                      icon: _menuOpen ? Icons.close : Icons.menu,
                      onTap: () => setState(() => _menuOpen = !_menuOpen),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
        if (!isWide && _menuOpen)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            color: Theme.of(context).scaffoldBackgroundColor.withOpacity(.95),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (final l in widget.links)
                  TextButton(
                    onPressed: () {
                      setState(() => _menuOpen = false);
                      l.onTap();
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Text(l.label, style: const TextStyle(fontSize: 16)),
                    ),
                  ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _circleBtn({String? label, IconData? icon, required VoidCallback onTap}) {
    return InkWell(
      borderRadius: BorderRadius.circular(40),
      onTap: onTap,
      child: Container(
        width: 38,
        height: 38,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: AppPalette.gold.withOpacity(.45)),
        ),
        child: icon != null
            ? Icon(icon, size: 16)
            : Text(label!,
                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700)),
      ),
    );
  }
}

class _LangMenuButton extends StatelessWidget {
  const _LangMenuButton({required this.current, required this.onChange});
  final AppLang current;
  final ValueChanged<AppLang> onChange;

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<AppLang>(
      tooltip: 'Language',
      onSelected: onChange,
      position: PopupMenuPosition.under,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      itemBuilder: (_) => [
        for (final l in AppLang.values)
          PopupMenuItem<AppLang>(
            value: l,
            child: Row(
              children: [
                SizedBox(
                  width: 28,
                  child: Text(l.pill,
                      style: const TextStyle(fontWeight: FontWeight.w700)),
                ),
                const SizedBox(width: 8),
                Text(l.displayName),
                const Spacer(),
                if (l == current)
                  const Icon(Icons.check, size: 16, color: AppPalette.rose),
              ],
            ),
          ),
      ],
      child: Container(
        width: 38,
        height: 38,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: AppPalette.gold.withOpacity(.45)),
        ),
        child: Text(
          current.pill,
          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700),
        ),
      ),
    );
  }
}
