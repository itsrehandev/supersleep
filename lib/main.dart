import 'package:flutter/material.dart';

import 'core/app_router.dart';
import 'core/app_theme.dart';
import 'services/alarm_scheduler.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
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
    AlarmSchedulerService.instance.start();
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
