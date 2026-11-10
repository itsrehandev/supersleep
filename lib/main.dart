import 'package:flutter/material.dart';

import 'core/app_router.dart';
import 'core/app_theme.dart';

void main() {
  runApp(const SuperSleepApp());
}

class SuperSleepApp extends StatelessWidget {
  const SuperSleepApp({super.key});

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
