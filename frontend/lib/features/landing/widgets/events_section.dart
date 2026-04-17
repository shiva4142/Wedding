import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/config/events.dart';
import '../../../core/i18n/translations.dart';
import '../../../core/theme/app_theme.dart';
import '../../../widgets/glass_card.dart';
import '../../../widgets/gold_divider.dart';
import '../../../widgets/primary_button.dart' as ui;

class EventsSection extends ConsumerWidget {
  const EventsSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lang = ref.watch(localeControllerProvider);
    final isWide = MediaQuery.of(context).size.width > 880;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 60),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1100),
          child: Column(
            children: [
              Text(tr(lang, 'join_us'), style: AppTheme.script(size: 32)),
              const SizedBox(height: 4),
              Text(tr(lang, 'events'),
                  style: Theme.of(context).textTheme.displaySmall?.copyWith(fontSize: 38)),
              const GoldDivider(),
              const SizedBox(height: 24),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: weddingEvents.length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: isWide ? 2 : 1,
                  crossAxisSpacing: 22,
                  mainAxisSpacing: 22,
                  childAspectRatio: isWide ? 0.95 : 0.78,
                ),
                itemBuilder: (_, i) =>
                    _EventCard(event: weddingEvents[i], lang: lang, index: i),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EventCard extends StatelessWidget {
  const _EventCard({required this.event, required this.lang, required this.index});
  final WeddingEvent event;
  final AppLang lang;
  final int index;

  @override
  Widget build(BuildContext context) {
    final dateFmt = DateFormat('EEE, MMM d, yyyy').format(event.date);
    final timeFmt = DateFormat('h:mm a').format(event.date);

    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: Stack(
        children: [
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: event.gradient.map((c) => c.withOpacity(.55)).toList(),
                ),
              ),
            ),
          ),
          Positioned.fill(
            child: GlassCard(
              padding: const EdgeInsets.all(22),
              opacity: .42,
              borderRadius: 0,
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(event.emoji, style: const TextStyle(fontSize: 46)),
                        ui.Chip(label: event.dressCode),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(event.title,
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontSize: 26)),
                    const SizedBox(height: 6),
                    Text(event.description, style: AppTheme.serif(size: 16)),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        Expanded(child: _kv(tr(lang, 'days').toUpperCase() == 'DAYS' ? 'DATE' : 'DATE', dateFmt)),
                        Expanded(child: _kv('TIME', timeFmt)),
                      ],
                    ),
                    const SizedBox(height: 10),
                    _kv('VENUE', event.location),
                    const SizedBox(height: 12),
                    InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: () => launchUrl(Uri.parse(
                          'https://www.google.com/maps/search/?api=1&query=${Uri.encodeQueryComponent(event.mapQuery)}')),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          height: 160,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: event.gradient
                                  .map((c) => c.withOpacity(.45))
                                  .toList(),
                            ),
                          ),
                          child: Stack(
                            children: [
                              Positioned.fill(
                                child: CustomPaint(painter: _MapGridPainter()),
                              ),
                              Center(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(Icons.location_on,
                                        size: 36, color: AppPalette.roseDeep),
                                    const SizedBox(height: 4),
                                    Text(event.location,
                                        textAlign: TextAlign.center,
                                        style: const TextStyle(
                                            fontWeight: FontWeight.w600)),
                                    const SizedBox(height: 2),
                                    const Text('Tap to open in Maps',
                                        style: TextStyle(
                                            fontSize: 11,
                                            color: AppPalette.muted)),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 10,
                      runSpacing: 8,
                      children: [
                        ui.GhostButton(
                          label: tr(lang, 'directions'),
                          icon: Icons.directions,
                          onPressed: () => launchUrl(Uri.parse(
                              'https://www.google.com/maps/search/?api=1&query=${Uri.encodeQueryComponent(event.mapQuery)}')),
                        ),
                        ui.GhostButton(
                          label: tr(lang, 'add_to_calendar'),
                          icon: Icons.event,
                          onPressed: () => launchUrl(_calUrl(event)),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: (index * 100).ms).slideY(begin: .15);
  }

  Widget _kv(String k, String v) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(k,
              style: const TextStyle(
                  fontSize: 10, letterSpacing: 2, color: AppPalette.muted)),
          const SizedBox(height: 2),
          Text(v, style: const TextStyle(fontWeight: FontWeight.w600)),
        ],
      );

  Uri _calUrl(WeddingEvent e) {
    String fmt(DateTime d) {
      final u = d.toUtc();
      final s = u.toIso8601String().replaceAll(RegExp(r'[-:.]'), '');
      return '${s.substring(0, 15)}Z';
    }

    final start = fmt(e.date);
    final end = fmt(e.date.add(const Duration(hours: 3)));
    final params = {
      'action': 'TEMPLATE',
      'text': e.title,
      'dates': '$start/$end',
      'location': e.location,
      'details': e.description,
    };
    final qs = params.entries
        .map((e) => '${e.key}=${Uri.encodeQueryComponent(e.value)}')
        .join('&');
    return Uri.parse('https://calendar.google.com/calendar/render?$qs');
  }
}

class _MapGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(.18)
      ..strokeWidth = 1;
    const step = 28.0;
    for (double x = 0; x < size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
    final road = Paint()
      ..color = Colors.white.withOpacity(.5)
      ..strokeWidth = 4
      ..style = PaintingStyle.stroke;
    final path = Path()
      ..moveTo(0, size.height * .7)
      ..quadraticBezierTo(size.width * .3, size.height * .4,
          size.width * .55, size.height * .55)
      ..quadraticBezierTo(
          size.width * .8, size.height * .7, size.width, size.height * .35);
    canvas.drawPath(path, road);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
