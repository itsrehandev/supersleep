import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

class PermissionWizardScreen extends StatefulWidget {
  const PermissionWizardScreen({super.key});

  @override
  State<PermissionWizardScreen> createState() => _PermissionWizardScreenState();
}

class _PermissionWizardScreenState extends State<PermissionWizardScreen> {
  bool _isRequesting = false;

  Future<void> _requestPermissions() async {
    setState(() => _isRequesting = true);

    try {
      final results = await Future.wait([
        Permission.notification.request(),
        Permission.scheduleExactAlarm.request(),
      ]);

      final granted = results.every((status) => status.isGranted);
      if (!mounted) {
        return;
      }

      if (granted) {
        Navigator.of(context).pushReplacementNamed('/alarms');
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Alarm permissions are required to ring on time.'),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isRequesting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Permission Setup Wizard'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Icon(
                Icons.notifications_active_rounded,
                size: 72,
                color: colorScheme.primary,
              ),
              const SizedBox(height: 20),
              Text(
                'Enable alarm permissions',
                style: theme.textTheme.headlineSmall,
              ),
              const SizedBox(height: 12),
              const Text(
                'Super Sleep needs notifications and exact-alarm permissions to ring reliably and wake you on time.',
              ),
              const SizedBox(height: 28),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: _isRequesting ? null : _requestPermissions,
                  icon: _isRequesting
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.lock_open_rounded),
                  label: Text(_isRequesting ? 'Requesting...' : 'Allow permissions'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
