import 'package:flutter/material.dart';

class AlarmsDashboardPage extends StatelessWidget {
  const AlarmsDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Scaffold(
      appBar: AppBar(
        title: Text('Super Sleep', style: textTheme.titleLarge),
        backgroundColor: colorScheme.surface,
        centerTitle: false,
        elevation: 0,
      ),
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.alarm,
                size: 64,
                color: colorScheme.primary,
              ),
              const SizedBox(height: 16),
              Text(
                'Alarms Dashboard',
                style: textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              Text(
                'No active alarms scheduled',
                style: textTheme.bodyMedium,
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {},
        icon: const Icon(Icons.add),
        label: const Text('Add Alarm'),
      ),
    );
  }
}
