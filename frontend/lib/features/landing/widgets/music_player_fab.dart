import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_theme.dart';
import '../../../services/providers.dart';

/// Bundled track: add `assets/audio/wedding_song.mp3` (see assets/audio/README.md).
const _musicAsset = 'assets/audio/wedding_song.mp3';

class MusicPlayerFab extends ConsumerStatefulWidget {
  const MusicPlayerFab({super.key});
  @override
  ConsumerState<MusicPlayerFab> createState() => _MusicPlayerFabState();
}

class _MusicPlayerFabState extends ConsumerState<MusicPlayerFab> {
  final _player = AudioPlayer();

  @override
  void initState() {
    super.initState();
    _player.setReleaseMode(ReleaseMode.loop);
    _player.setVolume(0.35);
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  Future<void> _toggle() async {
    final on = !ref.read(musicOnProvider);
    ref.read(musicOnProvider.notifier).state = on;
    if (on) {
      await _player.play(AssetSource(_musicAsset));
    } else {
      await _player.pause();
    }
  }

  @override
  Widget build(BuildContext context) {
    final on = ref.watch(musicOnProvider);
    final fab = Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Theme.of(context).scaffoldBackgroundColor.withOpacity(.85),
        border: Border.all(color: AppPalette.gold.withOpacity(.5)),
        boxShadow: [
          BoxShadow(
            color: AppPalette.rose.withOpacity(.25),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Center(
        child: Text(on ? '🎵' : '🎶', style: const TextStyle(fontSize: 22))
            .animate(onPlay: (c) => on ? c.repeat() : c.stop())
            .rotate(duration: 4.seconds, begin: 0, end: 1),
      ),
    );

    return Positioned(
      left: 20,
      bottom: 20,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(40),
          onTap: _toggle,
          child: fab,
        ),
      ),
    );
  }
}
