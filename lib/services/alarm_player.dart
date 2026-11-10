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
      // Explicitly set Android Alarm Stream so sound plays through Phone Alarm Volume
      await _player.setAudioContext(
        AudioContext(
          android: const AudioContextAndroid(
            usageType: AndroidUsageType.alarm,
            contentType: AndroidContentType.sonification,
            audioFocus: AndroidAudioFocus.gainTransientExclusive,
          ),
        ),
      );

      final safeVolume = volume.clamp(0.0, 100.0) / 100.0;
      await _player.setVolume(safeVolume);
      await _player.setReleaseMode(ReleaseMode.loop);

      final cleanPath = ringtonePath.trim();
      if (cleanPath.isEmpty) {
        await _player.play(AssetSource('sounds/gentleSunrise.mp3'));
      } else if (cleanPath.startsWith('http')) {
        await _player.play(UrlSource(cleanPath));
      } else if (cleanPath.startsWith('file:')) {
        await _player.play(DeviceFileSource(cleanPath.replaceFirst('file:', '')));
      } else if (cleanPath.startsWith('/')) {
        await _player.play(DeviceFileSource(cleanPath));
      } else {
        final relativeAsset = cleanPath
            .replaceFirst('assets/', '')
            .replaceFirst('lib/assets/', '');
        await _player.play(AssetSource(relativeAsset));
      }

      if (vibrationEnabled) {
        final hasVibrator = await Vibration.hasVibrator();
        if (hasVibrator == true) {
          Vibration.vibrate(pattern: [500, 1000, 500, 1000], repeat: 0);
        }
      }
    } catch (_) {
      // Fallback
    }
  }

  Future<void> stop() async {
    if (_isDisposed) {
      return;
    }

    try {
      await _player.stop();
      await _player.release();
      Vibration.cancel();
    } catch (_) {
      // Fallback
    }
  }

  Future<void> dispose() async {
    _isDisposed = true;
    await stop();
  }
}
