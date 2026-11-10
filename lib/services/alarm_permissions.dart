import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

class AlarmPermissionService {
  const AlarmPermissionService();

  Future<bool> ensureAlarmPermissions() async {
    final statuses = <Permission, PermissionStatus>{
      Permission.notification: await Permission.notification.status,
      Permission.scheduleExactAlarm: await Permission.scheduleExactAlarm.status,
    };

    var allGranted = true;
    for (final status in statuses.values) {
      if (!status.isGranted) {
        allGranted = false;
        break;
      }
    }

    if (allGranted) {
      return true;
    }

    final requested = <Permission>[];
    if (!statuses[Permission.notification]!.isGranted) {
      requested.add(Permission.notification);
    }
    if (!statuses[Permission.scheduleExactAlarm]!.isGranted) {
      requested.add(Permission.scheduleExactAlarm);
    }

    if (requested.isEmpty) {
      return true;
    }

    final results = await requested.request();
    for (final state in results.values) {
      if (!state.isGranted) {
        return false;
      }
    }

    return true;
  }

  Future<void> openAppSettingsIfNeeded(BuildContext context) async {
    final notificationStatus = await Permission.notification.status;
    final exactAlarmStatus = await Permission.scheduleExactAlarm.status;

    if (notificationStatus.isDenied || exactAlarmStatus.isDenied) {
      await openAppSettings();
    }
  }
}
