import 'dart:async';

import 'package:flutter/material.dart';

import '../models/alarm_model.dart';
import '../screens/ringing/ringing_screen.dart';
import '../services/alarm_store.dart';

final GlobalKey<NavigatorState> rootNavigatorKey = GlobalKey<NavigatorState>();

class AlarmSchedulerService {
  AlarmSchedulerService._();

  static final AlarmSchedulerService instance = AlarmSchedulerService._();

  Timer? _timer;
  final Map<String, DateTime> _lastTriggeredAt = {};

  void start() {
    _timer?.cancel();
    _checkNow();
    _timer = Timer.periodic(const Duration(seconds: 15), (_) => _checkNow());
  }

  void stop() {
    _timer?.cancel();
    _timer = null;
  }

  void _checkNow() {
    final now = DateTime.now();
    for (final alarm in AlarmStore.instance.alarms) {
      if (!alarm.isEnabled || !_shouldRingNow(alarm, now)) {
        continue;
      }

      final last = _lastTriggeredAt[alarm.id];
      if (last != null && _sameDay(last, now)) {
        continue;
      }

      _lastTriggeredAt[alarm.id] = now;
      _triggerAlarm(alarm);
    }
  }

  bool _shouldRingNow(Alarm alarm, DateTime now) {
    final sameHour = alarm.time.hour == now.hour;
    final sameMinute = alarm.time.minute == now.minute;
    if (!sameHour || !sameMinute) {
      return false;
    }

    final toleranceSeconds = now.second;
    if (toleranceSeconds > 30) {
      return false;
    }

    final weekday = (now.weekday - 1) % 7;
    if (alarm.repeatDays.isEmpty) {
      final todaysCandidate = DateTime(
        now.year,
        now.month,
        now.day,
        alarm.time.hour,
        alarm.time.minute,
      );
      final deltaMinutes = now.difference(todaysCandidate).inMinutes;
      return deltaMinutes >= 0 && deltaMinutes < 2;
    }

    return alarm.repeatDays.contains(weekday);
  }

  bool _sameDay(DateTime first, DateTime second) {
    return first.year == second.year &&
        first.month == second.month &&
        first.day == second.day;
  }

  void _triggerAlarm(Alarm alarm) {
    final context = rootNavigatorKey.currentContext;
    if (context == null) {
      return;
    }

    final label = alarm.label.trim().isEmpty ? 'Super Sleep Alarm' : alarm.label.trim();
    final route = MaterialPageRoute<void>(
      builder: (_) => Scaffold(
        body: ActiveAlarmScreen(alarmLabel: label),
      ),
    );

    Navigator.of(context, rootNavigator: true).push(route);
  }
}
