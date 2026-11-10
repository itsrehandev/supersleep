import 'dart:async';

import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../core/app_router.dart';
import '../models/alarm_model.dart';
import '../services/alarm_store.dart';

@pragma('vm:entry-point')
void alarmFireCallback(int id) {
  final context = rootNavigatorKey.currentContext;
  if (context != null && context.mounted) {
    context.go('/ringing');
  }
}

class AlarmSchedulerService {
  AlarmSchedulerService._();

  static final AlarmSchedulerService instance = AlarmSchedulerService._();

  Timer? _timer;
  final Map<String, DateTime> _lastTriggeredAt = {};

  Future<void> start() async {
    _timer?.cancel();
    try {
      await AndroidAlarmManager.initialize();
    } catch (_) {
      // Gracefully handle if platform is non-Android
    }
    _checkNow();
    _timer = Timer.periodic(const Duration(seconds: 10), (_) => _checkNow());
  }

  void stop() {
    _timer?.cancel();
    _timer = null;
  }

  void scheduleAlarmInOS(Alarm alarm) async {
    if (!alarm.isEnabled) {
      return;
    }

    final fireDateTime = alarm.getNextFireDateTime();
    final int alarmId = alarm.id.hashCode & 0x7FFFFFFF;

    try {
      await AndroidAlarmManager.oneShotAt(
        fireDateTime,
        alarmId,
        alarmFireCallback,
        exact: true,
        wakeup: true,
        alarmClock: true,
        allowWhileIdle: true,
        rescheduleOnReboot: true,
      );
    } catch (e) {
      debugPrint('Error scheduling OS alarm: $e');
    }
  }

  void cancelAlarmInOS(String alarmIdStr) async {
    final int alarmId = alarmIdStr.hashCode & 0x7FFFFFFF;
    try {
      await AndroidAlarmManager.cancel(alarmId);
    } catch (_) {}
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

    final weekday = (now.weekday - 1) % 7;
    if (alarm.repeatDays.isEmpty) {
      final todaysCandidate = DateTime(
        now.year,
        now.month,
        now.day,
        alarm.time.hour,
        alarm.time.minute,
      );
      final deltaSeconds = now.difference(todaysCandidate).inSeconds;
      return deltaSeconds >= 0 && deltaSeconds <= 59;
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
    if (context == null || !context.mounted) {
      return;
    }

    context.go('/ringing');
  }
}
