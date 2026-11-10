import 'package:flutter/material.dart';

class StopwatchPage extends StatelessWidget {
  const StopwatchPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    return Scaffold(
      appBar: AppBar(
        title: Text('Stopwatch', style: textTheme.titleLarge),
        backgroundColor: theme.colorScheme.surface,
        centerTitle: false,
        elevation: 0,
      ),
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.timer,
                size: 64,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(height: 16),
              Text(
                'Stopwatch',
                style: textTheme.titleLarge,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
