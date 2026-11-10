import 'package:flutter/material.dart';

class Alarm {
  final String id;
  final TimeOfDay time;
  final String label;
  final Set<int> repeatDays; // 0=Mon, 1=Tue, ..., 6=Sun
  final bool isEnabled;
  final String ringtoneName;
  final String? ringtonePath;
  final bool mathMissionEnabled;
  final String mathDifficulty;
  final bool typingMissionEnabled;
  final String typingDifficulty;
  final bool qrMissionEnabled;
  final bool vibrationEnabled;
  final double volumePercentage;
  final bool gradualVolumeEnabled;
  final int gradualDurationSeconds;
  final bool snoozeEnabled;
  final int snoozeIntervalMinutes;

  Alarm({
    required this.id,
    required this.time,
    required this.label,
    required this.repeatDays,
    this.isEnabled = true,
    this.ringtoneName = 'Gentle Sunrise (Default)',
    this.ringtonePath,
    this.mathMissionEnabled = false,
    this.mathDifficulty = 'Medium',
    this.typingMissionEnabled = false,
    this.typingDifficulty = 'Easy',
    this.qrMissionEnabled = false,
    this.vibrationEnabled = true,
    this.volumePercentage = 70.0,
    this.gradualVolumeEnabled = true,
    this.gradualDurationSeconds = 15,
    this.snoozeEnabled = true,
    this.snoozeIntervalMinutes = 5,
  });

  Alarm copyWith({
    String? id,
    TimeOfDay? time,
    String? label,
    Set<int>? repeatDays,
    bool? isEnabled,
    String? ringtoneName,
    String? ringtonePath,
    bool? mathMissionEnabled,
    String? mathDifficulty,
    bool? typingMissionEnabled,
    String? typingDifficulty,
    bool? qrMissionEnabled,
    bool? vibrationEnabled,
    double? volumePercentage,
    bool? gradualVolumeEnabled,
    int? gradualDurationSeconds,
    bool? snoozeEnabled,
    int? snoozeIntervalMinutes,
  }) {
    return Alarm(
      id: id ?? this.id,
      time: time ?? this.time,
      label: label ?? this.label,
      repeatDays: repeatDays ?? this.repeatDays,
      isEnabled: isEnabled ?? this.isEnabled,
      ringtoneName: ringtoneName ?? this.ringtoneName,
      ringtonePath: ringtonePath ?? this.ringtonePath,
      mathMissionEnabled: mathMissionEnabled ?? this.mathMissionEnabled,
      mathDifficulty: mathDifficulty ?? this.mathDifficulty,
      typingMissionEnabled: typingMissionEnabled ?? this.typingMissionEnabled,
      typingDifficulty: typingDifficulty ?? this.typingDifficulty,
      qrMissionEnabled: qrMissionEnabled ?? this.qrMissionEnabled,
      vibrationEnabled: vibrationEnabled ?? this.vibrationEnabled,
      volumePercentage: volumePercentage ?? this.volumePercentage,
      gradualVolumeEnabled: gradualVolumeEnabled ?? this.gradualVolumeEnabled,
      gradualDurationSeconds: gradualDurationSeconds ?? this.gradualDurationSeconds,
      snoozeEnabled: snoozeEnabled ?? this.snoozeEnabled,
      snoozeIntervalMinutes: snoozeIntervalMinutes ?? this.snoozeIntervalMinutes,
    );
  }

  /// Calculates next DateTime when this alarm will fire from [now].
  DateTime getNextFireDateTime([DateTime? now]) {
    now ??= DateTime.now();
    final candidateToday = DateTime(
      now.year,
      now.month,
      now.day,
      time.hour,
      time.minute,
    );

    if (repeatDays.isEmpty) {
      if (candidateToday.isAfter(now)) {
        return candidateToday;
      } else {
        return candidateToday.add(const Duration(days: 1));
      }
    } else {
      for (int i = 0; i < 7; i++) {
        final checkDate = candidateToday.add(Duration(days: i));
        final weekdayIndex = (checkDate.weekday - 1) % 7;
        if (repeatDays.contains(weekdayIndex)) {
          if (i == 0 && checkDate.isBefore(now)) {
            continue;
          }
          return checkDate;
        }
      }
      return candidateToday.add(const Duration(days: 1));
    }
  }

  String getRepeatText() {
    if (repeatDays.isEmpty) return 'Once';
    if (repeatDays.length == 7) return 'Everyday';
    if (repeatDays.length == 5 &&
        repeatDays.contains(0) &&
        repeatDays.contains(1) &&
        repeatDays.contains(2) &&
        repeatDays.contains(3) &&
        repeatDays.contains(4)) {
      return 'Weekdays';
    }
    if (repeatDays.length == 2 &&
        repeatDays.contains(5) &&
        repeatDays.contains(6)) {
      return 'Weekends';
    }
    const dayNames = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final sorted = repeatDays.toList()..sort();
    return sorted.map((d) => dayNames[d]).join(', ');
  }
}
