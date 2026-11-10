import 'package:flutter/material.dart';

import '../models/alarm_model.dart';
import 'alarm_scheduler.dart';
import 'database_service.dart';

class AlarmStore {
  AlarmStore._();
  static final AlarmStore instance = AlarmStore._();

  final ValueNotifier<List<Alarm>> alarmsNotifier =
      ValueNotifier<List<Alarm>>([]);

  List<Alarm> get alarms => List.unmodifiable(_sortedAlarms(alarmsNotifier.value));

  Future<void> loadAlarmsFromDb() async {
    final loaded = await DatabaseService.instance.getAllAlarms();
    alarmsNotifier.value = _sortedAlarms(loaded);
    for (final alarm in loaded) {
      if (alarm.isEnabled) {
        AlarmSchedulerService.instance.scheduleAlarmInOS(alarm);
      }
    }
  }

  Future<void> addAlarm(Alarm alarm) async {
    final current = List<Alarm>.from(alarmsNotifier.value);
    current.add(alarm);
    alarmsNotifier.value = _sortedAlarms(current);

    await DatabaseService.instance.insertAlarm(alarm);
    if (alarm.isEnabled) {
      AlarmSchedulerService.instance.scheduleAlarmInOS(alarm);
    }
  }

  Future<void> updateAlarm(Alarm updated) async {
    final current = List<Alarm>.from(alarmsNotifier.value);
    final index = current.indexWhere((a) => a.id == updated.id);
    if (index != -1) {
      current[index] = updated;
      alarmsNotifier.value = _sortedAlarms(current);

      await DatabaseService.instance.updateAlarm(updated);
      if (updated.isEnabled) {
        AlarmSchedulerService.instance.scheduleAlarmInOS(updated);
      } else {
        AlarmSchedulerService.instance.cancelAlarmInOS(updated.id);
      }
    }
  }

  Future<void> completeAlarmDismissal(String? alarmId) async {
    final current = List<Alarm>.from(alarmsNotifier.value);
    if (current.isEmpty) return;

    final index = alarmId != null
        ? current.indexWhere((a) => a.id == alarmId)
        : current.indexWhere((a) => a.isEnabled);

    if (index != -1) {
      final alarm = current[index];
      if (alarm.repeatDays.isEmpty) {
        // One-time alarm: disable after ringing
        final updated = alarm.copyWith(isEnabled: false);
        current[index] = updated;
        await DatabaseService.instance.updateAlarm(updated);
        AlarmSchedulerService.instance.cancelAlarmInOS(alarm.id);
      } else {
        // Repeating alarm: recalculate next occurrence & reschedule in OS
        await DatabaseService.instance.updateAlarm(alarm);
        AlarmSchedulerService.instance.scheduleAlarmInOS(alarm);
      }
      alarmsNotifier.value = _sortedAlarms(current);
    }
  }

  Future<void> duplicateAlarm(String id) async {
    final current = List<Alarm>.from(alarmsNotifier.value);
    final index = current.indexWhere((a) => a.id == id);
    if (index != -1) {
      final original = current[index];
      final duplicate = original.copyWith(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        label: '${original.label} (Copy)',
      );
      current.add(duplicate);
      alarmsNotifier.value = _sortedAlarms(current);

      await DatabaseService.instance.insertAlarm(duplicate);
      if (duplicate.isEnabled) {
        AlarmSchedulerService.instance.scheduleAlarmInOS(duplicate);
      }
    }
  }

  Future<void> toggleAlarm(String id, bool isEnabled) async {
    final current = List<Alarm>.from(alarmsNotifier.value);
    final index = current.indexWhere((a) => a.id == id);
    if (index != -1) {
      final updated = current[index].copyWith(isEnabled: isEnabled);
      current[index] = updated;
      alarmsNotifier.value = _sortedAlarms(current);

      await DatabaseService.instance.updateAlarm(updated);
      if (isEnabled) {
        AlarmSchedulerService.instance.scheduleAlarmInOS(updated);
      } else {
        AlarmSchedulerService.instance.cancelAlarmInOS(id);
      }
    }
  }

  Future<void> deleteAlarm(String id) async {
    final current = List<Alarm>.from(alarmsNotifier.value);
    current.removeWhere((a) => a.id == id);
    alarmsNotifier.value = _sortedAlarms(current);

    await DatabaseService.instance.deleteAlarm(id);
    AlarmSchedulerService.instance.cancelAlarmInOS(id);
  }

  List<Alarm> _sortedAlarms(List<Alarm> list) {
    final sorted = List<Alarm>.from(list);
    final now = DateTime.now();
    sorted.sort((a, b) {
      final timeA = a.getNextFireDateTime(now);
      final timeB = b.getNextFireDateTime(now);
      return timeA.compareTo(timeB);
    });
    return sorted;
  }
}
