import 'package:flutter/material.dart';

import 'core/app_router.dart';
import 'core/app_theme.dart';
import 'services/alarm_scheduler.dart';
import 'services/alarm_store.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AlarmStore.instance.loadAlarmsFromDb();
  await AlarmSchedulerService.instance.start();
  runApp(const SuperSleepApp());
}

class SuperSleepApp extends StatefulWidget {
  const SuperSleepApp({super.key});

  @override
  State<SuperSleepApp> createState() => _SuperSleepAppState();
}

class _SuperSleepAppState extends State<SuperSleepApp> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    AlarmSchedulerService.instance.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: AppTheme.themeMode,
      builder: (context, themeMode, _) => MaterialApp.router(
        title: 'Super Sleep',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: themeMode,
        routerConfig: appRouter,
      ),
    );
  }
}
