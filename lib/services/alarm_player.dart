import 'package:audioplayers/audioplayers.dart';
import 'package:vibration/vibration.dart';

class AlarmPlaybackService {
  AlarmPlaybackService({AudioPlayer? player}) : _player = player ?? AudioPlayer();

  final AudioPlayer _player;
  bool _isDisposed = false;

  Future<void> playAlarm({
    required String ringtonePath,
    required double volume,
    required bool vibrationEnabled,
  }) async {
    if (_isDisposed) {
      return;
    }

    try {
      final safeVolume = volume.clamp(0.0, 100.0) / 100.0;
      await _player.setVolume(safeVolume);
      await _player.setReleaseMode(ReleaseMode.loop);

      if (ringtonePath.trim().isEmpty) {
        await _player.play(AssetSource('sounds/gentleSunrise.mp3'));
      } else {
        if (ringtonePath.startsWith('http')) {
          await _player.play(UrlSource(ringtonePath));
        } else if (ringtonePath.startsWith('file:')) {
          await _player.play(DeviceFileSource(ringtonePath.replaceFirst('file:', '')));
        } else if (ringtonePath.startsWith('/')) {
          await _player.play(DeviceFileSource(ringtonePath));
        } else {
          await _player.play(AssetSource(ringtonePath));
        }
      }

      if (vibrationEnabled) {
        final hasVibrator = await Vibration.hasVibrator();
        if (hasVibrator == true) {
          Vibration.vibrate(duration: 1000, amplitude: 255);
        }
      }
    } catch (_) {
      // Gracefully fail with no crash.
    }
  }

  Future<void> stop() async {
    if (_isDisposed) {
      return;
    }

    try {
      await _player.stop();
      await _player.release();
    } catch (_) {
      // Gracefully fail with no crash.
    }
  }

  Future<void> dispose() async {
    _isDisposed = true;
    await stop();
  }
}
