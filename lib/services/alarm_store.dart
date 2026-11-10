import 'package:flutter/material.dart';

import '../models/alarm_model.dart';

class AlarmStore {
  AlarmStore._();
  static final AlarmStore instance = AlarmStore._();

  final ValueNotifier<List<Alarm>> alarmsNotifier =
      ValueNotifier<List<Alarm>>([]);

  List<Alarm> get alarms => List.unmodifiable(_sortedAlarms(alarmsNotifier.value));

  void addAlarm(Alarm alarm) {
    final current = List<Alarm>.from(alarmsNotifier.value);
    current.add(alarm);
    alarmsNotifier.value = _sortedAlarms(current);
  }

  void toggleAlarm(String id, bool isEnabled) {
    final current = List<Alarm>.from(alarmsNotifier.value);
    final index = current.indexWhere((a) => a.id == id);
    if (index != -1) {
      current[index] = current[index].copyWith(isEnabled: isEnabled);
      alarmsNotifier.value = _sortedAlarms(current);
    }
  }

  void deleteAlarm(String id) {
    final current = List<Alarm>.from(alarmsNotifier.value);
    current.removeWhere((a) => a.id == id);
    alarmsNotifier.value = _sortedAlarms(current);
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
