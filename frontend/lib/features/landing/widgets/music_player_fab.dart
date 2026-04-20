import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_theme.dart';
import '../../../services/providers.dart';

/// Path *inside* the Flutter `assets/` folder (pubspec: `assets/audio/wedding_song.mp3`).
/// [AudioPlayer] adds the `assets/` prefix — do not repeat it or the file 404s on web.
const _musicAsset = 'audio/wedding_song.mp3';

class MusicPlayerFab extends ConsumerStatefulWidget {
  const MusicPlayerFab({super.key});
  @override
  ConsumerState<MusicPlayerFab> createState() => _MusicPlayerFabState();
}

class _MusicPlayerFabState extends ConsumerState<MusicPlayerFab> {
  late final AudioPlayer _player = AudioPlayer();

  @override
  void initState() {
    super.initState();
    if (kIsWeb) {
      // Long-form music on web: avoid low-latency mode (can fail for MP3).
      _player.setPlayerMode(PlayerMode.mediaPlayer);
    }
    _player.setReleaseMode(ReleaseMode.loop);
    _player.setVolume(0.5);
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  Future<void> _toggle() async {
    final wasOn = ref.read(musicOnProvider);
    final on = !wasOn;
    if (on) {
      try {
        await _player.play(AssetSource(_musicAsset));
        if (mounted) ref.read(musicOnProvider.notifier).state = true;
      } catch (e, st) {
        debugPrint('Music play failed: $e\n$st');
        if (mounted) {
          ref.read(musicOnProvider.notifier).state = false;
          ScaffoldMessenger.maybeOf(context)?.showSnackBar(
            SnackBar(content: Text('Could not play music: $e')),
          );
        }
      }
    } else {
      ref.read(musicOnProvider.notifier).state = false;
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
