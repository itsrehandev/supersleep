import 'package:flutter/material.dart';

class StreakDashboardPage extends StatelessWidget {
  const StreakDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    return Scaffold(
      appBar: AppBar(
        title: Text('Streak & Score', style: textTheme.titleLarge),
        backgroundColor: theme.colorScheme.surface,
        centerTitle: false,
        elevation: 0,
      ),
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.local_fire_department,
                size: 64,
                color: Color(0xFFF59E0B),
              ),
              const SizedBox(height: 16),
              Text(
                'Streak Dashboard',
                style: textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              Text(
                'Build your streak by waking up on time.',
                style: textTheme.bodyMedium,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
