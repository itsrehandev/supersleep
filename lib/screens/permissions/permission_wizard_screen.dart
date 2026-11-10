import 'package:flutter/material.dart';

class PermissionWizardScreen extends StatelessWidget {
  const PermissionWizardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Permission Setup Wizard'),
      ),
      body: SafeArea(
        child: Center(
          child: Text(
            'Permission Setup Wizard',
            style: theme.textTheme.titleLarge,
          ),
        ),
      ),
    );
  }
}
