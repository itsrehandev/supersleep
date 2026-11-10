import 'package:flutter/material.dart';

class ActiveAlarmScreen extends StatelessWidget {
  const ActiveAlarmScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.alarm_on,
                size: 80,
                color: Color(0xFF8AB4F8),
              ),
              const SizedBox(height: 24),
              Text(
                'Active Alarm',
                style: theme.textTheme.titleLarge?.copyWith(
                  color: Colors.white,
                  fontSize: 32,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
