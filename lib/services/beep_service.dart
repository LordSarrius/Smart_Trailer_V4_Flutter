import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';

class BeepService {
  final AudioPlayer _player = AudioPlayer();
  String? _currentZone;
  bool _audioUnlocked = false;

  Future<void> init() async {
    await _player.setReleaseMode(ReleaseMode.loop);
    await _player.setVolume(1.0);
  }

  // Call once on first user tap to unlock audio on Chrome
  Future<void> unlockAudio() async {
    if (_audioUnlocked) return;
    _audioUnlocked = true;
    try {
      await _player.play(AssetSource('audio/beep_slow.wav'));
      await Future.delayed(const Duration(milliseconds: 50));
      await _player.stop();
    } catch (_) {}
    _currentZone = null;
  }

  Future<void> update(double distCm) async {
    final zone = distCm <= 25  ? 'critical'
           : distCm <= 40  ? 'fast'
           : distCm <= 60  ? 'medium'
           : distCm <= 100 ? 'warn'
           : distCm <= 150 ? 'slow'
           : 'off';

    if (zone == _currentZone) return;
    _currentZone = zone;

    await _player.stop();
    if (zone != 'off') {
      await _player.setReleaseMode(ReleaseMode.loop);
      await _player.play(AssetSource('audio/beep_$zone.wav'));
    }
  }

  void dispose() => _player.dispose();
}
