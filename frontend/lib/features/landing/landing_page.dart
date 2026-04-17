import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/i18n/translations.dart';
import 'widgets/countdown_section.dart';
import 'widgets/events_section.dart';
import 'widgets/footer_section.dart';
import 'widgets/gallery_section.dart';
import 'widgets/hero_section.dart';
import 'widgets/inviter_section.dart';
import 'widgets/love_story_section.dart';
import 'widgets/music_player_fab.dart';
import 'widgets/nav_bar.dart';
import 'widgets/rsvp_section.dart';
import 'widgets/share_fab.dart';
import 'widgets/wishes_section.dart';

class LandingPage extends ConsumerStatefulWidget {
  const LandingPage({super.key, this.guestName, this.guestSlug});
  final String? guestName;
  final String? guestSlug;

  @override
  ConsumerState<LandingPage> createState() => _LandingPageState();
}

class _LandingPageState extends ConsumerState<LandingPage> {
  final _scroll = ScrollController();
  final _heroKey = GlobalKey();
  final _storyKey = GlobalKey();
  final _eventsKey = GlobalKey();
  final _galleryKey = GlobalKey();
  final _rsvpKey = GlobalKey();
  final _wishesKey = GlobalKey();

  double _offset = 0;

  @override
  void initState() {
    super.initState();
    _scroll.addListener(() => setState(() => _offset = _scroll.offset));
  }

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  void _scrollTo(GlobalKey key) {
    final ctx = key.currentContext;
    if (ctx == null) return;
    Scrollable.ensureVisible(
      ctx,
      duration: const Duration(milliseconds: 700),
      curve: Curves.easeInOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    final lang = ref.watch(localeControllerProvider);
    return Scaffold(
      body: Stack(
        children: [
          SingleChildScrollView(
            controller: _scroll,
            child: Column(
              children: [
                KeyedSubtree(
                  key: _heroKey,
                  child: HeroSection(
                    guestName: widget.guestName,
                    onRsvp: () => _scrollTo(_rsvpKey),
                    onEvents: () => _scrollTo(_eventsKey),
                  ),
                ),
                const CountdownSection(),
                KeyedSubtree(key: _storyKey, child: const LoveStorySection()),
                const InviterSection(),
                KeyedSubtree(key: _eventsKey, child: const EventsSection()),
                KeyedSubtree(key: _galleryKey, child: const GallerySection()),
                KeyedSubtree(
                  key: _rsvpKey,
                  child: RsvpSection(
                    guestName: widget.guestName,
                    guestSlug: widget.guestSlug,
                  ),
                ),
                KeyedSubtree(key: _wishesKey, child: const WishesSection()),
                const FooterSection(),
              ],
            ),
          ),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: TopNavBar(
              scrollOffset: _offset,
              links: [
                NavLink(tr(lang, 'home'), () => _scrollTo(_heroKey)),
                NavLink(tr(lang, 'story'), () => _scrollTo(_storyKey)),
                NavLink(tr(lang, 'events'), () => _scrollTo(_eventsKey)),
                NavLink(tr(lang, 'gallery'), () => _scrollTo(_galleryKey)),
                NavLink(tr(lang, 'rsvp'), () => _scrollTo(_rsvpKey)),
                NavLink(tr(lang, 'wishes'), () => _scrollTo(_wishesKey)),
              ],
            ),
          ),
          const MusicPlayerFab(),
          ShareFab(guestSlug: widget.guestSlug, guestName: widget.guestName),
        ],
      ),
    );
  }
}
