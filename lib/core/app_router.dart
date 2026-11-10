import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../screens/home/home_screen.dart';
import '../screens/home/pages/alarms_page.dart';
import '../screens/home/pages/settings_page.dart';
import '../screens/home/pages/stopwatch_page.dart';
import '../screens/home/pages/streak_page.dart';
import '../screens/home/pages/timer_page.dart';
import '../screens/permissions/permission_wizard_screen.dart';
import '../screens/ringing/ringing_screen.dart';
import '../screens/splash/splash_screen.dart';

final GlobalKey<NavigatorState> rootNavigatorKey = GlobalKey<NavigatorState>();

final appRouter = GoRouter(
  navigatorKey: rootNavigatorKey,
  initialLocation: '/splash',
  debugLogDiagnostics: false,
  routes: [
    // Splash Screen (outside shell)
    GoRoute(
      path: '/splash',
      pageBuilder: (context, state) =>
          const NoTransitionPage(child: SplashScreen()),
    ),
    GoRoute(
      path: '/',
      redirect: (context, state) => '/splash',
    ),
    // Active Alarm Screen (outside shell)
    GoRoute(
      path: '/ringing',
      pageBuilder: (context, state) =>
          const NoTransitionPage(child: ActiveAlarmScreen()),
    ),
    // Permission Wizard Screen (outside shell)
    GoRoute(
      path: '/permissions/wizard',
      pageBuilder: (context, state) =>
          const NoTransitionPage(child: PermissionWizardScreen()),
    ),
    // Main App Shell with Bottom Navigation Bar
    ShellRoute(
      builder: (context, state, child) {
        return HomeScreen(child: child);
      },
      routes: [
        GoRoute(
          path: '/alarms',
          pageBuilder: (context, state) =>
              const NoTransitionPage(child: AlarmsDashboardPage()),
        ),
        GoRoute(
          path: '/streak',
          pageBuilder: (context, state) =>
              const NoTransitionPage(child: StreakDashboardPage()),
        ),
        GoRoute(
          path: '/timer',
          pageBuilder: (context, state) =>
              const NoTransitionPage(child: TimerPage()),
        ),
        GoRoute(
          path: '/stopwatch',
          pageBuilder: (context, state) =>
              const NoTransitionPage(child: StopwatchPage()),
        ),
        GoRoute(
          path: '/settings',
          pageBuilder: (context, state) =>
              const NoTransitionPage(child: SettingsPage()),
        ),
      ],
    ),
  ],
);
