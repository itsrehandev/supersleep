import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../services/alarm_player.dart';
import '../../services/alarm_store.dart';

class ActiveAlarmScreen extends StatefulWidget {
  const ActiveAlarmScreen({
    super.key,
    this.alarmId,
    this.alarmLabel = 'Super Sleep Alarm',
  });

  final String? alarmId;
  final String alarmLabel;

  @override
  State<ActiveAlarmScreen> createState() => _ActiveAlarmScreenState();
}

class _ActiveAlarmScreenState extends State<ActiveAlarmScreen> {
  final AlarmPlaybackService _player = AlarmPlaybackService();
  bool _isSnoozed = false;

  @override
  void initState() {
    super.initState();
    _startAlarm();
  }

  Future<void> _startAlarm() async {
    try {
      await _player.playAlarm(
        ringtonePath: 'sounds/gentleSunrise.mp3',
        volume: 85,
        vibrationEnabled: true,
      );
    } catch (_) {
      // Silent fail
    }
  }

  void _navigateHome() {
    if (!mounted) return;
    if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    } else {
      context.go('/alarms');
    }
  }

  Future<void> _stopAlarm() async {
    await _player.stop();
    await AlarmStore.instance.completeAlarmDismissal(widget.alarmId);
    _navigateHome();
  }

  Future<void> _snoozeAlarm() async {
    setState(() => _isSnoozed = true);
    await _player.stop();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Alarm snoozed for 5 minutes')),
      );
    }
    _navigateHome();
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Icon(
                Icons.alarm_on_rounded,
                size: 88,
                color: colorScheme.primary,
              ),
              const SizedBox(height: 20),
              Text(
                widget.alarmLabel,
                textAlign: TextAlign.center,
                style: theme.textTheme.headlineMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                _isSnoozed ? 'Snoozed' : 'Wake up! Time to start the day',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: Colors.white70,
                ),
              ),
              const SizedBox(height: 36),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  ElevatedButton.icon(
                    onPressed: _snoozeAlarm,
                    icon: const Icon(Icons.snooze_rounded),
                    label: const Text('Snooze'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFF59E0B),
                      foregroundColor: Colors.white,
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: _stopAlarm,
                    icon: const Icon(Icons.check_circle_rounded),
                    label: const Text('Dismiss'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2563EB),
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
