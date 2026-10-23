import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';

import '../models/ayah.dart';

/// Pembungkus pemutar audio: hanya satu ayat yang diputar pada satu waktu.
class AyahAudio {
  AyahAudio({required this.onChanged, this.onError}) {
    _sub = _player.onPlayerComplete.listen((_) {
      playingId = null;
      onChanged();
    });
  }

  final AudioPlayer _player = AudioPlayer();
  final VoidCallback onChanged;
  final void Function(String message)? onError;
  late final StreamSubscription<void> _sub;

  /// id ayat yang sedang diputar (null jika tidak ada).
  int? playingId;

  Future<void> toggle(Ayah ayah) async {
    if (playingId == ayah.id) {
      await stop();
      return;
    }
    if (ayah.audioUrl.isEmpty) {
      onError?.call('Audio untuk ayat ini tidak tersedia.');
      return;
    }
    try {
      await _player.stop();
      playingId = ayah.id;
      onChanged();
      await _player.play(UrlSource(ayah.audioUrl));
    } catch (_) {
      playingId = null;
      onChanged();
      onError?.call('Audio tidak dapat diputar. Periksa koneksi internet.');
    }
  }

  Future<void> stop() async {
    await _player.stop();
    playingId = null;
    onChanged();
  }

  Future<void> dispose() async {
    await _sub.cancel();
    await _player.dispose();
  }
}
