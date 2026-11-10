import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import '../../services/alarm_permissions.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  static const _minimumVisibleDuration = Duration(milliseconds: 800);
  final AlarmPermissionService _permissionService =
      const AlarmPermissionService();
  Timer? _navigationTimer;

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    final start = DateTime.now();

    try {
      final hasPermissions = await _permissionService.ensureAlarmPermissions();
      if (!mounted) {
        return;
      }

      final elapsed = DateTime.now().difference(start);
      final remainingDelay = _minimumVisibleDuration - elapsed;
      if (remainingDelay > Duration.zero) {
        await Future<void>.delayed(remainingDelay);
      }

      if (!mounted) {
        return;
      }

      final route = hasPermissions ? '/alarms' : '/permissions/wizard';
      context.go(route);
    } catch (_) {
      if (mounted) {
        context.go('/permissions/wizard');
      }
    }
  }

  @override
  void dispose() {
    _navigationTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Container(
                width: 96,
                height: 96,
                decoration: BoxDecoration(
                  color: colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(22),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(18),
                  child: SvgPicture.asset(
                    'lib/assets/logo.svg',
                    semanticsLabel: 'Super Sleep logo',
                    width: 60,
                    height: 60,
                    fit: BoxFit.contain,
                    placeholderBuilder: (BuildContext context) => Icon(
                      Icons.alarm_rounded,
                      color: colorScheme.primary,
                      size: 40,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Super Sleep',
                style: theme.textTheme.titleLarge?.copyWith(
                  color: colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Wake up. Show up. Build your streak.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
